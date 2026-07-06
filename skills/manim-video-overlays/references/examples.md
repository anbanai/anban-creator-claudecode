# manim-video-overlays Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 流程图解释

- Input: 课程视频需要解释“三步复盘法”。
- Recommended path: 用 Manim 画节点和箭头，按口播节奏逐步 reveal。
- Artifacts: scene.py、render.webm、manifest.json。
- Quality gate: 几何位置稳定，手机端文字可读。

### Case 2: 公式推导

- Input: 知识视频需要展示 ROI 公式变化。
- Recommended path: 用 Manim MathTex/文字 fallback 做分步推导。
- Artifacts: scene.py、render.webm。
- Quality gate: 公式不遮挡人脸和字幕安全区。

### Case 3: 时间线动画

- Input: 直播切片需要标出关键事件时间点。
- Recommended path: 用 deterministic timeline scene 输出透明 overlay。
- Artifacts: render.webm、metadata.json。
- Quality gate: 时间点与 transcript/EDL 对齐。
