---
name: dreamina-video
description: Use when generating commercial short videos with 即梦, Dreamina, Seedance, Seedance 视频生成, 种草视频, 带货视频, 获客视频, 推广视频, 图生视频, 多模态视频, or when a user provides image/audio/video references and asks for a stable marketing video.
---

# 即梦 / Seedance 商业视频生成

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


Use this skill to turn references and a business goal into a stable short-video generation workflow. Creative judgment stays in the agent; provider calls, API keys, parameter validation, task status, downloads, storage, credits, and logs stay in MCP/server tools.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `get_project_profile` | Read the resolved project runtime profile, `agent_brief`, and `video` block before planning. |
| `register_video_reference` | Upload or normalize a text/image/audio/video reference into an OSS-backed, Ark-accessible URL. |
| `analyze_video_reference` | Understand an input video through the configured native video-understanding route before planning; returns `video-understanding.json`, token usage, charged credits, and visual/action/expression/scene/camera/rhythm/consistency anchors. |
| `validate_video_generation_params` | Preflight model/ratio/resolution/duration/references and return estimated dynamic credits. |
| `build_video_generation_plan` | Validate parameters and produce `generation-plan.json` plus SDK payload preview and estimated credits. |
| `create_video_generation_job` | Submit one target-duration job; the server splits legal provider segments, deducts total credits once, and records segment state. |
| `query_video_generation_job` | Poll aggregate job and segment statuses, provider URLs, and errors. |
| `download_video_generation_results` | Download succeeded segment URLs, upload MP4 files to OSS, and register segment task files. |
| `compose_video_segments` | Register the locally ffmpeg-composed `final.mp4` as the job `final_video` task file. |
| `validate_video_delivery` | Verify the job has a registered `final_video` before final feedback. |

Never call Volcengine/Dreamina HTTP APIs directly, never handle API keys, never use fixed global model/credit defaults, and never use the 即梦 CLI or local `anban` bin as the main video-generation execution path. Agents must use MCP tools. Do not treat external @-style labels as the server execution protocol; translate them into `reference_role` plus MCP `references`.

## Workflow

1. Work inside the existing project/plan/task flow. A video generation job is a `video` task, not a separate product line.
2. Call `get_project_profile(project_id, task_id)` first. Use only the returned `resolved_profile`, `agent_brief`, and `video` block; do not hardcode model IDs, default resolution, duration, watermark, or fixed credits.
   - The only valid model keys are keys present in `video.model_catalog` and allowed by `video.policy.allowed_models`.
   - If a task/plan/history mentions a model key that is not in the returned catalog, stop with “模型未配置或不可用” instead of guessing a replacement.
   - Never persist, display, or call an unconfigured model key.
3. Prepare the workspace with `prepare_workspace(content_type="video", task_id=...)` when available. Local files are temporary Claude workspace artifacts only; anything persistent must become an OSS-backed task file through MCP/server tools.
4. Read the relevant references:
   - Business structure: `references/methodology.md`
   - Consistency/retry rules: `references/stability.md`
   - Artifact and prompt templates: `references/prompt-templates.md`
   - MCP contract details: `references/mcp-contract.md`
5. Run the 完整视频创作流程. Video generation is only the tool call; the core work is stable content creation:
   - Clarify content strategy: `creative_type` (`personal_ip`, `high_efficiency_joke`, `product_demo`, `brand_promo`, `custom`) and business purpose (`planting`, `ecommerce`, `lead_gen`, `promotion`).
   - Lock user intent: audience, subject/person/product, single message, proof, CTA strength, platform tone, 主体一致性, and must-not-change constraints.
   - Write `creative-brief.md` before any prompt: one audience, one subject, one message, one desired emotional/behavioral outcome, and one 黄金三秒 hook.
   - For 个人 IP: default to `purpose=planting` unless the goal is consultation/private traffic, then use `lead_gen`. Preserve the creator's identity, outfit family, speaking energy, values, and repeatable catchphrases.
   - For 高效段子: default to `purpose=promotion`; use `planting` for soft recommendation and `ecommerce` for direct selling. Build the joke from setup → misunderstanding/pressure → reversal → payoff → light CTA.
