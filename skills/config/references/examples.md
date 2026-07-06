# config Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 查看项目当前配置

- Input: 用户问“这个项目现在用什么风格？”
- Recommended path: 调用 get_project_profile，解释 writer/theme/image provider 和缺失项。
- Artifacts: config-report.md。
- Quality gate: 不要修改任何配置，除非用户明确要求。

### Case 2: 切换写作风格

- Input: 用户要求“换成文化底蕴风格”。
- Recommended path: 确认目标 project_id，更新 writer 相关设置或给出服务器侧配置指引。
- Artifacts: config-change.md。
- Quality gate: writer 只影响文字声音，不承载视觉风格。

### Case 3: 图片服务排查

- Input: 生成图失败，用户怀疑模型配置。
- Recommended path: 读取项目 image provider/model 信息，区分项目默认和任务级覆盖。
- Artifacts: image-config-diagnostic.md。
- Quality gate: 不记录 API key 或供应商密钥。
