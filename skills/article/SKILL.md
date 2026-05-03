---
name: article
description: 微信公众号图文文章全自动创作。用户提到"写文章"、"写一篇"、"发文章"、"公众号文章"、"推文"时使用此 skill。
---

# /article 微信公众号文章创作命令

## 强制执行声明

**你正在执行微信公众号文章创作任务。你必须使用工具（MCP 工具、Write、Bash、TaskCreate 等）完成完整的创作流水线。**

**禁止直接用文字回答用户的主题问题。** 你不是在回答问题，你是在创作一篇微信公众号文章。如果你直接输出文字回答而没有使用任何工具，说明你理解错了任务。

用户输入 `/article` 后面的内容是创作主题，不是让你回答的问题。

---

## 必须执行的步骤

按顺序执行以下步骤。每一步都必须调用对应的工具，不能跳过。

### Phase 1: 信息收集

### 步骤 1：获取频道信息与工作目录

合并执行以下操作：

- 检查 `$ANBANWRITER_DEFAULT_CHANNEL` 环境变量，非空则直接使用
- 否则调用 `list_channels(platform="article")`，匹配或让用户选择 → `$CHANNEL_ID`
- `get_channel_profile(channel_id="$CHANNEL_ID", scope="article")` → 获取账号定位、受众、写作风格
- `list_drafts(channel_id="$CHANNEL_ID")` 和 `list_published_articles(channel_id="$CHANNEL_ID")` → 已有文章标题
- `prepare_workspace(content_type="articles", task_id=TASK_ID)` → 工作目录路径 `$DIR`
- Bash 执行 `mkdir -p "$DIR"` 创建目录

### 步骤 2：选题研究

使用 `topic-research` skill：
- 结合账号关键词和用户需求搜索热门话题
- 生成文章大纲
- 保存为 `$DIR/01-research.md` 和 `$DIR/02-outline.md`

### Phase 2: 内容创作

### 步骤 3：撰写文章

使用 `content-writing` skill：
- 基于大纲输出 Markdown 格式文章
- **写作时不需要插入配图占位符**（配图由步骤 7 专门处理）
- 保存为 `$DIR/03-article.md`

### 步骤 4：AI 去痕与合规检查

使用 `content-writing` skill：
- 先执行 AI 去痕（`gentle` 模式）
- 再执行违禁词合规检查
- 保存为 `$DIR/04-article-final.md`

### Phase 3: SEO 与视觉

### 步骤 5：SEO 优化

使用 `seo-optimization` skill：
- 优化标题、关键词、摘要
- 将优化后的标题和摘要保存为 `$DIR/seo-result.md`，供步骤 9 使用

### 步骤 6：生成封面图

使用 `article-visual-design` skill：
- 根据 writer YAML 的 `cover_prompt` 模板生成封面
- 调用 `generate_image(image_type="cover", output_path="$DIR/cover.png")`
- 调用 `upload_image(file_path="$DIR/cover.png")` → 获取 `media_id`
- 记录封面视觉风格（writer YAML 的 `cover_style`）→ `$COVER_STYLE`

### 步骤 7：配图设计与生成

使用 `article-visual-design` skill：

- 逐章节分析 `$DIR/04-article-final.md` 的内容
- 为每个 `##` 章节设计配图提示词（必须引用章节中的具体概念、比喻或案例）
- 基于 `$COVER_STYLE` 确定统一的风格前缀
- 对每个章节：调用 `generate_image` 生成 → `upload_image` 上传 → 插入 CDN URL 到文章
- 覆盖写回 `$DIR/04-article-final.md`，保存 `$DIR/images.json`

### Phase 4: 组装发布

### 步骤 8：HTML 转换

使用 `content-writing` skill：
- 转换为 WeChat 兼容 HTML
- 图片链接自动替换为 CDN 链接
- 保存为 `$DIR/05-article.html`

### 步骤 9：草稿发布

使用 `article-publishing` skill：
- 从 `$DIR/seo-result.md` 读取优化后的标题和摘要
- 创建 `draft.json`（title 使用 SEO 优化标题，digest 使用 SEO 优化摘要）
- 发布到草稿箱：`publish_draft $DIR/draft.json`

---

## 质量标准

- 文章至少 3 个二级标题，结构清晰
- 封面图必须成功生成并上传
- **配图与内容关联**：每个配图提示词必须包含对应章节的具体概念
- **图文并茂**：每个 `##` 章节至少一张配图
- 所有配图风格通过 `style_prompt` 保持一致
- 无明显 AI 痕迹，无违禁词
- 草稿使用 SEO 优化后的标题和摘要

---

## 任务追踪要求

流程启动时用 TaskCreate 创建任务列表，每个步骤对应一个任务。开始前 `TaskUpdate status → in_progress`，完成后 `TaskUpdate status → completed`。报告进度示例：`[3/9] 文章撰写完成 → $DIR/03-article.md`
