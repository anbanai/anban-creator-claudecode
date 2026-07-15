#!/usr/bin/env bash

set -Eeuo pipefail

STAGING_DIR=""
SOURCE_MANIFEST=""
STAGING_MANIFEST=""
SOURCE_FILES=""
STAGING_FILES=""
RESERVATION_DIR=""
RESERVATION_HELD=0
RESERVATION_TOKEN=""
CURRENT_CODE="archive_prepare_failed"

json_escape() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

contains_control_chars() {
  local LC_ALL=C
  [[ "$1" =~ [[:cntrl:]] ]]
}

emit_result() {
  local status=$1 code=$2 message=$3 archive_dir=${4:-}
  printf '{"status":"%s","code":"%s","message":"%s","archive_dir":"%s"}\n' \
    "$(json_escape "$status")" \
    "$(json_escape "$code")" \
    "$(json_escape "$message")" \
    "$(json_escape "$archive_dir")"
}

fail() {
  local code=$1 message=$2 exit_code=${3:-1}
  trap - ERR
  emit_result "recoverable_failure" "$code" "$message"
  exit "$exit_code"
}

on_error() {
  local exit_code=$? line=$1
  trap - ERR
  emit_result "recoverable_failure" "$CURRENT_CODE" "command failed at line $line (exit $exit_code)"
  exit "$exit_code"
}

cleanup() {
  local exit_code=$?
  set +e
  [[ -z "$STAGING_DIR" ]] || rm -rf -- "$STAGING_DIR"
  [[ -z "$SOURCE_MANIFEST" ]] || rm -f -- "$SOURCE_MANIFEST"
  [[ -z "$STAGING_MANIFEST" ]] || rm -f -- "$STAGING_MANIFEST"
  [[ -z "$SOURCE_FILES" ]] || rm -f -- "$SOURCE_FILES"
  [[ -z "$STAGING_FILES" ]] || rm -f -- "$STAGING_FILES"
  if [[ "$RESERVATION_HELD" == 1 && -f "$RESERVATION_DIR/owner" ]]; then
    local reservation_owner
    IFS= read -r reservation_owner < "$RESERVATION_DIR/owner"
    if [[ "$reservation_owner" == "$RESERVATION_TOKEN" ]]; then
      rm -f -- "$RESERVATION_DIR/owner"
      rmdir -- "$RESERVATION_DIR"
    fi
  fi
  return "$exit_code"
}

trap 'on_error "$LINENO"' ERR
trap cleanup EXIT

