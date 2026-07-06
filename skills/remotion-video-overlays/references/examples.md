# remotion-video-overlays Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 参数化下三分之一

- Input: 多个受访者需要统一姓名条。
- Recommended path: 用 Remotion props 驱动 reusable component，逐 slot 渲染。
- Artifacts: render.webm、props.json、manifest.json。
- Quality gate: 组件复用但每个 slot timing 独立。

### Case 2: 数据卡片动画

- Input: 视频中要展示三项增长数据。
- Recommended path: 用 React 组件读取 JSON，生成透明数据卡。
- Artifacts: data.json、render.webm。
- Quality gate: 数字可读，不与字幕层冲突。

### Case 3: Alpha 编码回退

- Input: 直接 render video alpha 异常。
- Recommended path: 先输出 PNG frames，再用 ffmpeg VP9 alpha 编码。
- Artifacts: frames/、render.webm。
- Quality gate: 首尾帧、透明通道和时长全部验证。
