---
name: guizang-social-card
description: Creates Anban-native rendered social-card visuals for 图文笔记 and 微信公众号, using HTML/CSS plus Playwright screenshots, then registers PNG assets through MCP. Use when visual_style or the task asks for 归藏, Guizang, social card, 小红书组图, Swiss, 瑞士, 杂志, or editorial card.
---

# Guizang Social Card / 归藏社交卡

## 案例库

遇到平台分支、产物命名或 QA 取舍不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。

## 定位与许可

本 skill 是 Anban 原生适配层，灵感来自 `op7418/guizang-social-card-skill`：https://github.com/op7418/guizang-social-card-skill。上游为 AGPL-3.0，并提供商业许可说明；默认实现只引用思路和公开仓库链接，**不直接复制**上游 AGPL-3.0 的模板、脚本、校验器或素材。若未来需要直接 vendoring，必须先取得商业/法务许可并在插件版本中说明。

## 何时启用

保持现有 `generate_image` 流程为默认。仅当任务 prompt 或项目/任务 `visual_style` 包含以下触发词时，切到本 skill：`归藏`、`Guizang`、`social card`、`小红书组图`、`Swiss`、`瑞士`、`杂志`、`editorial card`。触发后仍由上游调用方决定 `seednote_image_mode` / `article_image_mode`，本 skill 不擅自增加关闭的图片产物。

## 平台规格

| 场景 | 输出尺寸 | 产物 |
|---|---:|---|
| 图文笔记 / Seednote | `1080x1440`，3:4 | `cover.png`、`image_01.png` ...、可选 `tail.png` |
| 微信公众号封面大图 | `2100x900`，21:9 | `wechat-21x9-cover.png`，并映射/复制为发布用 `cover.png` |
| 微信公众号分享方图 | `1080x1080`，1:1 | `wechat-1x1-cover.png` |
| 微信公众号封面对照 | 预览组合图 | `wechat-cover-pair-preview.png` |

微信公众号封面上传时使用 21:9 图作为 `thumb_media_id` 来源；1:1 图是分享/审阅辅助产物，除非后续发布接口显式支持，不替代草稿封面。正文卡片若启用，每张卡必须独立注册并取得自己的 `wechat_url`，严禁复用封面 CDN URL。

## 制作流程

1. 读取当前内容文件、账号定位、`visual_style` 和图片模式，写 `$DIR/image-plan.md`。图文笔记按 `seednote_image_mode` 只规划允许的 `cover.png` / `image_01.png`... / `tail.png`；微信公众号按 `article_image_mode` 只规划允许的封面和正文卡。
2. 生成任务目录内的 HTML/CSS 源文件。卡片必须是原创 Anban 版式：可用 editorial / Swiss / magazine 方向，但不要复制上游 HTML、CSS、JS、校验器或资产。
3. 使用 Playwright 截图为 PNG：图文笔记固定 `1080x1440`；微信封面固定 `2100x900` 和 `1080x1080`；正文卡按当前 slot 规格。
4. 做视觉 QA：无溢出、无文字被裁、标题不过长、页脚不撞、字号在移动端可读、主体和文案与内容一致、无二维码/联系方式/外链 URL/扫码提示/加群/加微信等导流元素。
5. 逐张调用 `register_rendered_image(project_id, task_id, name, role, image_base64 或 file_path, upload_to_cdn)` 登记。agent/client-local 图片优先传 `image_base64`；只有 MCP server 能读取的 server-local 文件才传 `file_path`。
6. 写 `$DIR/image-review.md`，记录每张图的尺寸、注册返回的 `task_file_id` / `download_url` / `wechat_url` / `media_id`、QA 结论和需要人工复核的风险。

## MCP 纪律

- 必须使用 `register_rendered_image` 注册 HTML/CSS 渲染出的 PNG；不要绕过 MCP，不要自写 HTTP 上传客户端。
- 微信公众号发布前，所有正文卡都必须有独立 `wechat_url`；封面必须有可用 `media_id`，除非 `article_image_mode` 关闭封面。
- `register_rendered_image(upload_to_cdn=true)` 用于 WeChat 项目时返回 `wechat_url` + `media_id`；用于非 WeChat 项目时至少返回 `task_file_id` + `download_url`。
- 若 `file_path` 是 agent/client-local 路径，改用 `image_base64`；server-local path 必须来自 MCP server 可读位置。

## 产物契约

- 图文笔记：`image-plan.md` 声明实际图片总数；产出 `cover.png`、`image_01.png`...、可选 `tail.png`，并写 `image-review.md`。
- 微信公众号：产出 `wechat-21x9-cover.png`、`wechat-1x1-cover.png`、`wechat-cover-pair-preview.png`；21:9 图映射为 `cover.png` / `thumb_media_id`。正文卡片写入 `images.json`，每条含独立 `wechat_url`。
- 所有 visible text 默认简体中文；标题过长时先短化，不靠缩到不可读解决。
