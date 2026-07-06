# video-use Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 口播去口癖成片

- Input: 用户给 8 分钟口播素材，要 90 秒干净版。
- Recommended path: 转写、选择 retake、剪掉口癖和停顿，加字幕和轻量包装。
- Artifacts: edit-plan.md、timeline.json、final.mp4。
- Quality gate: 剪辑点不截断语义，字幕与音频同步。

### Case 2: 产品演示加动效

- Input: 已有成片但需要重点标注卖点。
- Recommended path: 按场景选择 PIL/Remotion/HyperFrames/Manim overlay skill。
- Artifacts: overlay-plan.md、rendered-overlays/。
- Quality gate: 动效服务信息，不遮挡产品关键区域。

### Case 3: 多素材社媒导出

- Input: 用户给横版素材，要竖版短视频。
- Recommended path: 重构画幅、字幕安全区、封面帧和平台导出参数。
- Artifacts: export-plan.md、final_9x16.mp4。
- Quality gate: 移动端安全区文字不被裁切。
