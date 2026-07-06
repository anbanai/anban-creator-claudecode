---
name: remotion-video-overlays
description: Use when video-use needs React/Remotion-based parameterized motion graphics, reusable video templates, data-driven animated cards, or component-based overlays.
---

# Remotion Video Overlays

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


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
