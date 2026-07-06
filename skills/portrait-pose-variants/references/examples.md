# portrait-pose-variants Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 职场头像表情组

- Input: 一张女性正面照，要 4 个封面表情。
- Recommended path: 先写 identity-lock，再生成微笑/思考/惊讶/自信四种 9:16 变体。
- Artifacts: identity-lock.md、pose-plan.md、variant_01.png..04.png。
- Quality gate: 五官、发型、年龄感一致；姿态变化不能换人。

### Case 2: 手势变化封面

- Input: 同一讲师需要指向标题区、抱臂、拿平板。
- Recommended path: 为每个手势写负面约束，避免多手指和道具穿帮。
- Artifacts: pose-prompts.md、audit.md。
- Quality gate: 手部异常触发重生成或人工复核。

### Case 3: 风格参考强一致

- Input: 用户要求保持原照片服装和背景调性。
- Recommended path: 只改变表情/姿态，背景与服饰作为身份线索保留。
- Artifacts: consistency-audit.md。
- Quality gate: 不能把职业照变成写真或卡通。
