---
name: manim-video-overlays
description: Use when video-use needs precise explanatory animation, diagrams, formulas, graph motion, process visualization, or educational overlays rendered with Manim.
---

# Manim Video Overlays

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


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