6. Collect inputs: references for people/objects/scenes, business purpose (`planting`, `ecommerce`, `lead_gen`, `promotion`), content type, target deliverable duration, ratio, resolution, configured model key, seed/camera preferences. Missing ratio/model/resolution values come from project video profile, but 目标成片时长 must be outcome-led:
   - First use an explicit user-requested duration.
   - If absent and a registered video reference has server-measured `input_duration_seconds`, use that 参考视频时长 as the target.
   - Only use project `duration` as a fallback when neither the user nor references imply duration.
   - Never treat a provider/model 15s limit as the final deliverable duration.
7. Read task/plan `video_config` before asking for new parameters. If `video_config.references` exists, treat it as user-approved input:
   - Preserve each `type`, `url`, `text`, `reference_role`, filename/mime metadata, and server-measured `input_duration_seconds`.
   - Register or normalize each reference before calling build/create.
   - Plan-triggered tasks reuse the plan's saved references unless the user explicitly changes the plan.
8. Register every non-text reference with `register_video_reference`. Prefer `task_file_id` or upload through the platform; for video input, use the returned reference with server-measured `input_duration_seconds` and never hand-write a raw `video_url` into plan/create. Raw provider URLs are intermediate only and must not be the main delivery link.
9. For every video reference, call `analyze_video_reference` after registration and save/consume `video-understanding.json`.
   - Require `analysis_mode=native_video`, where the configured large model understands the whole OSS video directly through `model_routes.video_understanding`.
   - If native video understanding fails, stop and report the configuration/provider error. Do not degrade to screenshots, frame sampling, transcript-only analysis, or image understanding.
   - Treat returned `usage` and `credits_charged` as billing evidence; missing usage is a server-side error for understanding routes.
   - The analysis must cover frame content, character identity, facial expressions, body actions, scene, camera movement, editing rhythm, and what must not drift. Do not rely only on ASR, transcript, or marketing copy.
10. Write `reference-anchors.md`: first declare `reference_role` for every reference, then separate each reference into must-keep, can-change, and must-not-change anchors. Subject consistency is mandatory: `subject_profile` and every `reference_role=subject identity` source must appear in all shots where the subject appears.
11. Write `script.md`: structure beats against the 目标成片时长. For long-form references, preserve the reference rhythm and compress only when the user asks for a shorter result. Do not submit raw marketing copy as a video prompt.
12. Write `shot-plan.md`: plan one or more 单次生成片段 according to the selected model's max duration. Each segment needs subject, action, scene, camera movement, visual focus, negative constraints, and its segment time range.
13. Build the final prompt using global anchors + shot instructions + negative constraints. Keep one intent per shot.
14. Call `validate_video_generation_params` or `build_video_generation_plan`; save the result to `generation-plan.json`, including estimated dynamic credits and pricing breakdown. Show/record the estimate before submission. The server enforces the 100000-credit minimum balance gate for video task/plan creation and trigger; do not create a workaround.
15. If the 目标成片时长 is longer than the allowed 单次生成片段 duration, split into consecutive segments and call `create_video_generation_job` once; the server uses `generation_plan.segments` to submit all legal provider-bounded segments. Save all submissions to `video-task-submit.json` with segment indexes.
16. Poll the aggregate job with `query_video_generation_job`; save terminal responses to `video-task-result.json`.
17. On success, call `download_video_generation_results` with `task_id` for every generated segment so each MP4 is uploaded to OSS and registered as a task file. For multi-segment jobs, assemble `output/final.mp4` with ffmpeg, call `compose_video_segments`, then call `validate_video_delivery`. Segment-only delivery is not complete.
18. Write `quality-review.md` before deciding whether to retry. Score subject consistency, product/scene fidelity, business goal fit, motion clarity, target duration fit, and CTA fit.
19. When submitting feedback, always use `agent_name="videocreator"`; `dreamina-video` is the selected skill/workflow, not the executing agent identity.

