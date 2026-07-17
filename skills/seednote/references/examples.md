# seednote Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 新主题种草笔记

- Input: 用户输入“通勤保温杯种草”。
- Recommended path: 走选题、写作、图片规划、生成、交付全链路，TaskCreate 跟踪进度。
- Artifacts: topic-analysis.md、content.md、image-plan.md、manifest.json。
- Quality gate: 不得只输出文案；必须生成文件-backed 产物。

### Case 2: 复刻爆款但换产品

- Input: 用户提供源笔记链接和新产品。
- Recommended path: 先做 seednote-viral-analysis，确定 clone depth，再重写文案和视觉。
- Artifacts: source-analysis.md、template.md、content.md。
- Quality gate: 保留机制，不复制源笔记可识别表达。

### Case 3: 用户指定标题正文

- Input: 输入含“封面标题/笔记正文/话题标签”。
- Recommended path: 锁定用户字段，只做润色和平台格式化，图片围绕指定内容。
- Artifacts: content.md、image-plan.md。
- Quality gate: 不得扩展到新主题或覆盖用户标题。
