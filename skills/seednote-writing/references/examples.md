# seednote-writing Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 测评型笔记

- Input: 主题是“6 款通勤杯对比”。
- Recommended path: 标题用数字+对象，正文用对比表述和真实使用场景，标签保留品类词。
- Artifacts: content.md、title-candidates.md。
- Quality gate: 正文发布版不用 Markdown 粗体或横线。

### Case 2: 情绪故事型笔记

- Input: 主题是“搬家后终于睡好”。
- Recommended path: 前两行写具体场景，正文以体验转折推进，结尾问开放问题。
- Artifacts: content.md。
- Quality gate: 不写“评论区告诉我/点赞收藏”。

### Case 3: 爆款改写

- Input: 源笔记结构强，用户要换到茶产品。
- Recommended path: 迁移钩子和节奏，替换案例、措辞、产品证据和标签。
- Artifacts: rewritten-content.md、clone-notes.md。
- Quality gate: 不能复制源笔记原句或具体视觉元素。
