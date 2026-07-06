# writers Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 新增专家风格

- Input: 用户要“像资深投资人一样写”。
- Recommended path: 按 README schema 新增 writer YAML，只定义声音、结构和禁忌。
- Artifacts: writers/investor.yaml。
- Quality gate: 不得写视觉风格、封面 prompt 或图片字段。

### Case 2: 排查 writer 未生效

- Input: 文章语气没有变化。
- Recommended path: 检查 lookup order、writer key 和项目配置是否一致。
- Artifacts: writer-diagnostic.md。
- Quality gate: 不要把 author 署名和 writer 风格混淆。

### Case 3: 迁移旧风格文件

- Input: 已有 YAML 含 image_style 字段。
- Recommended path: 删除视觉字段，把视觉要求迁移到项目/task visual_style。
- Artifacts: writers/<name>.yaml、migration-notes.md。
- Quality gate: writer 文件只保留写作声音相关字段。
