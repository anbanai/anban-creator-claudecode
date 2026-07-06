# seednote-research Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 主题热度分析

- Input: 用户想做“春季花茶”。
- Recommended path: 搜索热门笔记，提炼高频角度、用户痛点和可差异化切口。
- Artifacts: topic-analysis.md。
- Quality gate: 不要只列标题；要给可执行选题建议。

### Case 2: 已指定主题

- Input: prompt 明确 about: 白茶回甘。
- Recommended path: 直接采用主题，不 claim_topic，围绕关键词检索素材。
- Artifacts: topic-analysis.md。
- Quality gate: 避免重复消费服务端预认领。

### Case 3: 复刻源笔记抓取

- Input: 用户给 source note id。
- Recommended path: 拉取源详情，保存正文/图像线索/互动数据供拆解。
- Artifacts: source-note.md、source-assets.json。
- Quality gate: 源信息不足时记录缺口，不臆测。
