---
name: pil-video-overlays
description: Use when video-use needs deterministic lightweight overlays made from Pillow/PIL images, PNG sequences, simple text cards, counters, progress bars, or reveal frames.
---

# PIL Video Overlays

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
