---
name: hyperframes-video-overlays
description: Use when video-use needs agent-authored HTML/CSS/JavaScript motion graphics, kinetic typography, UI motion, product callouts, or animated cards rendered with HyperFrames for a video overlay.
---

# HyperFrames Video Overlays

Use this skill only as a child workflow of `video-use`. It creates transparent motion overlay assets that `video-use` composites later.

## Contract

- Work under `edit/animations/slot_<id>/`.
- Output `edit/animations/slot_<id>/render.webm` with alpha whenever possible.
- If alpha WebM is unavailable, output a PNG sequence plus `manifest.json` and note the fallback.
- Do not edit source footage or final videos directly.
- Return an `edl.json` `overlays[]` item with `file`, `start`, `end`, `x`, and `y`.

```json
{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0}
```

## Use For

- UI motion, app screens, pointer/cursor motion, animated captions, product callout cards.
- Short kinetic typography with CSS/JS timing.
- HTML layouts that need browser-quality typography.

## Workflow

1. Create `edit/animations/slot_<id>/`.
2. Build the HyperFrames project or HTML entry there.
3. Match the main video dimensions, frame rate, duration, and safe zones.
4. Render transparent WebM as `render.webm` using HyperFrames output settings such as `--format webm` when available.
5. Verify alpha, dimensions, duration, and first/last frames before handing back to `video-use`.

## Rules

- Keep text concise and readable on mobile.
- Use Source Han Sans / 思源黑体 or a documented fallback for Chinese text.
- Leave subtitle safe zones clear; `video-use` applies subtitles LAST.
- Write timing assumptions into `manifest.json`.
