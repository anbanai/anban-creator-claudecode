---
name: xls-publishing
description: Creates and manages WeChat Xiaolvshu (小绿书) newspic image post drafts with up to 20 images. Use when creating or managing WeChat Xiaolvshu newspic image post drafts. Also use when user mentions '发小绿书', '图片帖发布', 'newspic draft', '小绿书草稿', or when the xls pipeline reaches the draft publishing step.
---

# 微信公众号小绿书发布

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `upload_image` (channel_id, file_path) | 上传图片到微信素材库 |
| `publish_xls_draft` (channel_id, title, content, images) | 创建小绿书草稿 |

---

适用于：纯图片帖子、旅行图集、产品展示，最多 20 张图片。内容为**纯文本**（不支持 HTML）。

## 草稿管理

查看发布历史：调用 `list_drafts` 和 `list_published_articles` MCP 工具。

## publish_xls_draft 参数说明

| 参数 | 说明 | 必填 |
|------|------|------|
| `title` | 帖子标题 | 是 |
| `content` | 纯文本描述 | 否 |
| `images` | 图片列表（文件路径或 media_id，自动上传本地图片） | 是 |
| `open_comment` | 开启评论 | 否 |
| `fans_only` | 仅粉丝可评论（需同时 open_comment） | 否 |

## 响应格式

```json
{
  "success": true,
  "data": {
    "media_id": "draft_media_id_xxx",
    "draft_url": "https://mp.weixin.qq.com/...",
    "count": 3,
    "uploaded_ids": ["media_id_1", "media_id_2", "media_id_3"]
  }
}
```

## 完整工作流

### 直接使用本地图片

1. 调用 `publish_xls_draft`，传入图片文件路径列表，工具会自动上传到微信素材库
2. 可同时传入 `content` 文字描述和评论设置

### AI 生成图片完整工作流

1. 调用 `generate_image` 生成封面图片
2. 逐张调用 `generate_image` 生成内容图片，每张使用独立 prompt
3. 调用 `publish_xls_draft`，传入生成的图片路径，工具会自动上传并创建草稿

## 流水线集成

本 skill 是 xls 流水线的最后一步。前置条件：

| 前置产出 | 来源 | 用途 |
|----------|------|------|
| `$DIR/cover.png` | xls-visual-design skill | 图片列表的第一张（封面） |
| `$DIR/image_01.png` ... | xls-visual-design skill | 图片列表的内容图 |
| `$DIR/tail.png` | xls-visual-design skill | 图片列表的尾图 |
| 帖子标题 | xls pipeline 步骤 3 | 作为 title 参数 |

`publish_xls_draft` 工具会自动上传本地图片到微信素材库（无需先调用 `upload_image`），返回上传后的 media_id 列表。

## 发布前验证

- [ ] 所有图片文件存在且可访问
- [ ] 图片数量 ≤ 20
- [ ] 标题已设置（≤ 32 字符）
- [ ] 描述文案为纯文本（无 HTML 标签）

## 注意事项

- 内容为纯文本（不支持 HTML）
- 最多 20 张图片
- 封面图自动取第一张
- 从 Markdown 提取图片时，自动跳过网络图片（http/https 开头）
- SDK（silenceper）不支持 newspic，需直接调用微信 API

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 图片上传失败 | 文件 >10MB 或格式不支持 | 压缩图片，确保为 JPG/PNG/WebP |
| 草稿创建失败 | 图片数量超过 20 张 | 减少图片数量 |
| 图片顺序错误 | 文件名排序不正确 | 确保按 cover.png → image_01 → ... → tail.png 顺序传入 |

## 参考文档

- 微信API参考：[wechat-api.md](references/wechat-api.md)
