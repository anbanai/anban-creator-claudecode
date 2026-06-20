#!/usr/bin/env bash
# SubagentStop 机械闸门：seednote agent 完成前验证产物完整性
# 官方依据：https://code.claude.com/docs/en/hooks（SubagentStop + decision:block）
#
# 检查清单（任一缺失则 block 强制 agent 继续）：
#   - $DIR/image-plan.md    证明走了 seednote-visual-design skill 的完整规划流程
#   - $DIR/image-prompts.md 证明每次 generate_image 后都追加了 prompt 记录
#   - $DIR/image-review.md  证明跑了 skill Step 6 质量验证
#   - 图片数 = image-plan.md 「计划图片数量」字段值（由 skill 步骤 3 写入，由 user prompt 指令驱动）
#
# 工作目录定位（关键）：
#   prepare_workspace(task_id=X) 返回字面字符串 "output"（不是 output/seednote/X/）。
#   agent 在 steps 4-9 把产物写到 output/，step 10 archive 才 mv 到 output/seednote/{title}/。
#   因此本脚本必须同时扫两个位置 + Docker 工作区，找不到时 fail-closed。

set -euo pipefail

# jq 是必需依赖，缺失时 fail-closed（不能让闸门因环境问题被绕过）
if ! command -v jq >/dev/null 2>&1; then
  jq_alt() {
    # 没有 jq 时手工输出最小 JSON（reason 里不含特殊字符）
    local reason="$1"
    printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$reason" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '"%s"' "$reason")"
  }
  jq_alt "seednote-quality-gate.sh: jq is required but not installed. Please install jq to enable the gate."
  exit 0
fi

INPUT=$(cat)

# 只对 seednote agent 生效（matcher 已过滤，脚本内再确认一次更稳）
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty' 2>/dev/null || true)
[[ "$AGENT_TYPE" != "seednote" ]] && exit 0

WORKSPACE_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

# 找最近被引用的 $DIR，按可能性排序收集候选：
# 1. output/seednote/{title}/ — 已归档（agent step 10 完成）
# 2. output/ — 未归档（agent steps 4-9，$DIR 字面 = "output"，需要看到 seednote 产物签名）
# 3. data/workspace/{task_id}/ 下的对应路径 — 服务端分发的 Docker 工作区
CANDIDATES=()

# 候选 1：已归档目录，按 mtime 倒序
while IFS= read -r dir; do
  [[ -n "$dir" ]] && CANDIDATES+=("$dir")
done < <(ls -td "$WORKSPACE_ROOT"/output/seednote/*/ 2>/dev/null || true)

# 候选 2：未归档的 output/，要求至少有一个 seednote 产物签名（避免误判非 seednote 的 output/）
if [[ -f "$WORKSPACE_ROOT/output/image-plan.md" ]] || [[ -f "$WORKSPACE_ROOT/output/cover.png" ]] || [[ -f "$WORKSPACE_ROOT/output/tail.png" ]]; then
  CANDIDATES+=("$WORKSPACE_ROOT/output/")
fi

# 候选 3：Docker 工作区，按 mtime 倒序
while IFS= read -r dir; do
  [[ -n "$dir" ]] && CANDIDATES+=("$dir")
done < <(find "$WORKSPACE_ROOT/data/workspace" -type d -path "*seednote*" -newermt "-2 hours" 2>/dev/null || true)

# Fail-closed：知道是 seednote agent 但找不到工作目录 → block（不能静默通过）
if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
  REASON="种子笔记机械闸门：未找到 seednote 工作目录（已扫描 output/、output/seednote/*/、data/workspace/*seednote*）。
这通常意味着 prepare_workspace 未执行，或 agent 在创建工作目录前就退出。
请确认步骤 4 已执行 prepare_workspace + mkdir -p，然后重试。"
  jq -nc --arg reason "$REASON" '{decision: "block", reason: $reason}'
  exit 0
fi

# 取第一个候选（最近被修改的）作为 $DIR
SEEDNOTE_DIR="${CANDIDATES[0]}"

MISSING=()
[[ ! -f "$SEEDNOTE_DIR/image-plan.md" ]]    && MISSING+=("image-plan.md（说明没调用 seednote-visual-design skill 走完整流程）")
[[ ! -f "$SEEDNOTE_DIR/image-prompts.md" ]] && MISSING+=("image-prompts.md（说明 generate_image 调用后没记录 prompt）")
[[ ! -f "$SEEDNOTE_DIR/image-review.md" ]]  && MISSING+=("image-review.md（说明没跑 skill Step 6 质量验证）")

# 图片数量：从 image-plan.md 解析「计划图片数量: N 张」字段（由 skill 步骤 3 写入）。
# 四种合法值 1/2/3 对应封面 / 封面+内容图 / 封面+尾图 / 封面+内容图+尾图，由 user prompt 指令驱动。
if [[ -f "$SEEDNOTE_DIR/image-plan.md" ]]; then
  EXPECTED=$(grep -oE '计划图片数量[:：]\s*[0-9]+' "$SEEDNOTE_DIR/image-plan.md" 2>/dev/null | grep -oE '[0-9]+' | head -1)
  if [[ -z "$EXPECTED" ]]; then
    MISSING+=("image-plan.md 缺「计划图片数量」字段（说明 skill 步骤 3 未执行）")
  else
    IMG_COUNT=$(find "$SEEDNOTE_DIR" -maxdepth 1 \( -name "cover.png" -o -name "image_*.png" -o -name "tail.png" \) -type f 2>/dev/null | wc -l | tr -d ' ')
    [[ "$IMG_COUNT" -ne "$EXPECTED" ]] && MISSING+=("图片数量（当前 $IMG_COUNT 张，应等于 image-plan.md 声明的 $EXPECTED 张）")
    [[ ! -f "$SEEDNOTE_DIR/cover.png" ]] && MISSING+=("cover.png（封面必选）")
  fi
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  REASON="种子笔记机械闸门未通过（${SEEDNOTE_DIR}），缺失：
$(printf '  - %s\n' "${MISSING[@]}")

请按 seednote-visual-design skill 流程补齐：先生成 image-plan.md（含「必须出现文字」字段），再逐张调用 generate_image（每次追加 image-prompts.md），最后跑 Step 6 写 image-review.md。禁止跳过 skill 直接调 generate_image。"
  jq -nc --arg reason "$REASON" '{decision: "block", reason: $reason}'
fi

exit 0
