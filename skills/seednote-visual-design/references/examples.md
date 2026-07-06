# seednote-visual-design Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 单封面模式

- Input: seednote_image_mode 只含 cover。
- Recommended path: 只生成 cover.png，不生成内容图和尾图。
- Artifacts: cover-prompt.md、cover.png。
- Quality gate: 缺 image_01.png 不算失败。

### Case 2: 封面+内容图

- Input: 正文有 7 个信息点。
- Recommended path: 信息点分成 2-3 张内容图，每张 2-4 点，独立场景但共享风格块。
- Artifacts: image-plan.md、cover.png、image_01.png、image_02.png。
- Quality gate: 不使用封面作 ref 导致内容图雷同。

### Case 3: 复刻风格不复刻构图

- Input: 源笔记推荐 medium clone。
- Recommended path: 参考色调和信息结构，替换视觉主体、场景和版式。
- Artifacts: image-plan.md、visual-risk.md。
- Quality gate: 不得复用源图人物姿势/图标组合/文字框位置。