if [[ $# -ne 2 ]]; then
  fail "archive_invalid_arguments" "usage: archive-seednote-workspace.sh SOURCE_DIR PROPOSED_ARCHIVE_DIR" 64
fi

SOURCE_INPUT=$1
PROPOSED_INPUT=$2
if contains_control_chars "$SOURCE_INPUT" || contains_control_chars "$PROPOSED_INPUT"; then
  fail "archive_unsafe_path" "source and archive paths must not contain control characters" 64
fi
[[ -d "$SOURCE_INPUT" ]] || fail "archive_source_missing" "source directory does not exist: $SOURCE_INPUT"
[[ -n "$PROPOSED_INPUT" ]] || fail "archive_invalid_arguments" "proposed archive directory is empty" 64

SOURCE_DIR=$(cd "$SOURCE_INPUT" && pwd -P)
SOURCE_PARENT=$(dirname "$SOURCE_DIR")
case "/$PROPOSED_INPUT/" in
  *"/../"*) fail "archive_unsafe_destination" "archive destination must not contain a parent traversal" ;;
esac
case "$PROPOSED_INPUT" in
  /*) PROPOSED_ABS=$PROPOSED_INPUT ;;
  *) PROPOSED_ABS="$(pwd -P)/$PROPOSED_INPUT" ;;
esac
ARCHIVE_PARENT_INPUT=$(dirname "$PROPOSED_ABS")
ARCHIVE_BASENAME=$(basename "$PROPOSED_INPUT")
[[ -n "$ARCHIVE_BASENAME" && "$ARCHIVE_BASENAME" != "." && "$ARCHIVE_BASENAME" != ".." ]] || \
  fail "archive_invalid_arguments" "invalid archive basename: $ARCHIVE_BASENAME" 64

CURRENT_CODE="archive_prepare_failed"
EXISTING_PARENT=$ARCHIVE_PARENT_INPUT
while [[ ! -e "$EXISTING_PARENT" ]]; do
  NEXT_PARENT=$(dirname "$EXISTING_PARENT")
  [[ "$NEXT_PARENT" != "$EXISTING_PARENT" ]] || \
    fail "archive_unsafe_destination" "archive destination has no existing directory ancestor"
  EXISTING_PARENT=$NEXT_PARENT
done
[[ -d "$EXISTING_PARENT" ]] || \
  fail "archive_unsafe_destination" "archive destination ancestor is not a directory: $EXISTING_PARENT"
EXISTING_PARENT=$(cd "$EXISTING_PARENT" && pwd -P)
case "$EXISTING_PARENT/" in
  "$SOURCE_PARENT/"*) ;;
  *) fail "archive_unsafe_destination" "archive destination escapes the workspace root" ;;
esac

mkdir -p -- "$ARCHIVE_PARENT_INPUT"
ARCHIVE_PARENT=$(cd "$ARCHIVE_PARENT_INPUT" && pwd -P)
case "$ARCHIVE_PARENT/" in
  "$SOURCE_PARENT/"*) ;;
  *) fail "archive_unsafe_destination" "archive destination escapes the workspace root" ;;
esac
[[ "$ARCHIVE_PARENT" != "$SOURCE_DIR" ]] || \
  fail "archive_invalid_destination" "archive parent must not equal source directory"

device_id() {
  case "$(uname -s)" in
    Darwin|FreeBSD) stat -f '%d' "$1" ;;
    *) stat -c '%d' "$1" ;;
  esac
}

SOURCE_DEVICE=$(device_id "$SOURCE_PARENT")
ARCHIVE_DEVICE=$(device_id "$ARCHIVE_PARENT")
[[ "$SOURCE_DEVICE" == "$ARCHIVE_DEVICE" ]] || \
  fail "archive_cross_device" "source sibling staging and archive parent are on different filesystems"

STAGING_DIR=$(mktemp -d "$SOURCE_PARENT/.seednote-archive.XXXXXX")
SOURCE_MANIFEST=$(mktemp "$SOURCE_PARENT/.seednote-source-manifest.XXXXXX")
STAGING_MANIFEST=$(mktemp "$SOURCE_PARENT/.seednote-staging-manifest.XXXXXX")
SOURCE_FILES=$(mktemp "$SOURCE_PARENT/.seednote-source-files.XXXXXX")
STAGING_FILES=$(mktemp "$SOURCE_PARENT/.seednote-staging-files.XXXXXX")

TAR_BIN=${ANBAN_ARCHIVE_TAR_BIN:-tar}
TAR_BIN=$(command -v "$TAR_BIN") || fail "archive_copy_failed" "tar command is unavailable"
MV_BIN=${ANBAN_ARCHIVE_MV_BIN:-mv}
MV_BIN=$(command -v "$MV_BIN") || fail "archive_atomic_rename_failed" "mv command is unavailable"
TAR_EXCLUDES=()
SOURCE_EXCLUDE=""
case "$ARCHIVE_PARENT/" in
  "$SOURCE_DIR/"*)
    ARCHIVE_ROOT_REL=${ARCHIVE_PARENT#"$SOURCE_DIR/"}
    TAR_EXCLUDES+=("--exclude=./$ARCHIVE_ROOT_REL")
    SOURCE_EXCLUDE=$ARCHIVE_PARENT
    ;;
esac

if [[ -n "${ANBAN_ARCHIVE_HASH_BIN:-}" ]]; then
  HASH_TOOL=$(command -v "$ANBAN_ARCHIVE_HASH_BIN") || fail "archive_hash_tool_missing" "configured hash command is unavailable"
  HASH_MODE=sha256sum
elif HASH_TOOL=$(command -v sha256sum); then
  HASH_MODE=sha256sum
elif HASH_TOOL=$(command -v shasum); then
  HASH_MODE=shasum
else
  fail "archive_hash_tool_missing" "sha256sum and shasum are unavailable"
fi

hash_file() {
  if [[ "$HASH_MODE" == "sha256sum" ]]; then
    "$HASH_TOOL" "$1" | awk '{print $1}'
  else
    "$HASH_TOOL" -a 256 "$1" | awk '{print $1}'
  fi
}

hash_text() {
  if [[ "$HASH_MODE" == "sha256sum" ]]; then
    "$HASH_TOOL" | awk '{print $1}'
  else
    "$HASH_TOOL" -a 256 | awk '{print $1}'
  fi
}

inode_id() {
  case "$(uname -s)" in
    Darwin|FreeBSD) stat -f '%i' "$1" ;;
    *) stat -c '%i' "$1" ;;
  esac
}

build_manifest() {
  local root=$1 manifest=$2 file_list=$3 exclude=${4:-}
  if [[ -n "$exclude" ]]; then
    find "$root" -path "$exclude" -prune -o -print0 > "$file_list"
  else
    find "$root" -print0 > "$file_list"
  fi
  : > "$manifest"
  while IFS= read -r -d '' file; do
    local relative size hash
    [[ "$file" != "$root" ]] || continue
    relative=${file#"$root/"}
    if contains_control_chars "$relative"; then
      fail "archive_unsafe_path" "source contains a path with control characters"
    fi
    if [[ -L "$file" ]]; then
      fail "archive_unsafe_file_type" "source contains a symbolic link: $relative"
    elif [[ -d "$file" ]]; then
      printf 'directory\t%s\n' "$relative" >> "$manifest"
    elif [[ -f "$file" ]]; then
      size=$(wc -c < "$file")
      hash=$(hash_file "$file")
      printf 'file\t%s\t%s\t%s\n' "$relative" "$size" "$hash" >> "$manifest"
    else
      fail "archive_unsafe_file_type" "source contains a non-regular entry: $relative"
    fi
  done < "$file_list"
  LC_ALL=C sort -o "$manifest" "$manifest"
}

CURRENT_CODE="archive_manifest_failed"
build_manifest "$SOURCE_DIR" "$SOURCE_MANIFEST" "$SOURCE_FILES" "$SOURCE_EXCLUDE"

CURRENT_CODE="archive_copy_failed"
"$TAR_BIN" -C "$SOURCE_DIR" "${TAR_EXCLUDES[@]}" -cf - . | "$TAR_BIN" -C "$STAGING_DIR" -xf -

CURRENT_CODE="archive_manifest_failed"
build_manifest "$STAGING_DIR" "$STAGING_MANIFEST" "$STAGING_FILES"
cmp "$SOURCE_MANIFEST" "$STAGING_MANIFEST"

release_reservation() {
  local owner_token=""
  if [[ "$RESERVATION_HELD" == 1 && -f "$RESERVATION_DIR/owner" ]]; then
    IFS= read -r owner_token < "$RESERVATION_DIR/owner" || true
    if [[ "$owner_token" == "$RESERVATION_TOKEN" ]]; then
      rm -f -- "$RESERVATION_DIR/owner"
      rmdir -- "$RESERVATION_DIR"
    fi
  fi
  RESERVATION_HELD=0
}

RESERVATION_TOKEN="${BASHPID:-$$}-$(date +%s)-$RANDOM"
SUFFIX=1
while true; do
  if [[ "$SUFFIX" == 1 ]]; then
    CANDIDATE="$ARCHIVE_PARENT/$ARCHIVE_BASENAME"
  else
    CANDIDATE="$ARCHIVE_PARENT/$ARCHIVE_BASENAME-$SUFFIX"
  fi
  SUFFIX=$((SUFFIX + 1))
  [[ ! -e "$CANDIDATE" ]] || continue

  RESERVATION_KEY=$(printf '%s' "$CANDIDATE" | hash_text)
  RESERVATION_DIR="$ARCHIVE_PARENT/.archive-reserve-$RESERVATION_KEY"
  if ! mkdir -- "$RESERVATION_DIR" 2>/dev/null; then
    continue
  fi
  RESERVATION_HELD=1
  printf '%s\n' "$RESERVATION_TOKEN" > "$RESERVATION_DIR/owner"
  if [[ -e "$CANDIDATE" ]]; then
    release_reservation
    continue
  fi

  CURRENT_CODE="archive_atomic_rename_failed"
  STAGING_INODE=$(inode_id "$STAGING_DIR")
  STAGING_BASENAME=$(basename "$STAGING_DIR")
  if ! "$MV_BIN" -- "$STAGING_DIR" "$CANDIDATE"; then
    fail "archive_atomic_rename_failed" "failed to atomically publish the verified archive"
  fi

  CANDIDATE_INODE=""
  if [[ -d "$CANDIDATE" ]]; then
    CANDIDATE_INODE=$(inode_id "$CANDIDATE")
  fi
  if [[ "$CANDIDATE_INODE" != "$STAGING_INODE" ]]; then
    NESTED_STAGING="$CANDIDATE/$STAGING_BASENAME"
    if [[ -d "$NESTED_STAGING" && "$(inode_id "$NESTED_STAGING")" == "$STAGING_INODE" ]]; then
      rm -rf -- "$NESTED_STAGING"
    fi
    fail "archive_destination_race" "archive destination was occupied by an external writer"
  fi

  STAGING_DIR=""
  release_reservation
  break
done

rm -f -- "$SOURCE_MANIFEST" "$STAGING_MANIFEST" "$SOURCE_FILES" "$STAGING_FILES"
SOURCE_MANIFEST=""
STAGING_MANIFEST=""
SOURCE_FILES=""
STAGING_FILES=""

emit_result "archived" "archive_created" "archive verified and atomically published; source retained" "$CANDIDATE"
