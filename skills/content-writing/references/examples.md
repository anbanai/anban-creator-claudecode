# content-writing Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 专家口吻改写

- Input: 账号 writer 是行业专家，研究大纲偏口语。
- Recommended path: 先写清晰论点，再按 writer 资源调整句式、例证密度和署名语气。
- Artifacts: 03-article.md、writer-notes.md。
- Quality gate: 每节有案例/场景/数据之一，不空泛喊口号。

### Case 2: AI 去痕

- Input: 初稿出现“总之/值得注意的是/在当今时代”等模板句。
- Recommended path: 调用 humanizer 思路做句式拆散、具体化和人类叙述痕迹恢复。
- Artifacts: 04-article-final.md、humanize-report.md。
- Quality gate: 保留原论点，不为了“像人”改掉事实。

### Case 3: 合规收敛

- Input: 文中有绝对化营销词。
- Recommended path: 按 prohibited-words 和 content-compliance 替换为可验证描述。
- Artifacts: compliance-report.md。
- Quality gate: 高风险词清零，替换后语义仍自然。
