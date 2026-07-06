# article-viral-strategy Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show the broader high-star convention of compact trigger guidance plus concrete reusable examples.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing the skill when the user input is ambiguous, when choosing a workflow branch, or when preparing quality checks. Adapt the pattern to the current project profile, task flags, platform constraints, and available MCP tools. Keep generated artifacts file-backed and record any downgrade or risk in the task directory.

### Case 1: 低冲突选题增强

- Input: 初稿标题是“如何做好复盘”。
- Recommended path: 加入具体人群、场景代价和好奇心缺口，重写为可点开的承诺。
- Artifacts: viral-audit.md、title-candidates.md。
- Quality gate: 标题有明确对象/收益/反差，不能只堆情绪词。

### Case 2: 完读率节奏重排

- Input: 正文前三段都是背景介绍。
- Recommended path: 把结论、冲突或反常识提前；每个二级标题下设置问题推进。
- Artifacts: retention-pass.md。
- Quality gate: 开头 3 秒内能回答“为什么现在要读”。

### Case 3: 收藏诱因补强

- Input: 文章是工具清单但缺可执行结构。
- Recommended path: 把步骤、模板、清单整理成可收藏资产，并在结尾给复用场景。
- Artifacts: viral-elements.md、final-review.md。
- Quality gate: 收藏理由来自内容价值，不使用诱导互动话术。
