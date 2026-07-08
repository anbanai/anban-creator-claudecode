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

### Case 4: 养生号泛水墨模板感

- Input: 多篇中医/养生文章封面都是浅米色水墨山水、茶盏、莲花或药材摆拍。
- Recommended path: 保留中医调性，但为每篇提炼不同 `cover_hook`、`visual_metaphor` 和 `thumbnail_strategy`；把主体做大、对比做强，禁止无主体山水当封面。
- Artifacts: cover-prompt.md 记录 `anti_generic_constraints`，cover.png。
- Quality gate: 命中“泛水墨模板感”或缩成 200px 后看不出主题，`specificity_not_generic` / `thumbnail_readability` 判低并重试。

### Case 5: 三伏贴重复图

- Input: 两篇“三伏贴”文章都生成了几乎相同的手部或贴敷画面。
- Recommended path: 一个封面可表现穴位贴近景，另一个改用“贴错/贴对”的视觉对比或背部穴位安全区构图，避免同主体同构图。
- Artifacts: cover-prompt.md、visual_quality_scorecard。
- Quality gate: `series_distinctiveness` 必须至少 medium；若和历史/同批封面无法区分，先改隐喻再重试。

### Case 6: 绿豆汤主题不清

- Input: 标题讨论“为什么有人解暑、有人拉肚子”，封面只有一碗汤和远山。
- Recommended path: 用一碗绿豆汤连接两种体质反应的对比隐喻，例如一侧清凉舒缓、一侧腹部不适或寒凉提示，仍保持合规克制。
- Artifacts: cover-prompt.md 中写明 `cover_hook` 和 `required_entities`。
- Quality gate: 封面必须能看出“差异/对比/人群不适配”，否则 `title_cover_digest_alignment` 判低。

### Case 7: 黑白人像风格漂移

- Input: 养生文章列表里混入黑白男性人像，与账号视觉系统断裂。
- Recommended path: 回到任务解析的 `visual_style` 和文章核心隐喻，除非正文就是人物故事且有合规肖像来源，否则不用陌生人像作封面主体。
- Artifacts: cover-prompt.md 记录 `style_consistency` 失败原因和重试 prompt。
- Quality gate: 与账号风格或标题主题无关的人像判为“黑白人像风格漂移”，不得进入发布。

### Case 8: 截图暴露的封面质量问题

- Input: 同批文章截图里出现泛水墨模板感，三伏贴重复，绿豆汤主题不清，黑白人像风格漂移。
- Recommended path: 每篇先写 `cover_hook`、`visual_metaphor`、`thumbnail_strategy` 和 `anti_generic_constraints`，明确禁止上一批失败画面再次出现。
- Artifacts: cover-prompt.md、cover-review.md、viral-audit.md。
- Quality gate: `visual_quality_scorecard.specificity_not_generic`、`series_distinctiveness`、`title_cover_digest_alignment` 不低于 medium；否则重写封面概念再生成。
