---
name: dreamina-video
description: Use when generating commercial short videos with 即梦, Dreamina, Seedance, Seedance 视频生成, 种草视频, 带货视频, 获客视频, 推广视频, 图生视频, 多模态视频, or when a user provides image/audio/video references and asks for a stable marketing video.
---

# 即梦 / Seedance 商业视频生成

Use this skill to turn references and a business goal into a stable short-video generation workflow. Creative judgment stays in the agent; provider calls, API keys, parameter validation, task status, downloads, storage, credits, and logs stay in MCP/server tools.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `register_video_reference` | Upload or normalize a text/image/audio/video reference. Use public HTTPS media URLs only. |
| `build_video_generation_plan` | Validate parameters and produce `generation-plan.json` plus SDK payload preview. |
| `create_video_generation_task` | Submit the server-side Ark SDK async task. |
| `query_video_generation_task` | Poll task status and retrieve generated URLs/metadata. |
| `download_video_generation_result` | Download the completed video and register it as a task file. |

Never call Volcengine/Dreamina HTTP APIs directly, never handle API keys, and never use the 即梦 CLI as the main execution path. Agents must use MCP tools. Do not treat external @-style labels as the server execution protocol; translate them into `reference_role` plus MCP `references`.

## Workflow

1. Prepare the workspace with `prepare_workspace(content_type="video", task_id=...)` when available. Use `output/video/<task>` as fallback.
2. Read the relevant references:
   - Business structure: `references/methodology.md`
   - Consistency/retry rules: `references/stability.md`
   - Artifact and prompt templates: `references/prompt-templates.md`
   - MCP contract details: `references/mcp-contract.md`
3. Collect inputs: references for people/objects/scenes, business purpose (`planting`, `ecommerce`, `lead_gen`, `promotion`), duration, ratio, resolution, model, seed/camera preferences.
4. Write `reference-anchors.md`: first declare `reference_role` for every reference, then separate each reference into must-keep, can-change, and must-not-change anchors.
5. Write `script.md`: use the 0-3s / 3-10s / 10-13s / 13-15s commercial structure. Do not submit raw marketing copy as a video prompt.
6. Write `shot-plan.md`: 4-5 shots for 15s by default. Each shot needs subject, action, scene, camera movement, visual focus, and negative constraints.
7. Build the final prompt using global anchors + shot instructions + negative constraints. Keep one intent per shot.
8. Call `build_video_generation_plan` and save the result to `generation-plan.json`. Fix validation issues before submission.
9. Call `create_video_generation_task`; save `video-task-submit.json`.
10. Poll with `query_video_generation_task`; save every terminal response to `video-task-result.json`.
11. On success, call `download_video_generation_result`; save file paths/URLs to `delivery-manifest.json`.
12. Write `quality-review.md` before deciding whether to retry. Score subject consistency, product/scene fidelity, business goal fit, motion clarity, and CTA fit.

## Defaults

- Purpose: `planting` if the user says 种草 or gives no explicit conversion goal.
- Duration: 15 seconds.
- Ratio/resolution: `9:16` and `1080p`.
- 15s shot count: 4-5 shots.
- Keep model, ratio, resolution, duration, seed, `camera_fixed`, and watermark stable across retries unless the failure analysis says otherwise.

## Retry Rules

- Subject drift: strengthen `reference-anchors.md`; reduce shot count.
- Product shape/color drift: move product descriptors into every product shot; avoid metaphorical phrasing.
- Action chaos: simplify action verbs; one action per shot.
- Scene jumping: repeat scene anchors and set `camera_fixed` when appropriate.
- Too ad-like for planting: soften CTA and rewrite script as first-person experience.
- Weak conversion for ecommerce/lead gen: make benefit and CTA more explicit, but keep claims compliant.

Record every retry in `iteration-log.md` with changed fields, reason, and result.
