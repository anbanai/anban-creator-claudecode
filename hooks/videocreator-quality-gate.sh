#!/usr/bin/env bash
# SubagentStop mechanical gate for the videocreator agent.

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
agent_re = re.compile(r'(^|[\s,;])agent(?:_name)?\s*[:=]\s*[`"\']?videocreator[`"\']?(?=$|[\s,;])', re.I)
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
  for manifest in "$root/output/input-manifest.md" "$root/output/videocreator/$task_id/input-manifest.md"; do
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
  videocreator|anban:videocreator) ;;
  *) exit 0 ;;
esac

WORKSPACE_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
VIDEO_DIR="$(find_manifest_dir "$WORKSPACE_ROOT")"
if [[ -z "$VIDEO_DIR" || ! -f "$VIDEO_DIR/input-manifest.md" ]]; then
  json_block "videocreator 机械闸门：未找到 input-manifest.md。请先执行 prepare_workspace(content_type=\"videocreator\", task_id=...) 并写入 input-manifest.md。"
  exit 0
fi

MISSING=()
[[ ! -s "$VIDEO_DIR/generation-plan.json" ]] && MISSING+=("generation-plan.json")
[[ ! -s "$VIDEO_DIR/video-task-submit.json" ]] && MISSING+=("video-task-submit.json")
[[ ! -s "$VIDEO_DIR/video-task-result.json" ]] && MISSING+=("video-task-result.json")
[[ ! -s "$VIDEO_DIR/delivery-manifest.json" ]] && MISSING+=("delivery-manifest.json")
[[ ! -s "$VIDEO_DIR/quality-review.md" ]] && MISSING+=("quality-review.md")

if [[ -s "$VIDEO_DIR/video-task-result.json" ]]; then
  python3 - "$VIDEO_DIR/video-task-result.json" <<'PY' || MISSING+=("video-task-result.json status 不是 succeeded")
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)
sys.exit(0 if data.get("status") == "succeeded" else 1)
PY
fi

if [[ -s "$VIDEO_DIR/delivery-manifest.json" ]]; then
  python3 - "$VIDEO_DIR/delivery-manifest.json" <<'PY' || MISSING+=("delivery-manifest.json 缺 task_file/file_url/final_video")
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)
sys.exit(0 if data.get("task_file") or data.get("file_url") or data.get("final_video") else 1)
PY
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  json_block "videocreator 机械闸门未通过（${VIDEO_DIR}），缺失：
$(printf '  - %s\n' "${MISSING[@]}")

请回到当前 videocreator agent 上下文继续执行视频生成工作流；禁止只报告后台运行。"
fi

exit 0
