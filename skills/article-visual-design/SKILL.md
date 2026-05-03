---
name: article-visual-design
description: Manages images for WeChat article (公众号图文) content including AI generation, compression, and CDN upload. Use when generating or processing images for WeChat articles.
---

# 公众号图文图片管理

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type, output_path, task_id) | 生成单张图片，返回 download_url 和 file_path |
| `upload_image` (channel_id, file_path) | 上传图片到微信 CDN，返回 CDN URL |
| `download_image` (channel_id, url) | 下载在线图片 |
| `compress_image` (file_path) | 压缩图片 |

---

## 封面图生成

封面图使用 writer YAML 中的 `cover_prompt` 模板。流程：

1. 读取对应的 writer YAML 文件（`writers/{style_name}.yaml`）
2. 将文章内容注入 `{article_content}` 占位符
3. 封面 prompt 会自动分析文章 → 提炼主题 → 设计视觉隐喻 → 输出结构化提示词
4. 调用 `generate_image(image_type="cover", output_path="$DIR/cover.png")` 生成
5. 调用 `upload_image(file_path="$DIR/cover.png")` 上传，获取 `media_id`

**封面视觉风格记录**：从 writer YAML 的 `cover_style` 和 `cover_mood` 字段提取，作为章节配图的风格基准。

---

## 章节配图设计与生成

章节配图设计是独立的分析步骤，在文章定稿后执行。这是确保配图与文章内容关联性的核心环节。

### 为什么要独立分析

写作步骤专注于文字质量，配图需要专门的视觉设计分析：
- 写作 LLM 同时写文章和配图提示词时，提示词通常过于简短和通用
- 独立分析步骤可以充分理解每个章节的上下文和全文脉络
- 可以确保所有配图风格一致且与封面协调

### 设计流程

对文章中每个 `##` 章节，按以下步骤执行：

#### 步骤 1：确定统一风格前缀

基于封面视觉风格（`$COVER_STYLE`），确定适用于所有配图的风格前缀：

格式：`[视觉风格名称], [色调], [构图风格], [技术风格]`

示例映射：
- `cover_style: "Victorian Woodcut / Etching"` → `Victorian woodcut etching style, black and white with cross-hatching, dramatic composition with negative space, editorial illustration`
- `cover_style: "中国水墨画"` → `Chinese ink wash painting style, monochrome with subtle color accents, flowing composition with generous white space, traditional brushwork`

#### 步骤 2：逐章节分析与生成

对每个 `##` 章节执行：

**2a. 提取章节上下文**

- **核心论点**：该章节要传达的关键信息（1句话）
- **情感基调**：理性分析、温暖鼓励、犀利批判、诗意沉思、轻松幽默等
- **具体素材**：章节中使用的案例、比喻、场景描述、引用等

**2b. 设计提示词**

将风格前缀 + 章节分析整合为英文提示词（150-300字符）：

```
[风格前缀] + [具体场景/物体描述] + [视觉隐喻或细节] + [情绪色调和氛围] + [构图指导]
```

要求：
- 优先使用章节中已有的比喻或案例作为视觉主体
- 避免抽象通用描述（如"商务场景"、"科技背景"）
- 不同章节的提示词必须有明显区别

**2c. 生成并上传**

1. 调用 `generate_image`（`channel_id`, `prompt`, `image_type="content"`, `output_path="$DIR/img_N.png"`, `task_id`）
2. 调用 `upload_image`（`channel_id`, `file_path="$DIR/img_N.png"`）→ 获取 CDN URL
3. 将 `![描述](CDN_URL)` 插入到章节关键段落之后（不紧跟 `##` 标题，不在章节末尾）

**示例**（假设章节讨论"拖延的本质是自我保护"，风格为维多利亚版画）：

```
Victorian woodcut etching style, black and white with cross-hatching. A figure standing at the edge of a thick fog, reaching out but hesitating, the fog forming soft protective walls around them. Contemplative and empathetic atmosphere, dramatic composition with negative space, editorial illustration
```

#### 步骤 3：保存结果

- 将含 CDN 图片链接的文章覆盖写回 `$DIR/04-article-final.md`
- 将所有配图信息保存为 `$DIR/images.json`（含 index, prompt, file_path, url）

---

## 技术规范

**微信图片限制**：
- 最大尺寸：10MB（超出会被自动压缩）
- 最大宽度：1920px（保持比例压缩）
- 支持格式：JPG、PNG、GIF、WebP

**公众号常用比例**：
- 正文配图：16:9 或 4:3 横版
- 封面图（公众号封面）：2.35:1（900x383px 标准）
- 正方形配图：1:1

见 [references/image-syntax.md](references/image-syntax.md) 查看完整图片语法参考。
