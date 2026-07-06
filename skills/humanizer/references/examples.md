# humanizer Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 模板腔清理

- Input: 文本充满“在这个快速发展的时代”。
- Recommended path: 删除泛化开场，换成具体场景、动作和判断。
- Artifacts: humanized.md、change-notes.md。
- Quality gate: 意思不漂移，只去除统计平均句式。

### Case 2: 过度平滑的段落

- Input: 每段长度相同、连接词机械。
- Recommended path: 制造自然节奏差：短句、插入真实细节、保留少量不对称表达。
- Artifacts: humanized.md。
- Quality gate: 不要故意加入错别字或低质量口语。

### Case 3: 品牌稿降 AI 痕

- Input: 企业稿需要专业但不僵硬。
- Recommended path: 保留术语，减少空泛形容词，用案例和边界替代夸赞。
- Artifacts: humanized.md、risk-report.md。
- Quality gate: 专业可信优先于“像聊天”。
