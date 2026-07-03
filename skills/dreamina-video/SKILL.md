---
name: dreamina-video
description: Use when generating commercial short videos with 即梦, Dreamina, Seedance, Seedance 视频生成, 种草视频, 带货视频, 获客视频, 推广视频, 图生视频, 多模态视频, or when a user provides image/audio/video references and asks for a stable marketing video.
---

# 即梦 / Seedance 商业视频生成

Use this skill to turn references and a business goal into a stable short-video generation workflow. Creative judgment stays in the agent; provider calls, API keys, parameter validation, task status, downloads, storage, credits, and logs stay in MCP/server tools.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `get_project_video_profile` | Read project video defaults, model policy, model catalog, and credit multiplier before planning. |
| `register_video_reference` | Upload or normalize a text/image/audio/video reference into an OSS-backed, Ark-accessible URL. |
| `validate_video_generation_params` | Preflight model/ratio/resolution/duration/references and return estimated dynamic credits. |
| `build_video_generation_plan` | Validate parameters and produce `generation-plan.json` plus SDK payload preview and estimated credits. |
| `create_video_generation_task` | Submit the server-side Ark SDK async task. |
| `query_video_generation_task` | Poll task status and retrieve generated URLs/metadata. |
| `download_video_generation_result` | Download the completed provider result, upload it to OSS, and register it as a task file. |

Never call Volcengine/Dreamina HTTP APIs directly, never handle API keys, never use fixed global model/credit defaults, and never use the 即梦 CLI or local `anban` bin as the main video-generation execution path. Agents must use MCP tools. Do not treat external @-style labels as the server execution protocol; translate them into `reference_role` plus MCP `references`.

## Workflow

1. Work inside the existing project/plan/task flow. A video generation job is a `video` task, not a separate product line.
2. Call `get_project_video_profile(project_id)` first. Use only the returned project defaults, model policy, model catalog, and `credit_multiplier`; do not hardcode model IDs, default resolution, duration, or fixed credits.
   - The only valid model keys are keys present in the returned `model_catalog` and allowed by the returned project policy.
   - If a task/plan/history mentions a model key that is not in the returned catalog, stop with “模型未配置或不可用” instead of guessing a replacement.
   - Never persist, display, or call an unconfigured model key.
3. Prepare the workspace with `prepare_workspace(content_type="video", task_id=...)` when available. Local files are temporary Claude workspace artifacts only; anything persistent must become an OSS-backed task file through MCP/server tools.
4. Read the relevant references:
   - Business structure: `references/methodology.md`
   - Consistency/retry rules: `references/stability.md`
   - Artifact and prompt templates: `references/prompt-templates.md`
   - MCP contract details: `references/mcp-contract.md`
5. Collect inputs: references for people/objects/scenes, business purpose (`planting`, `ecommerce`, `lead_gen`, `promotion`), duration, ratio, resolution, configured model key, seed/camera preferences. Missing values come from project video profile, not from this skill.
6. Read task/plan `video_config` before asking for new parameters. If `video_config.references` exists, treat it as user-approved input:
   - Preserve each `type`, `url`, `text`, `reference_role`, filename/mime metadata, and server-measured `input_duration_seconds`.
   - Register or normalize each reference before calling build/create.
   - Plan-triggered tasks reuse the plan's saved references unless the user explicitly changes the plan.
7. Register every non-text reference with `register_video_reference`. Prefer `task_file_id` or upload through the platform; for video input, use the returned reference with server-measured `input_duration_seconds` and never hand-write a raw `video_url` into plan/create. Raw provider URLs are intermediate only and must not be the main delivery link.
8. Write `reference-anchors.md`: first declare `reference_role` for every reference, then separate each reference into must-keep, can-change, and must-not-change anchors.
9. Write `script.md`: use the 0-3s / 3-10s / 10-13s / 13-15s commercial structure. Do not submit raw marketing copy as a video prompt.
10. Write `shot-plan.md`: 4-5 shots for 15s by default. Each shot needs subject, action, scene, camera movement, visual focus, and negative constraints.
11. Build the final prompt using global anchors + shot instructions + negative constraints. Keep one intent per shot.
12. Call `validate_video_generation_params` or `build_video_generation_plan`; save the result to `generation-plan.json`, including estimated dynamic credits and pricing breakdown. Show/record the estimate before submission. The server enforces the 100000-credit minimum balance gate for video task/plan creation and trigger; do not create a workaround.
13. Call `create_video_generation_task`; save `video-task-submit.json`.
14. Poll with `query_video_generation_task`; save every terminal response to `video-task-result.json`.
15. On success, call `download_video_generation_result` with `task_id` so the result is uploaded to OSS and registered as a task file. Save returned task file IDs/URLs to `delivery-manifest.json`.
16. Write `quality-review.md` before deciding whether to retry. Score subject consistency, product/scene fidelity, business goal fit, motion clarity, and CTA fit.

## Retry Rules

- Subject drift: strengthen `reference-anchors.md`; reduce shot count.
- Product shape/color drift: move product descriptors into every product shot; avoid metaphorical phrasing.
- Action chaos: simplify action verbs; one action per shot.
- Scene jumping: repeat scene anchors and set `camera_fixed` when appropriate.
- Too ad-like for planting: soften CTA and rewrite script as first-person experience.
- Weak conversion for ecommerce/lead gen: make benefit and CTA more explicit, but keep claims compliant.
- Unsupported model/parameter combo: only use server-returned validation errors or `suggested_params`; do not invent a downgrade outside the project policy.

Record every retry in `iteration-log.md` with changed fields, reason, and result.
