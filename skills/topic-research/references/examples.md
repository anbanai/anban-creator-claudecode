# topic-research Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 公众号选题池

- Input: 账号定位是 AI 工具，用户说“写效率”。
- Recommended path: 搜索相关热门角度，按 engagement potential 打分并选一条大纲。
- Artifacts: 01-research.md、02-outline.md。
- Quality gate: 大纲至少 3 个二级标题，每节有观点和素材方向。

### Case 2: 避免重复旧题

- Input: 项目已有多篇“Prompt 技巧”文章。
- Recommended path: 对比历史标题，选择相邻但不重复的切口。
- Artifacts: topic-score.md。
- Quality gate: 不能只改标题复用旧内容。

### Case 3: 争议型选题

- Input: 主题“AI 会不会取代运营”。
- Recommended path: 拆正反观点、受众焦虑和可验证案例。
- Artifacts: outline.md。
- Quality gate: 避免制造无证据恐慌。
