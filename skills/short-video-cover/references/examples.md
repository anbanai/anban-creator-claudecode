# short-video-cover Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 轻度参考封面

- Input: 用户给参考封面和新标题“3 个剪辑误区”。
- Recommended path: 只学色彩/字体层级，构图和主体重新设计。
- Artifacts: reference-analysis.md、cover-prompt.md、cover.png。
- Quality gate: reference_depth=light 时 prompt 不要求参考构图。

### Case 2: 深度参考但换语义

- Input: 参考封面是人物居中+大字，新主题是职场表达。
- Recommended path: 保留主体位置逻辑，替换人物、背景和装饰语义。
- Artifacts: migration-plan.md、cover.png。
- Quality gate: 不能像素级复制参考封面。

### Case 3: 生成后优化

- Input: 首版文字可读但主体遮挡标题。
- Recommended path: 根据 optimization-checklist 调整标题区安全边距和主体位置。
- Artifacts: cover-review.md、cover_v2.png。
- Quality gate: 必须记录为什么重生成。
