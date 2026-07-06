# seo-optimization Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 公众号搜索标题

- Input: 文章标题候选太文学化。
- Recommended path: 保留传播性，同时加入核心关键词和用户搜索词。
- Artifacts: seo-title.md。
- Quality gate: 标题自然可读，不堆砌关键词。

### Case 2: 摘要生成

- Input: 文章是长篇方法论，需要草稿 digest。
- Recommended path: 写 1 句具体收益+适用人群，避免夸张承诺。
- Artifacts: digest.md。
- Quality gate: 摘要不超过平台限制，且不含违禁词。

### Case 3: 关键词补齐

- Input: 主题涉及“私域增长”，正文缺相关词。
- Recommended path: 在小标题和段落中自然补充同义词。
- Artifacts: keyword-report.md。
- Quality gate: 关键词加入不改变原论点。
