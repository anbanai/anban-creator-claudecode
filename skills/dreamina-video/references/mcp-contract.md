# MCP Contract

Agents must use MCP tools for video generation. API keys and raw provider calls stay on the server.

## register_video_reference

Use for uploading or validating references before planning.

Input:
- `project_id`
- `type`: `text`, `image_url`, `audio_url`, `video_url`
- `url`: required for media references
- `file_path`: optional server-local media path; MCP uploads it to storage and returns `ark_url`
- `text`: required for text references

Media URLs must be public HTTPS URLs. Localhost, private IPs, relative storage URLs, and local filesystem paths are not Ark-accessible. If storage is local or has no public HTTPS CDN/OSS URL, the tool returns an explicit OSS/CDN hint instead of submitting an unusable reference.

## build_video_generation_plan

Use before submitting. It validates the request and returns:
- `generation_plan`
- `sdk_payload_preview`
- required artifact names, including `reference-anchors.md`, `script.md`, `shot-plan.md`, `generation-plan.json`, `quality-review.md`

Important inputs:
- `project_id`
- `prompt`
- `purpose`: `planting`, `ecommerce`, `lead_gen`, `promotion`
- `references`: array of reference objects
- `duration`: seconds
- `ratio`: usually `9:16`
- `resolution`: usually `1080p`
- `model`
- `seed`
- `camera_fixed`
- `watermark`
- `service_tier`
- `task_id`

## create_video_generation_task

Use only after artifacts and plan are written. The server:
- deducts credits when applicable
- calls Volcengine Ark `CreateContentGenerationTask`
- returns `video_task_id`, model, ratio, resolution, duration, seed

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

Save terminal response to `video-task-result.json`.

## download_video_generation_result

Use after `succeeded`. Input:
- `project_id`
- `video_url`
- `output_path`
- optional `task_id`
- optional `file_name`

If `task_id` is provided, the server registers the downloaded MP4 as a task file.
