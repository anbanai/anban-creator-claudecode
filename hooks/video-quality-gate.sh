#!/usr/bin/env bash
# SubagentStop mechanical gate for the video agent.
# Blocks completion when the selected video workflow has not produced its
# required durable delivery artifacts.

set -euo pipefail

json_block() {
  local reason="$1"
  python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason":sys.stdin.read()}, ensure_ascii=False))' <<< "$reason"
}

json_agent_type() {
  python3 -c 'import json,sys; print((json.load(sys.stdin).get("agent_type") or ""))' 2>/dev/null || true
}

json_status_succeeded() {
  python3 - "$1" <<'PY'
import json
import sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
sys.exit(0 if data.get("status") == "succeeded" else 1)
PY
}

json_has_delivery() {
  python3 - "$1" <<'PY'
import json
import sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
sys.exit(0 if data.get("task_file") or data.get("file_url") else 1)
PY
}

INPUT=$(cat)
AGENT_TYPE=$(printf "%s" "$INPUT" | json_agent_type)
case "$AGENT_TYPE" in
  video|videocreator|videoeditor) ;;
  *) exit 0 ;;
esac

WORKSPACE_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
CANDIDATES=()

while IFS= read -r dir; do
  [[ -n "$dir" ]] && CANDIDATES+=("$dir")
done < <(ls -td "$WORKSPACE_ROOT"/output/video/*/ 2>/dev/null || true)

if [[ -f "$WORKSPACE_ROOT/output/input-manifest.md" ]]; then
  CANDIDATES+=("$WORKSPACE_ROOT/output/")
fi

if [[ -d "$WORKSPACE_ROOT/data/workspace" ]]; then
  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] && CANDIDATES+=("$(dirname "$manifest")")
  done < <(find "$WORKSPACE_ROOT/data/workspace" -type f -name "input-manifest.md" -print 2>/dev/null || true)
fi

if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
  json_block "视频机械闸门：未找到 video 工作目录或 input-manifest.md。请先执行 prepare_workspace(content_type=\"video\", task_id=...) 并写入 input-manifest.md。"
  exit 0
fi

VIDEO_DIR="${CANDIDATES[0]}"
MANIFEST="$VIDEO_DIR/input-manifest.md"
if [[ ! -f "$MANIFEST" ]]; then
  json_block "视频机械闸门：${VIDEO_DIR} 缺 input-manifest.md，无法确认 workflow。"
  exit 0
fi

TEXT=$(tr '[:upper:]' '[:lower:]' < "$MANIFEST")
MISSING=()

if echo "$TEXT" | grep -q "dreamina-video"; then
  [[ ! -s "$VIDEO_DIR/video-task-submit.json" ]] && MISSING+=("video-task-submit.json（缺 create_video_generation_task 记录）")
  [[ ! -s "$VIDEO_DIR/video-task-result.json" ]] && MISSING+=("video-task-result.json（缺 query_video_generation_task 终态记录）")
  [[ ! -s "$VIDEO_DIR/delivery-manifest.json" ]] && MISSING+=("delivery-manifest.json（缺 download_video_generation_result 注册结果）")
  if [[ -s "$VIDEO_DIR/video-task-result.json" ]] && ! json_status_succeeded "$VIDEO_DIR/video-task-result.json" >/dev/null 2>&1; then
    MISSING+=("video-task-result.json status 不是 succeeded")
  fi
  if [[ -s "$VIDEO_DIR/delivery-manifest.json" ]] && ! json_has_delivery "$VIDEO_DIR/delivery-manifest.json" >/dev/null 2>&1; then
    MISSING+=("delivery-manifest.json 缺 task_file/file_url")
  fi
elif echo "$TEXT" | grep -q "video-use"; then
  [[ ! -s "$VIDEO_DIR/edit/edl.json" ]] && MISSING+=("edit/edl.json")
  [[ ! -s "$VIDEO_DIR/final.mp4" && ! -s "$VIDEO_DIR/preview.mp4" ]] && MISSING+=("final.mp4 或 preview.mp4")
elif echo "$TEXT" | grep -q "short-video-cover"; then
  [[ ! -s "$VIDEO_DIR/cover.png" && ! -s "$VIDEO_DIR/cover_v2.png" ]] && MISSING+=("cover.png 或 cover_v2.png")
elif echo "$TEXT" | grep -q "portrait-pose-variants"; then
  if ! find "$VIDEO_DIR" -maxdepth 1 -name "variant_*.png" -type f -size +0c -print 2>/dev/null | grep -q .; then
    MISSING+=("variant_*.png")
  fi
elif echo "$TEXT" | grep -q "capcut-draft"; then
  if ! find "$VIDEO_DIR" -type f \( -name "*.json" -o -name "*.draft" \) -size +0c -print 2>/dev/null | grep -q .; then
    MISSING+=("剪映草稿 JSON/files")
  fi
else
  MISSING+=("input-manifest.md 未声明 dreamina-video/video-use/short-video-cover/portrait-pose-variants/capcut-draft")
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  REASON="视频机械闸门未通过（${VIDEO_DIR}），缺失：
$(printf '  - %s\n' "${MISSING[@]}")

请回到当前 video agent 上下文继续执行对应 skill；禁止只启动嵌套 Agent 或只报告后台运行。"
  json_block "$REASON"
fi

exit 0
