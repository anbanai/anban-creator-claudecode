# article-visual-design Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 多章节视觉节奏

- Input: 文章有 5 个二级标题，封面与正文图都开启。
- Recommended path: 按 rhythm 模板分配 hero/section_opener/inline_detail/footer，至少 3 种构图。
- Artifacts: visual-rhythm-plan.md、image-plan.md、images.json。
- Quality gate: hero 有且仅有 1 个，正文图必须与章节具体物体/比喻匹配。

### Case 2: 封面作为风格锚点

- Input: cover_and_content 模式已生成 cover.png。
- Recommended path: 正文图使用 cover.png 作风格参考，但每张图独立生成独立上传。
- Artifacts: image-prompts.md、images.json。
- Quality gate: ref 是风格锚点，不是复用封面图；正文 img URL 不能相同。

### Case 3: cover_only 模式

- Input: 任务只要公众号头图。
- Recommended path: 跳过 image-plan.md 和正文插图，把封面审计作为唯一视觉交付。
- Artifacts: cover.png、cover-review.md。
- Quality gate: 不得因正文缺图触发失败。
