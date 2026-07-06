---
name: writers
description: Guidance for adding and using custom writer-style YAML files in Anban Creator.
---

# Custom Writer Styles

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。

Use this skill as the entry point for custom writer YAML guidance. The detailed
schema, examples, lookup order, and troubleshooting notes live in
`README.md` in this directory.

Writer files define writing voice only. They must not carry visual identity or
image style fields; visual style is resolved separately from project/task
configuration.
