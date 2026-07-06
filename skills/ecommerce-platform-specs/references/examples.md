# ecommerce-platform-specs Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 微信小店合规扫描

- Input: target_platform=wechat_store，文案含“转发返现”。
- Recommended path: 映射到微信小店规范，标记诱导分享高风险并改写。
- Artifacts: compliance-report.md。
- Quality gate: 命中高风险的图必须重生成后才能归档。

### Case 2: 功效类美妆文案

- Input: 详情页写“7 天根治痘痘”。
- Recommended path: 按广告法和类目规范改成可验证、非治疗承诺表达。
- Artifacts: compliance-report.md。
- Quality gate: 不得保留“根治/永久/100%”等绝对化词。

### Case 3: 疑似误报商标名

- Input: 产品名含“金牌”但为注册品牌词。
- Recommended path: 标中风险人工复核，不自动删除核心商品名。
- Artifacts: compliance-report.md。
- Quality gate: 误报处理要记录依据和人工复核建议。
