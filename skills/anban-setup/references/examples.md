# anban-setup Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 首次安装后认证预检

- Input: 用户说“第一次使用，帮我初始化”。
- Recommended path: 先检查本地 anban CLI，再用 list_projects 验证 MCP 认证。
- Artifacts: setup-check.md。
- Quality gate: 只报告 ANBAN_API_KEY 是否存在，绝不打印密钥值。

### Case 2: MCP 认证失败诊断

- Input: 任一创作 skill 调 MCP 返回 401/403。
- Recommended path: 切换到 anban-setup，检查密钥存在性、API URL 和默认项目配置。
- Artifacts: diagnostic-report.md。
- Quality gate: 不得绕过 MCP 写自定义 HTTP 客户端。

### Case 3: 本地视频工具缺失

- Input: video-use 需要 anban CLI 但 --help 不可用。
- Recommended path: 运行插件 bootstrap 修复；仍失败则提示重新安装插件或联系支持。
- Artifacts: setup-check.md。
- Quality gate: 不要要求用户手动构建或复制二进制。
