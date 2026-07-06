# article-cover-design Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 抽象管理主题封面

- Input: 文章核心是“中层管理的隐性成本”，无可视产品。
- Recommended path: 从文章比喻中提取“看不见的负重”视觉隐喻，用 900x383 构图并保护中心安全区。
- Artifacts: cover-prompt.md、cover.png、cover-review.md。
- Quality gate: 转发卡 1:1 裁切主体仍完整，文字只在必要时使用短词。

### Case 2: 强人物故事封面

- Input: 文章讲一位店长从亏损到盈利的复盘。
- Recommended path: 用人物背影/柜台/账本构成故事张力，不复刻真人肖像，不把标题塞满画面。
- Artifacts: cover-prompt.md、vision-score.md。
- Quality gate: 6 维评分中主题相关性和安全区任一 FAIL 都要重生成。

### Case 3: 系列栏目统一封面

- Input: 账号有固定“增长笔记”栏目风格。
- Recommended path: 沿用栏目色彩和留白纪律，主体隐喻随文章变化，保留系列识别但避免模板化。
- Artifacts: cover.png、best-refs.md。
- Quality gate: 同系列可识别，单篇主题也能从首屏看懂。
