# MCP Contract

## Contents

- [get_project_profile](#getprojectprofile)
- [generate_image for visual anchors](#generateimage-for-visual-anchors)
- [prepare_video_generation_inputs](#preparevideogenerationinputs)
- [register_video_reference](#registervideoreference)
- [analyze_video_reference](#analyzevideoreference)
- [validate_video_generation_params](#validatevideogenerationparams)
- [build_video_generation_plan](#buildvideogenerationplan)
- [create_video_generation_job](#createvideogenerationjob)
- [query_video_generation_job](#queryvideogenerationjob)
- [download_video_generation_results](#downloadvideogenerationresults)
- [compose_video_segments](#composevideosegments)
- [validate_video_delivery](#validatevideodelivery)

Agents must use MCP tools for video generation. API keys and raw provider calls stay on the server.

## get_project_profile

Use this first for every video task.

Input:
- `project_id`
- optional `task_id`

Returns:
- `resolved_profile`: project name, platform, positioning/instructions, keywords, creative constraints, source metadata, and whether a task snapshot is in use
- `agent_brief`: server-formatted project context and video creation constraints that the agent can read directly
- `videocreator.defaults`: resolved purpose, model key, resolution, ratio, duration, watermark, and preflight defaults
- `videocreator.policy`: allowed models, default model, auto-downgrade policy, max resolution, and max duration
- `videocreator.model_catalog`: server-configured and project-allowed video model keys and capabilities
- `videocreator.input`: user-authored `video_creator_input` intake (`brief`, `references`, `hard_constraints`) when `task_id` is supplied
- `videocreator.references`: convenience alias for `videocreator.input.references`
- `videocreator.visual_anchor_generation`: capability hints for generated visual anchors, including `available`, `default_image_type`, `max_auto_anchors`, `verify_with_vision`, `register_tool`, and fallback guidance
- `videocreator.pricing.credits_per_cny`: billing conversion from real CNY model cost to base credits
- `videocreator.pricing.tier_multiplier`: current membership multiplier applied after base cost
- `videocreator.pricing.base_task_fee_rule`: videocreator task/plan creation charges only `credits.task_costs.videocreator` as the base service fee
- `videocreator.pricing.operation_billing_rule`: `create_video_generation_job` and `create_video_generation_task` deduct `video_gen` operation credits independently when the provider job is submitted

Do not hardcode a default model, resolution, duration, watermark, or fixed credit number in the skill. Project profile is the source of truth; plan/task overrides are snapshots and must not rewrite project defaults unless the user explicitly asks to save them.

Model visibility is fail-closed:
- Only keys present in `videocreator.model_catalog` are configured and usable.
- `videocreator.policy.allowed_models`, `videocreator.policy.default_model`, task `video_creator_config.model_key`, and plan `video_creator_config.model_key` are valid only if the key exists in `videocreator.model_catalog`.
- If historical data contains a missing key, report “模型未配置或不可用” and stop. Do not show, save, estimate, trigger, or call the missing model.

## generate_image for visual anchors

Use this only for video-agent visual-anchor bootstrap when the user has not supplied enough image/video references for a stable subject, product, or first frame.

Required input pattern:
- `project_id`
- `task_id`
- `image_type`: `content`
- `size`: normally `3:4`
- `output_path`: `visual-anchors/<role>-anchor-NN.png`
- `verify_with_vision`: `true`
- `verification_prompt`: ask for JSON verification of required visible anchors
- optional `ref_image_path`: required for second and third generated anchors; use the accepted main anchor path

Accept only normalized verification with `passed=true`. If a score exists, it must be at least 0.75. If the tool is unavailable for the deployment, fall back according to `videocreator.visual_anchor_generation.fallback`; do not bypass MCP or call image providers directly.

After an anchor passes, call `register_video_reference` with `type="image_url"`, the returned/generated `file_path`, and the intended `reference_role`. Only registered references should be passed into `build_video_generation_plan` and `create_video_generation_job`.

## prepare_video_generation_inputs

Use this before `validate_video_generation_params`, `build_video_generation_plan`, or `create_video_generation_job` on every Studio video task, and always when `videocreator.input.references` exists.

Input:
- `project_id`
- `task_id`

Returns:
- `video-input-contract.json` as an OSS-backed task file
- normalized `references[]` with inferred `reference_role`
- owned Studio upload URLs materialized under `video-inputs/` with `task_file_id`; pass these `normalized_references` exactly to validate/build/create
- required reference roles, including `full remake reference` and `joke timeline`
- measured video durations and `target_duration_source`
- `inferred_mode`, such as `strict_remake`
- optional `video-understanding.json` when native video analysis is available

Strict remake triggers include `主体不变`, `完全一样`, `同款`, `复刻`, `参考视频`, and `照着这个段子`. In strict remake mode, write `reference-timeline.json` from the native video understanding output before prompt writing, then compile a segment-aware `shot-plan.md`. If the user did not give a target duration and a measured reference video exists, match that reference duration subject to project policy.

Fail closed: every user-supplied image/video from `video_creator_input.references` is a mandatory constraint. If the contract cannot validate a public HTTPS URL, cannot preserve measured video duration, or cannot find the reference in final generation `references[]`, stop. Generated visual anchors can supplement user media but cannot replace it.

## register_video_reference

Use for uploading or validating references before planning.

Input:
- `project_id`
- optional `task_id`
- optional `task_file_id`
- `type`: `text`, `image_url`, `audio_url`, `video_url`
- `url`: required for media references
- `file_path`: optional temporary agent/server-local media path; MCP uploads it to OSS/storage and returns `ark_url`
- `text`: required for text references
- `reference_role`: subject identity, product appearance, scene background, first frame, last frame, action, camera movement, rhythm, voice tone, BGM, or typography
- optional metadata from `video_creator_input.references` / `videocreator.input.references`: `file_name`, `mime_type`, `file_size`, `input_duration_seconds`

Media URLs must be OSS/CDN-backed public HTTPS URLs. Localhost, private IPs, relative storage URLs, and local filesystem paths are not Ark-accessible. If storage is local or has no public HTTPS CDN/OSS URL, the tool returns an explicit OSS/CDN hint instead of submitting an unusable reference. Claude workspace files are temporary; persistent platform files must be registered as task files.

When a task or plan has `video_creator_input.references` (profile `videocreator.input.references`), consume those references first. Preserve `reference_role` and server-measured `input_duration_seconds`; for raw video references, never invent or overwrite duration client-side.

## analyze_video_reference

Use this after `prepare_video_generation_inputs` / `register_video_reference` for every input video before writing `reference-anchors.md`, `reference-timeline.json`, `script.md`, or segment-aware `shot-plan.md`.

Input:
- `project_id`
- optional `task_id`
- optional `task_file_id`
- optional `video_url`
- optional `reference_role`: subject identity, product appearance, scene background, action, camera movement, rhythm, first frame, last frame, voice tone, BGM, or typography
- optional `purpose_hint`: creative/business hint such as `personal_ip`, `high_efficiency_joke`, `planting`, or `ecommerce`
- optional `analysis_prompt`

Returns:
- `analysis_mode`: always `native_video` on success
- `video_understanding.metadata`
- `video_understanding.model`
- `video_understanding.usage`: token counts from the native video-understanding model
- `video_understanding.credits_charged`: final charged credits after tier/user multipliers
- `video_understanding.visual_summary`
- `video_understanding.timeline`
- `video_understanding.subjects`
- `video_understanding.people`
- `video_understanding.expressions`
- `video_understanding.actions`
- `video_understanding.scenes`
- `video_understanding.camera_motion`
- `video_understanding.rhythm`
- `video_understanding.must_keep`
- `video_understanding.can_change`
- `video_understanding.must_not_change`
- `video_understanding.planning_hints`
- `task_file` / `task_file_id` when `task_id` is supplied

The model is not hardcoded by the skill. The server uses `model_routes.video_understanding`, resolved through `model_providers`, with `require_native_video=true` and `require_usage=true`. Deployments may configure a video-capable large model such as Kimi through the OpenAI-compatible SDK path. If the provider cannot understand the whole video natively, the tool fails immediately. Never fall back to frame sampling, screenshot analysis, image understanding, transcript/audio-only analysis, or marketing copy when a visual reference video exists.

Save or read the registered `video-understanding.json`. It is a planning source of truth:
- `reference-anchors.md` must cite must_keep / can_change / must_not_change
- `script.md` must use rhythm and creative function, not merely copied text
- `shot-plan.md` must use visual, action, expression, scene, and camera facts
- `quality-review.md` must check the generated result against these anchors

## validate_video_generation_params

Use before create, and usually before writing the final submission note.

Returns:
- `valid`
- `resolved_params`
- `estimated_credits`
- `pricing_breakdown`
- validation errors for unsupported resolved model, parameter, or reference combinations

The server estimates credits dynamically from `model_prices.video_generation`, `billing.credits_per_cny`, membership/user multipliers, the server-resolved model key, output resolution, ratio, duration, whether an input video is present, and server-measured input video duration. Real model cost stays separate from billing multipliers. Do not trust agent-supplied input video duration. Video task/plan creation charges only the base task service fee. The actual video provider cost is deducted later as an independent `video_gen` MCP operation when the provider job is submitted. If the balance cannot cover `video_gen` at execution time, stop and ask the user to recharge.

If `video-input-contract.json` says a video reference is required, `pricing_breakdown.input_video` must be true. If it is `input_video=false`, stop; the request has lost the user reference and must not spend credits.

## build_video_generation_plan

Use before submitting. It validates the request and returns:
- `generation_plan`
- `sdk_payload_preview`
- `estimated_credits`
- `pricing_breakdown`
- required artifact names, including `reference-anchors.md`, `script.md`, `shot-plan.md`, `generation-plan.json`, `quality-review.md`

Important inputs:
- `project_id`
- `prompt`
- `purpose`: `planting`, `ecommerce`, `lead_gen`, `promotion`
- `references`: array of reference objects
- `duration`: seconds
- `ratio`: usually `9:16`
- `resolution`: usually `1080p`
- `seed`
- `camera_fixed`
- `watermark`
- `service_tier`
- `task_id`

Do not pass a model key. The server resolves the generation model from task/project configuration. You may read provider/model details from `get_project_profile` or tool responses to adapt reference strategy, but never choose or pass model keys.

The generation plan must include all required `video-input-contract.json` references. Missing user media, unmeasured video duration, private URLs, missing prepared `video-input-contract.json`, or generated-anchor-only substitutions are hard failures. A visual anchor is only allowed as an additional reference after the required user references are present.

## create_video_generation_job

Use only after artifacts and plan are written. The server:
- resolves target deliverable duration and duration source
- splits the job into legal provider-bounded `segments`
- deducts total dynamic credits once, or reuses the existing video task deduction when `task_id` was already charged
- submits one provider job per segment when the target duration exceeds the provider segment cap

If the plan has multiple segments, do not report completion after the first segment. Call `download_video_generation_results` for all succeeded segments, compose the final MP4 locally with ffmpeg, call `compose_video_segments`, and then call `validate_video_delivery`.
- calls Volcengine Ark `CreateContentGenerationTask` once per segment
- records `video_generation_id`, segment provider task IDs, segment duration, and segment credits

Save response to `video-task-submit.json`.

## query_video_generation_job

Poll until all segments reach a terminal status.

Input:
- `project_id`
- `task_id` or `video_generation_id`

Returns:
- `video_generation_id`
- aggregate `status`
- `segments[]` with `index`, `video_task_id`, `status`, provider URLs, duration, task file ID, and error

Provider raw URLs are diagnostic/intermediate fields. They are not the final Studio delivery link.

Save terminal response to `video-task-result.json`.

## download_video_generation_results

Use after segment success. Input:
- `project_id`
- `task_id`
- `video_generation_id`
- `segments[]` with `index` and `video_url` or `file_url`

The server downloads each provider segment URL to a temporary area, uploads each MP4 to OSS, and registers segment task files. A single-segment job is marked as `final_video`; multi-segment jobs are not complete until composed.

## compose_video_segments

Use after all segment files are downloaded and a local ffmpeg composition exists.

Input:
- `project_id`
- `task_id`
- `video_generation_id`
- `file_path`: server/agent-local `final.mp4`
- optional `file_name`

The server uploads the composed MP4 to OSS, registers it as a task file, and stores its ID as `final_video`.

## validate_video_delivery

Use before final feedback.

Input:
- `project_id`
- `task_id`
- optional `video_generation_id`

Returns `valid=true` only when the job has a registered `final_video` task file. Segment-only output is not a completed video generation delivery.
