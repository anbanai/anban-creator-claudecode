# line-art-coloring Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 三角色儿童插画

- Input: 一组线稿包含女孩、猫、风筝。
- Recommended path: 先建 Color Bible，再用原线稿单源 ref 生成候选并做颜色/线稿双轨审计。
- Artifacts: color-bible.md、colored_01.png、consistency-report.md。
- Quality gate: 颜色一致优先，不能承诺像素级保线。

### Case 2: 角色新增道具

- Input: 第 4 张线稿新增雨伞。
- Recommended path: 沿用已有角色颜色，为雨伞新增语义色并记录反面约束。
- Artifacts: color-bible.md、best-refs.md。
- Quality gate: 新增颜色与角色主色区分，避免跨图混淆。

### Case 3: 线稿退化回归

- Input: 修正颜色后线条比前一版变形。
- Recommended path: 拒收修正版，回退颜色次优但线稿更稳的版本，标 needs_img2img。
- Artifacts: verification.md、consistency-report.md。
- Quality gate: 回归守卫优先于继续重绘。
