---
name: manim-video-overlays
description: Use when video-use needs precise explanatory animation, diagrams, formulas, graph motion, process visualization, or educational overlays rendered with Manim.
---

# Manim Video Overlays

Use this skill only as a child workflow of `video-use`. It renders precise diagrammatic overlays for final composition.

## Contract

- Work under `edit/animations/slot_<id>/`.
- Output `edit/animations/slot_<id>/render.webm` with alpha when possible.
- Use Manim transparent background settings such as `--transparent` or equivalent config when alpha is required.
- Do not edit source footage or final videos directly.
- Return an `edl.json` `overlays[]` item with `file`, `start`, `end`, `x`, and `y`.

```json
{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0}
```

## Use For

- Diagrams, formulas, timelines, charts, arrows, callout paths, structured educational animation.
- Motion that benefits from deterministic geometry and precise timing.

## Workflow

1. Create `edit/animations/slot_<id>/`.
2. Write a focused Manim scene for the requested overlay.
3. Match output dimensions, frame rate, duration, and background transparency.
4. Render to `render.webm` or render frames and encode alpha WebM.
5. Verify alpha, dimensions, duration, legibility, and safe zones.

## Rules

- Keep scenes short and deterministic.
- Use Source Han Sans / 思源黑体 or a documented fallback for Chinese text.
- Leave subtitle safe zones clear; `video-use` applies subtitles LAST.
- Save scene command, timing, and output metadata in `manifest.json`.
