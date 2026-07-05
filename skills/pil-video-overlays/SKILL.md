---
name: pil-video-overlays
description: Use when video-use needs deterministic lightweight overlays made from Pillow/PIL images, PNG sequences, simple text cards, counters, progress bars, or reveal frames.
---

# PIL Video Overlays

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


Use this skill only as a child workflow of `video-use`. It creates deterministic PNG-sequence or alpha WebM overlays using Pillow/PIL plus ffmpeg.

## Contract

- Work under `edit/animations/slot_<id>/`.
- Output `edit/animations/slot_<id>/render.webm` with alpha when possible.
- PNG frames should live under `edit/animations/slot_<id>/frames/`.
- Do not edit source footage or final videos directly.
- Return an `edl.json` `overlays[]` item with `file`, `start`, `end`, `x`, and `y`.

```json
{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0}
```

## Use For

- Simple cards, counters, progress bars, badges, step reveals, static diagrams with light motion.
- Lowest-dependency fallback when HyperFrames, Remotion, or Manim are unavailable.

## Workflow

1. Create `edit/animations/slot_<id>/frames/`.
2. Generate RGBA PNG frames with Pillow/PIL at the target dimensions and fps.
3. Encode frames to `render.webm` with alpha using ffmpeg VP8/VP9 settings.
4. Verify alpha, dimensions, duration, frame count, and safe zones.
5. Save generation parameters and frame counts in `manifest.json`.

## Rules

- Use Source Han Sans / 思源黑体 or a documented fallback for Chinese text.
- Keep text large enough for mobile and avoid subtitle safe zones.
- Prefer deterministic frame generation over ad hoc manual edits.
- `video-use` applies subtitles LAST, after this overlay is composited.
