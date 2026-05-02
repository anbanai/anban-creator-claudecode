---
name: article-visual-design
description: Manages images for WeChat article (公众号图文) content including AI generation, compression, and CDN upload. Use when generating or processing images for WeChat articles.
---

# 公众号图文图片管理

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type="cover"或"content", output_path) | 生成单张图片 |
| `generate_images_from_markdown` (channel_id, markdown, task_id, style_prompt, upload) | 从 Markdown 批量提取+生成图片，style_prompt 会前置到所有图片提示词中 |
| `upload_image` (channel_id, file_path) | 上传图片到微信素材库 |
| `compress_image` (file_path) | 压缩图片 |

---

## 三种使用场景

1. **封面图生成**：根据 writer YAML 的 `cover_prompt` 模板，分析文章内容后生成封面
2. **章节配图设计与生成**：逐章节分析内容，设计关联性强的配图提示词，批量生成
3. **上传已有图片**：压缩后上传到微信 CDN

---

## 使用方式

通过 MCP 工具调用：

1. **封面图生成**：调用 `generate_image`，指定 `image_type="cover"`，`output_path` 保存本地
2. **章节配图批量生成**：先设计提示词并插入 Markdown，再调用 `generate_images_from_markdown`
3. **上传已有图片**：调用 `upload_image`，传入文件路径
4. **下载在线图片**：调用 `download_image`，传入 URL

---

## 封面图生成

封面图使用 writer YAML 中的 `cover_prompt` 模板。流程：

1. 读取对应的 writer YAML 文件（`writers/{style_name}.yaml`）
2. 将文章内容注入 `{article_content}` 占位符
3. 封面 prompt 会自动分析文章 → 提炼主题 → 设计视觉隐喻 → 输出结构化提示词
4. 调用 `generate_image(image_type="cover", output_path=...)` 生成
5. 调用 `upload_image(file_path=...)` 上传，获取 `media_id`

**封面视觉风格记录**：从 writer YAML 的 `cover_style` 和 `cover_mood` 字段提取，作为章节配图的风格基准。

---

## 章节配图设计与生成

章节配图设计是一个独立的分析步骤，在文章定稿后、批量生成前执行。这是确保配图与文章内容关联性的核心环节。

### 为什么要独立分析

写作步骤专注于文字质量，配图需要专门的视觉设计分析：
- 写作 LLM 同时写文章和配图提示词时，提示词通常过于简短和通用
- 独立分析步骤可以充分理解每个章节的上下文和全文脉络
- 可以确保所有配图风格一致且与封面协调

### 设计流程

对文章中每个 `##` 章节，按以下 5 个子步骤执行：

#### 子步骤 1：提取章节上下文

阅读该章节的完整内容，提取：

- **核心论点**：该章节要传达的关键信息（1句话）
- **情感基调**：理性分析、温暖鼓励、犀利批判、诗意沉思、轻松幽默等
- **具体素材**：章节中使用的案例、比喻、场景描述、引用等
- **全文定位**：该章节在全文中的位置和作用（开头引入/核心论述/案例说明/总结升华等）

#### 子步骤 2：设计视觉表达方案

基于提取的上下文，设计配图内容：

- **具体场景/物体**：从章节内容中提炼一个可视觉化的场景或物体
  - **优先使用章节中已有的比喻或案例**（最高关联性）
  - 其次使用章节讨论的核心概念
  - 避免抽象通用描述（如"商务场景"、"科技背景"）
- **视觉隐喻**：如何将章节的核心论点转化为视觉语言
  - 不是字面翻译，而是通过视觉元素传达论点的精髓
  - 利用空间关系、光影、材质、构图等视觉语言
- **情绪色调**：与章节情感基调匹配的色彩和氛围
  - 温暖鼓励 → 暖色调、柔和光线
  - 理性分析 → 冷色调、清晰结构
  - 犀利批判 → 高对比、强烈明暗
  - 诗意沉思 → 柔和渐变、留白

#### 子步骤 3：撰写提示词并插入文章

将分析整合为英文提示词（150-300字符），按此结构：

```
[具体场景/物体描述] + [视觉隐喻或细节] + [情绪色调和氛围] + [构图指导]
```

**要求**：
- 提示词必须包含章节中提到的具体概念、比喻或案例
- 用英文撰写（图片生成模型对英文提示词理解更好）
- 每个章节至少一个 `![描述](__generate:提示词__)` 占位符
- 放在关键段落之后，不紧跟 `##` 标题，不在章节末尾
- 不同章节的提示词必须有明显区别

**示例**（假设章节讨论"拖延的本质是自我保护"）：

好的提示词：
```
A person standing at the edge of a thick fog, reaching out but hesitating, the fog forming soft protective walls around them, warm golden light filtering through from behind the mist, contemplative and empathetic atmosphere, depth of field with focus on the outstretched hand, editorial illustration style
```

差的提示词（过于通用）：
```
A person thinking deeply, soft lighting, professional business style
```

#### 子步骤 4：确定统一风格前缀

基于封面视觉风格（`$COVER_STYLE`），扩展为适用于所有章节配图的风格前缀：

格式：`[视觉风格名称], [色调], [构图风格], [技术风格]`

示例映射：
- `cover_style: "Victorian Woodcut / Etching"` → `Victorian woodcut etching style, black and white with cross-hatching, dramatic composition with negative space, editorial illustration`
- `cover_style: "中国水墨画"` → `Chinese ink wash painting style, monochrome with subtle color accents, flowing composition with generous white space, traditional brushwork`
- `cover_style: "Friendly illustration"` → `Friendly digital illustration, warm and bright color palette, clean composition with rounded shapes, modern editorial style`

将含配图占位符的文章覆盖写回 `$DIR/04-article-final.md`。

#### 子步骤 5：批量生成

所有章节的提示词插入完成后，调用 `generate_images_from_markdown`：

```
generate_images_from_markdown(
  channel_id=$CHANNEL_ID,
  markdown=<含 __generate:prompt__ 的文章内容>,
  task_id=$TASK_ID,
  style_prompt=<统一风格前缀>,
  upload=true
)
```

`style_prompt` 会被前置到每个图片的提示词前，确保风格一致性。生成结果保存为 `$DIR/images.json`。

---

## 文章内图片语法

在 Markdown 中使用 AI 生成占位符：

```markdown
# 文章标题

正文段落...

![图片描述](__generate:详细的图片生成提示词__){width=100%}

继续正文...
```

`generate_images_from_markdown` 工具提取所有 `__generate:...` 占位符，批量生成图片并替换。

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
