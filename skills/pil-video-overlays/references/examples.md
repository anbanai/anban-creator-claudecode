# pil-video-overlays Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 进度条计数器

- Input: 短视频需要 5 秒倒计时进度条。
- Recommended path: 用 Pillow 生成 RGBA 帧，再编码 alpha WebM。
- Artifacts: frames/、render.webm、manifest.json。
- Quality gate: 帧数=fps*duration，透明背景有效。

### Case 2: 静态提示牌轻动效

- Input: 视频角落出现“重点 1/3”。
- Recommended path: 生成少量 PNG 帧实现淡入/淡出，无额外 JS 依赖。
- Artifacts: frames/、render.webm。
- Quality gate: 文字足够大且不占字幕区。

### Case 3: 最低依赖降级

- Input: Remotion/HyperFrames 不可用。
- Recommended path: 改用 PIL 简单卡片，记录降级原因。
- Artifacts: manifest.json、render.webm。
- Quality gate: 视觉简单但 timing 和尺寸准确。
