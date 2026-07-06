# dreamina-video Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 产品图生推广视频

- Input: 用户给保温杯图片，要 5 秒种草视频。
- Recommended path: 锁定产品外观，生成开场痛点、卖点演示、收尾 CTA 三段提示。
- Artifacts: video-prompt.md、dreamina-result.json。
- Quality gate: 不得凭空改变品牌/logo/瓶身文字；时长按任务或参考视频决定。

### Case 2: 参考视频节奏复刻

- Input: 用户给一段口播参考视频和新主题。
- Recommended path: 只迁移节奏、镜头密度和转场逻辑，人物/内容全部替换。
- Artifacts: reference-analysis.md、video-prompt.md。
- Quality gate: 避免复刻可识别人物、背景和文案。

### Case 3: 多模态获客短片

- Input: 有人像图、产品图、音频口播三类参考。
- Recommended path: 拆分主体、产品、声音节奏的约束，按 provider 支持传引用。
- Artifacts: asset-map.md、prompt.md。
- Quality gate: 引用数量不超模型能力，失败时记录降级策略。
