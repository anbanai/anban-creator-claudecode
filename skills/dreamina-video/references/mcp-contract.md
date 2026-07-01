# MCP Contract

Agents must use MCP tools for video generation. API keys and raw provider calls stay on the server.

## get_project_video_profile

Use this first for every video task.

Input:
- `project_id`

Returns:
- `video_defaults`: project defaults for purpose, model key, resolution, ratio, duration, watermark, preflight
- `video_model_policy`: allowed models, default model, auto-downgrade policy, max resolution and max duration
- `model_catalog`: server-supported Seedance model keys and capabilities
- `credit_multiplier`: default `1000`, meaning 1 RMB = 1000 credits unless server config changes it

Do not hardcode a default model, resolution, duration, watermark, or fixed credit number in the skill. Project profile is the source of truth; plan/task overrides are snapshots and must not rewrite project defaults unless the user explicitly asks to save them.

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

Media URLs must be OSS/CDN-backed public HTTPS URLs. Localhost, private IPs, relative storage URLs, and local filesystem paths are not Ark-accessible. If storage is local or has no public HTTPS CDN/OSS URL, the tool returns an explicit OSS/CDN hint instead of submitting an unusable reference. Claude workspace files are temporary; persistent platform files must be registered as task files.

## validate_video_generation_params

Use before create, and usually before writing the final submission note.

Returns:
- `valid`
- `resolved_params`
- `estimated_credits`
- `pricing_breakdown`
- validation errors for unsupported model/parameter/reference combinations

The server estimates credits dynamically from official RMB price tables, `credit_multiplier`, model key, output resolution, ratio, duration, whether an input video is present, and server-measured input video duration. Do not trust agent-supplied input video duration.

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
- `model`: friendly model key from project profile/catalog, not a hardcoded provider fallback
- `seed`
- `camera_fixed`
- `watermark`
- `service_tier`
- `task_id`

## create_video_generation_task

Use only after artifacts and plan are written. The server:
- deducts dynamic credits when applicable, or reuses the existing video task deduction when `task_id` was already charged at task creation
- calls Volcengine Ark `CreateContentGenerationTask`
- returns `video_task_id`, model, ratio, resolution, duration, seed, estimated credits, and pricing breakdown

Save response to `video-task-submit.json`.

## query_video_generation_task

Poll until terminal status.

Returns:
- `video_task_id`
- `status`: `queued`, `running`, `succeeded`, `failed`, `cancelled`
- `video_url`
- `last_frame_url`
- `file_url`
- `model`
- `resolution`
- `ratio`
- `duration`
- `seed`
- `revised_prompt`
- `error`

Provider raw URLs are diagnostic/intermediate fields. They are not the final Studio delivery link.

Save terminal response to `video-task-result.json`.

## download_video_generation_result

Use after `succeeded`. Input:
- `project_id`
- `video_url`
- `task_id`
- optional `file_name`

The server downloads the provider URL to a temporary area, uploads the MP4 to OSS, and registers it as a task file. The delivery manifest should point at the returned task file and platform URL, not a local absolute path or provider raw URL.
