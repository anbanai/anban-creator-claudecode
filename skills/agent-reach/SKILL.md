---
name: agent-reach
description: Use when Seednote or Xiaohongshu research needs real external note/search data through Agent-Reach, including CLI availability checks, active backend selection, note detail retrieval, xsec_token handling, or unavailable-backend reporting without fabricated data.
compatibility: Requires the Agent-Reach CLI on PATH and a logged-in Xiaohongshu backend when real external data is needed.
---

# Agent-Reach

Use Agent-Reach as the only boundary for external Xiaohongshu data. This skill does not replace Anban MCP tools; use it only for real outside data collection that Seednote research needs.

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。

## Required Flow

1. Run `agent-reach doctor --json` before any external research.
2. Read `xiaohongshu.active_backend` from the doctor output.
3. If Agent-Reach is missing, not logged in, or has no usable Xiaohongshu backend, stop and report the repair hint. Do not invent notes, metrics, comments, URLs, `feed_id`, or `xsec_token`.
4. Use only the command family exposed by the active Agent-Reach backend. Do not call OpenCLI, xiaohongshu-mcp, xhs-cli, browser scrapers, or custom HTTP clients directly unless Agent-Reach selected that backend.
5. Write provenance into research artifacts: `data_source=agent-reach`, `active_backend`, `backend_command_family`, `token_source`, `missing_fields`, and `fallback_reason`.

## Source Notes

- Extract `feed_id` and `xsec_token` only from real URLs or backend results returned by Agent-Reach.
- Never construct `xsec_token` by guesswork or template.
- If a source note cannot be resolved after the Agent-Reach backend's retry path, stop and explain the recoverable step.

## Repair Hint

When the CLI or backend is unavailable, ask the user to install or configure Agent-Reach:

```text
帮我安装 Agent Reach：https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md
```
