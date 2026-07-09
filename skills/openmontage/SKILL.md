---
name: openmontage
description: Use when handling Anban OpenMontage tasks that convert openmontage-input.json into an OpenMontage adapter manifest, run the upstream OpenMontage pipeline, and register normalized Anban deliverables.
---

# OpenMontage Skill

Use this skill only for Anban `openmontage` tasks.

遇到素材映射、pipeline 选择或交付格式不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。

## Inputs

- `$TASK_ID`
- `$PROJECT_ID`
- `openmontage-input.json`
- project profile from Anban MCP
- configured OpenMontage submodule or runner path

## Required Files

- `openmontage-project.json`: adapter manifest sent to OpenMontage
- `delivery-manifest.json`: normalized Anban delivery manifest
- `final.mp4`: final video when the pipeline succeeds
- `failure-diagnosis.md`: required when the pipeline cannot complete

## Rules

- Keep OpenMontage independent from existing Anban video generation and video editing flows.
- Do not call `create_video_generation_job`, `validate_video_delivery`, Seedance skills, Dreamina skills, or `video-use`.
- Do not expose raw OpenMontage pipeline internals as Anban stable schema.
- Do not modify files under `third_party/OpenMontage`.
- Use Anban MCP tools for project profile, workspace preparation, progress, uploads, task files, and feedback.

## Adapter Manifest

Write `openmontage-project.json` with:

```json
{
  "task_id": "$TASK_ID",
  "project_id": "$PROJECT_ID",
  "brief": "",
  "pipeline_key": "default",
  "assets": [],
  "preferences": {},
  "limits": {},
  "output_dir": "output/openmontage/$TASK_ID"
}
```

The adapter maps this stable manifest into the current upstream OpenMontage project format.
