# ecommerce-copywriting Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 高客单茶礼卖点

- Input: 产品档案显示产区、年份、礼盒、低咖啡因。
- Recommended path: 用 FABE 排序，把“送礼体面”和“晚间可饮”拆成主图/详情页文案。
- Artifacts: copywriting.md。
- Quality gate: 不写“顶级/最佳/第一”等极限词。

### Case 2: 3C 配件参数转卖点

- Input: 产品图包含接口、功率、兼容型号。
- Recommended path: 把参数翻译成使用收益，主图短句、详情页用证据支撑。
- Artifacts: main-copy.md、detail-copy.md。
- Quality gate: 参数不确定时标待核验，不编造认证。

### Case 3: 食品场景化种草

- Input: 产品是低糖燕麦棒。
- Recommended path: 用早餐、加班、运动后场景组织文案，避免医疗功效暗示。
- Artifacts: copywriting.md、compliance-notes.md。
- Quality gate: 健康表达只写配料和口感，不写治疗/减肥承诺。