## Required Artifacts

- `creative-brief.md`: content type, business purpose, audience, subject/person/product, single message, proof, CTA, emotional target, and constraints.
- `video-understanding.json`: output from `analyze_video_reference`; cite it in anchors and shot planning.
- `reference-anchors.md`: must-keep / can-change / must-not-change anchors for person, product, scene, rhythm, and camera.
- `script.md`: time-coded hook, proof/experience, reinforcement, CTA.
- `shot-plan.md`: time-coded shots with subject, action, scene, camera, focus, audio, and negative constraints.
- `generation-plan.json`, `video-task-submit.json`, `video-task-result.json`, `quality-review.md`, `iteration-log.md`.

## Practical Examples

### 个人 IP 种草

Input: "30 岁效率博主，黑色衬衫，讲一个会议记录方法；参考视频是她的口播节奏。"
Understanding summary: medium close-up, direct eye contact, fast but friendly rhythm, small hand gestures, office desk background.
Script: 0-3s pain hook "会议开完还是没人行动？"; 3-10s show note-to-action method; 10-13s result checklist; 13-15s soft CTA "先收藏，下次开会照着用。"
Shot plan: keep same creator identity and outfit family in every shot; use fixed medium shot plus one hand close-up; no hard-sell price language.
Final prompt: "Generate a 15s vertical personal-IP planting video... keep the same 30-year-old efficiency creator identity, black shirt, friendly fast delivery, office background..."

### 高效段子

Input: "做一个关于老板临时加需求的高效段子，最后带出 AI 工作流。"
Understanding summary: no strict identity reference; tone should be quick setup and reversal.
Script: setup "老板说只是小改"; pressure "五分钟后变成重做"; reversal "我打开模板三步出方案"; payoff "小改不可怕，可怕是没有流程"; CTA light.
Shot plan: 3-4 shots, one reaction close-up, one screen/workflow proof, one punchline frame; keep action simple.
Final prompt: "Generate a fast-paced 12s joke-style promotion video... setup, escalation, reversal, payoff..."

### 产品演示

Input: "展示保温杯不漏水，参考图锁产品外观。"
Understanding summary: product silhouette and material are the anchor.
Script: hook spill anxiety; proof shake/invert; close-up seal; CTA.
Shot plan: product appears in every shot with same color/material; one hand action per shot; no invented logo or shape drift.
Final prompt: "Keep product silhouette, color, lid structure, and material identical..."

### 参考视频复刻

Input: "照这个参考视频的节奏和运镜，但换成我的人物和主题。"
Understanding summary: camera starts static, cuts on beat, push-in at payoff, warm indoor lighting.
Script: preserve timing structure, not literal content.
Shot plan: copy rhythm/camera roles from `video-understanding.json`; replace subject/message only; must-not-change beat timing and camera energy.
Final prompt: "Use the reference video's rhythm and camera movement as pacing guidance; do not copy its people or product unless specified..."

## Retry Rules

- Subject drift: strengthen `reference-anchors.md`; reduce shot count.
- Product shape/color drift: move product descriptors into every product shot; avoid metaphorical phrasing.
- Action chaos: simplify action verbs; one action per shot.
- Scene jumping: repeat scene anchors and set `camera_fixed` when appropriate.
- Too ad-like for planting: soften CTA and rewrite script as first-person experience.
- Weak conversion for ecommerce/lead gen: make benefit and CTA more explicit, but keep claims compliant.
- Unsupported model/parameter combo: only use server-returned validation errors or `suggested_params`; do not invent a downgrade outside the project policy.

Record every retry in `iteration-log.md` with changed fields, reason, and result.
