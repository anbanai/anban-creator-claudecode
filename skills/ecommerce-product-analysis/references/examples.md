# ecommerce-product-analysis Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 多图部位标注

- Input: 茶类产品图包含干茶、茶汤、叶底、包装正面。
- Recommended path: 逐张 analyze_image，给 subject、可见信息和置信度。
- Artifacts: product-bible.md。
- Quality gate: subject 必须可供后续查表选 ref，不能只写“产品图”。

### Case 2: 低清图降级

- Input: 包装背面文字不可读。
- Recommended path: 标注 confidence=low，只锁定可见形状和颜色，请求补图或从后续生成中排除文字。
- Artifacts: product-bible.md、missing-info.md。
- Quality gate: 不得猜测配料、净含量、认证。

### Case 3: 最佳锚点选择

- Input: 多张主包装图中一张清晰、正面、光照稳定。
- Recommended path: 选为 ANCHOR_REF，说明原因和适用模块。
- Artifacts: best-refs.md。
- Quality gate: 锚点用于基准外观，不替代部位级参考选择。
