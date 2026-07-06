#!/usr/bin/env bash
# SubagentStop mechanical gate for the seednote agent.
# Blocks completion when required visual-planning artifacts are missing.

set -euo pipefail

INPUT="$(cat)"
export HOOK_INPUT="$INPUT"
export WORKSPACE_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

python3 - <<'PY'
import glob
import json
import os
import re
import sys
from pathlib import Path


def block(reason: str) -> None:
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))


try:
    payload = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except json.JSONDecodeError:
    payload = {}

if payload.get("agent_type") != "seednote":
    sys.exit(0)

root = Path(os.environ.get("WORKSPACE_ROOT") or os.getcwd())
candidates: list[Path] = []

archive_dirs = [Path(p) for p in glob.glob(str(root / "output" / "seednote" / "*" / ""))]
archive_dirs.sort(key=lambda p: p.stat().st_mtime if p.exists() else 0, reverse=True)
candidates.extend(archive_dirs)

output_dir = root / "output"
if any((output_dir / name).exists() for name in ("image-plan.md", "cover.png", "tail.png")):
    candidates.append(output_dir)

workspace_dir = root / "data" / "workspace"
if workspace_dir.exists():
    workspace_candidates = [
        p
        for p in workspace_dir.rglob("*")
        if p.is_dir() and "seednote" in str(p)
    ]
    workspace_candidates.sort(key=lambda p: p.stat().st_mtime if p.exists() else 0, reverse=True)
    candidates.extend(workspace_candidates)

if not candidates:
    block(
        "种子笔记机械闸门：未找到 seednote 工作目录（已扫描 output/、output/seednote/*/、data/workspace/*seednote*）。\n"
        "这通常意味着 prepare_workspace 未执行，或 agent 在创建工作目录前就退出。\n"
        "请确认步骤 4 已执行 prepare_workspace + mkdir -p，然后重试。"
    )
    sys.exit(0)

seednote_dir = candidates[0]
missing: list[str] = []

if not (seednote_dir / "image-plan.md").is_file():
    missing.append("image-plan.md（说明没调用 seednote-visual-design skill 走完整流程）")
if not (seednote_dir / "image-prompts.md").is_file():
    missing.append("image-prompts.md（说明 generate_image 调用后没记录 prompt）")
if not (seednote_dir / "image-review.md").is_file():
    missing.append("image-review.md（说明没跑 skill Step 6 质量验证）")

plan_path = seednote_dir / "image-plan.md"
if plan_path.is_file():
    plan = plan_path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r"计划图片数量[:：]\s*(\d+)", plan)
    if not match:
        missing.append("image-plan.md 缺「计划图片数量」字段（说明 skill 步骤 3 未执行）")
    else:
        expected = int(match.group(1))
        images = [
            p
            for p in seednote_dir.iterdir()
            if p.is_file()
            and (p.name == "cover.png" or p.name == "tail.png" or re.fullmatch(r"image_.*\.png", p.name))
        ]
        image_count = len(images)
        if image_count != expected:
            missing.append(f"图片数量（当前 {image_count} 张，应等于 image-plan.md 声明的 {expected} 张）")
        if not (seednote_dir / "cover.png").is_file():
            missing.append("cover.png（封面必选）")
        content_count = len([p for p in images if p.name.startswith("image_")])
        if content_count > 3:
            missing.append(f"内容图超过 3 张上限（当前 {content_count} 张，应 ≤3）")

if missing:
    block(
        f"种子笔记机械闸门未通过（{seednote_dir}），缺失：\n"
        + "".join(f"  - {item}\n" for item in missing)
        + "\n请按 seednote-visual-design skill 流程补齐：先生成 image-plan.md（含「必须出现文字」字段），再逐张调用 generate_image（每次追加 image-prompts.md），最后跑 Step 6 写 image-review.md。禁止跳过 skill 直接调 generate_image。"
    )

sys.exit(0)
PY
