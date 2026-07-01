---
name: remotion-video-overlays
description: Use when video-use needs React/Remotion-based parameterized motion graphics, reusable video templates, data-driven animated cards, or component-based overlays.
---

# Remotion Video Overlays

Use this skill only as a child workflow of `video-use`. It renders Remotion compositions into overlay assets for final ffmpeg composition.

## Contract

- Work under `edit/animations/slot_<id>/`.
- Output `edit/animations/slot_<id>/render.webm` with alpha when possible.
- Prefer transparent PNG frames followed by VP8/VP9 WebM encoding when alpha is required.
- Do not edit source footage or final videos directly.
- Return an `edl.json` `overlays[]` item with `file`, `start`, `end`, `x`, and `y`.

```json
{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0}
```

## Use For

- Reusable React compositions, branded templates, counters, lower thirds, data-driven product cards.
- Animations where props, JSON data, or component reuse matter.

## Workflow

1. Create `edit/animations/slot_<id>/`.
2. Scaffold or reuse a Remotion composition inside that slot.
3. Set width, height, fps, and duration to match the EDL window.
4. Render with alpha-safe settings. If direct alpha video is unreliable, render PNG frames and encode `render.webm` with alpha.
5. Verify alpha, dimensions, duration, and visual safe zones.

## Rules

- Keep dependencies local to the slot or clearly documented.
- Use Source Han Sans / 思源黑体 or a documented fallback for Chinese text.
- Leave subtitle safe zones clear; `video-use` applies subtitles LAST.
- Save props/data and timing notes in `manifest.json`.
