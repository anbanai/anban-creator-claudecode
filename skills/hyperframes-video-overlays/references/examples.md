# hyperframes-video-overlays Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: App 操作指针动效

- Input: video-use 需要在 3 秒内展示按钮点击路径。
- Recommended path: 用 HTML/CSS/JS 做透明 WebM，输出 overlays[] 时间窗。
- Artifacts: edit/animations/slot_01/render.webm、manifest.json。
- Quality gate: 尺寸/fps/时长与 EDL 一致，字幕安全区空出。

### Case 2: 产品卖点卡片

- Input: 口播提到“48 小时保温”时弹出卡片。
- Recommended path: 用浏览器排版生成 kinetic card，manifest 记录字体和 timing。
- Artifacts: render.webm、manifest.json。
- Quality gate: 文字移动不遮挡产品主体。

### Case 3: Alpha 不可用降级

- Input: HyperFrames 输出不支持 alpha webm。
- Recommended path: 改出 PNG sequence，并在 manifest 说明 fallback。
- Artifacts: frames/、manifest.json。
- Quality gate: video-use 能据 manifest 继续合成。
