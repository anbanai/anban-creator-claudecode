---
name: dreamina-video
description: 'Use when older prompts, agents, or users mention Dreamina, 即梦, or dreamina-video and the request should be translated to the canonical seedance-20 video workflow.'
---

# dreamina-video Compatibility Alias

This skill is kept for compatibility with older prompts and agents that mention Dreamina, 即梦, or dreamina-video. The canonical workflow is `seedance-20`.

Use the `seedance-20` skill for all planning, references, MCP contracts, prompt templates, generation, delivery, and QC.

For progressive examples and compatibility cases, read [references/examples.md](references/examples.md) before deciding how to translate an older Dreamina request into the canonical `seedance-20` path.

## 图片比例固定规则

- 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
- 项目/频道默认比例次之。
- 业务默认比例只作兜底。
- 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例。
- 微信文章封面/正文图默认 `16:9`。
- Seednote/XLS/移动信息流默认 `3:4`。

Do not maintain separate Dreamina-only workflow logic here. Do not copy the full workflow into this alias.

When submitting feedback or writing manifests, use `agent_name="video"`. `dreamina-video` and `seedance-20` are skills/workflows, not the unified executing agent identity.

## Reference Map

Load these long references only when the current task needs that detail:
- [references/prompt-templates.md](references/prompt-templates.md) - prompt templates.
- [references/methodology.md](references/methodology.md) - methodology.
- [references/stability.md](references/stability.md) - stability.
- [references/mcp-contract.md](references/mcp-contract.md) - mcp contract.
