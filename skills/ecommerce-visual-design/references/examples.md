# ecommerce-visual-design Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 主图五连张

- Input: 已有产品档案和主图文案。
- Recommended path: 主图 1 先锁商品基准，后续主图按卖点变化构图并按需选部位 ref。
- Artifacts: asset-plan.md、main_01.png..main_05.png。
- Quality gate: 商品形状/包装/logo 跨图一致，构图不重复。

### Case 2: 详情页分屏解释

- Input: 产品需要展示材质、使用步骤、对比优势。
- Recommended path: 按 detail-page 模块规划信息层级，每节只承载一个主卖点。
- Artifacts: detail_01.png..detail_NN.png、image-prompts.md。
- Quality gate: 文字可读，平台尺寸符合 target_platform。

### Case 3: 分享图轻量传播

- Input: 需要朋友圈/社群分享图。
- Recommended path: 保留商品真实参考，弱化硬广，突出一条记忆点和场景氛围。
- Artifacts: share_01.png、vision-check.md。
- Quality gate: 不可牺牲产品保真来换氛围。
