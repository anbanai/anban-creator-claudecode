#!/usr/bin/env bash
# SubagentStop mechanical gate for the videoeditor agent.

set -euo pipefail

json_block() {
  local reason="$1"
  python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason":sys.stdin.read()}, ensure_ascii=False))' <<< "$reason"
}

json_agent_type() {
  python3 -c 'import json,sys; print((json.load(sys.stdin).get("agent_type") or ""))' 2>/dev/null || true
}

manifest_matches() {
  local manifest="$1"
  python3 - "$manifest" "${TASK_ID:-}" <<'PY'
import pathlib
import re
import sys

manifest = pathlib.Path(sys.argv[1])
task_id = sys.argv[2]
text = manifest.read_text(encoding="utf-8", errors="ignore")
agent_re = re.compile(r'(^|[\s,;])agent(?:_name)?\s*[:=]\s*[`"\']?videoeditor[`"\']?(?=$|[\s,;])', re.I)
if not agent_re.search(text):
    sys.exit(1)
if task_id and task_id not in text:
    sys.exit(1)
PY
}

find_manifest_dir() {
  local root="$1"
  local task_id="${TASK_ID:-}"
  local manifest
  for manifest in "$root/output/input-manifest.md" "$root/output/videoeditor/$task_id/input-manifest.md"; do
    [[ -f "$manifest" ]] && manifest_matches "$manifest" && { dirname "$manifest"; return 0; }
  done
  find "$root" -path "*/input-manifest.md" -type f -print 2>/dev/null | while read -r manifest; do
    if manifest_matches "$manifest"; then
      dirname "$manifest"
      return 0
    fi
  done | head -n 1
}

INPUT=$(cat)
AGENT_TYPE=$(printf "%s" "$INPUT" | json_agent_type)
case "$AGENT_TYPE" in
  videoeditor|anban:videoeditor) ;;
  *) exit 0 ;;
esac

WORKSPACE_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
VIDEO_DIR="$(find_manifest_dir "$WORKSPACE_ROOT")"
if [[ -z "$VIDEO_DIR" || ! -f "$VIDEO_DIR/input-manifest.md" ]]; then
  json_block "videoeditor 机械闸门：未找到 input-manifest.md。请先执行 prepare_workspace(content_type=\"videoeditor\", task_id=...) 并写入 input-manifest.md。"
  exit 0
fi

MISSING=()
HAS_RENDERED_DELIVERY=0
if [[ -s "$VIDEO_DIR/edit/edl.json" && ( -s "$VIDEO_DIR/final.mp4" || -s "$VIDEO_DIR/preview.mp4" ) ]]; then
  HAS_RENDERED_DELIVERY=1
fi
HAS_DRAFT_PACKAGE=0
if find "$VIDEO_DIR" -type f -name "draft_info.json" -size +0c -print 2>/dev/null | grep -Eq '/capcut(-draft)?(/|$)' &&
   find "$VIDEO_DIR" -type f -name "draft_meta_info.json" -size +0c -print 2>/dev/null | grep -Eq '/capcut(-draft)?(/|$)'; then
  HAS_DRAFT_PACKAGE=1
fi
if [[ "$HAS_RENDERED_DELIVERY" != "1" && "$HAS_DRAFT_PACKAGE" != "1" ]]; then
  MISSING+=("edit/edl.json + final.mp4/preview.mp4，或包含 draft_info.json 与 draft_meta_info.json 的剪映草稿包")
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  json_block "videoeditor 机械闸门未通过（${VIDEO_DIR}），缺失：
$(printf '  - %s\n' "${MISSING[@]}")

请回到当前 videoeditor agent 上下文继续执行 video-use 工作流；禁止只报告后台运行。"
fi

exit 0
