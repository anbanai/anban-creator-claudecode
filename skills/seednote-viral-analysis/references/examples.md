# seednote-viral-analysis Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 结构迁移判断

- Input: 源笔记是“3 个省钱技巧”清单。
- Recommended path: 拆标题钩子、正文节奏、视觉页主题，给 recommended_clone_depth。
- Artifacts: source-analysis.md、template.json。
- Quality gate: tight 只用于低风险通用结构。

### Case 2: 高风险视觉复刻

- Input: 源封面有人像姿势和品牌包装。
- Recommended path: 标出 do_not_copy：姿势、图标组合、文字框位置。
- Artifacts: risk-report.md。
- Quality gate: 只能迁移信息层级和互动机制。

### Case 3: 爆款模板输出

- Input: 源笔记互动强但主题要换成另一产品。
- Recommended path: 产出可填充模板：标题公式、开头方式、内容页结构。
- Artifacts: template.md。
- Quality gate: 模板不包含源文案原句。
