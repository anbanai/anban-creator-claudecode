---
name: content-writing
description: Writes WeChat articles with server-side writer resources, removes AI traces, prepares content for render_template, and checks platform compliance. Use when writing article body content, de-AI rewriting, content quality review, compliance review, or when the article pipeline calls for writing/decontaminating article text.
user-invocable: false
---

# 微信公众号内容写作知识库

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `write_article(project_id, topic, input_type?, article_type?, length?, task_id?)` | 服务端按已解析 writer resource 生成 Markdown 正文 |
| `list_resources(category="writers")` | 发现可用写作风格资源 |
| `get_resource(category="writers", name, include_raw?)` | 读取 writer metadata / 标题公式 / raw YAML |
| `list_resources(category="layouts" / "article_templates")` | 发现排版模块与文章节奏模板 |
| `get_resource(category="layouts" / "article_templates", name, include_raw?)` | 获取模块 schema、模板 rhythm、字段契约 |
| `inspect_article(project_id, markdown, article_image_mode?, layout_plan?, cover_media_id?)` | 发布前只读预检 readiness / blockers / suggested fixes |
| `render_template(project_id, markdown, layout_plan, theme?, task_id?)` | 主路径：按 `visual-rhythm-plan.md` 确定性渲染微信 HTML |
| `convert_markdown(project_id, markdown, theme?, task_id?)` | 兼容旧 server 的降级路径；新流水线不得作为主路径 |

---

## 写作职责边界

content-writing 只负责正文质量，不负责图片生成和最终 HTML slot 规划。

- writer 只决定文字风格、段落节奏、标题公式和语气，不携带视觉/封面风格。
- 视觉风格来自 project/task 的 `visual_style`，文章模板来自 `article_templates`，排版样式来自 `theme`。
- 写作时不插入图片占位符；配图由 `article-visual-design` 生成并回填到 `visual-rhythm-plan.md`。
- HTML 主路径是 `render_template`，由服务端按 layout_plan 和 layout schema 确定性渲染。

## 写作流程

1. 读取 `$DIR/context-brief.md`、`$DIR/02-outline.md` 和项目 profile。
2. 调用 `write_article` 生成 `$DIR/03-article.md`。
3. 使用 `humanizer` skill 就地改写，保存 `$DIR/04-article-final.md`。
4. 执行违禁词和内容质量检查，输出 `$DIR/content-quality-report.md`。
5. 后续由 article 流程调用 `inspect_article` 与 `render_template`。

## 正文质量标准

- 每个 `##` 章节绑定 context-brief 中至少 1 个上下文锚点。
- 每个章节包含具体素材：案例、场景、数据、人物、冲突、比喻或操作细节。
- 前 100 字有清晰钩子，不用“今天给大家分享”式空开场。
- 小标题可扫读，移动端段落短，长短句交替。
- 有可摘出的判断句，但不堆空泛金句。
- 结尾给具体行动或一个好回答的问题，不做违规诱导。

## AI 去痕

使用 `humanizer` skill 执行 draft → audit → final 流程：

- 改写而非删除，保留信息点、段落数量级和作者意图。
- 重点处理意义拔高、三段式套话、AI 高频词、空洞总结、连续排比、过度转折。
- 不调用 MCP、不计费、无强度档位。

## 合规检查

词库详见 [prohibited-words.md](references/prohibited-words.md)。

- 高风险：删除相关内容。
- 中风险：替换为合规近义表达。
- 低风险：替换、弱化或删除。
- 禁止使用谐音字、拼音、特殊符号规避平台规则。

报告格式：

```text
违禁词检查报告：
- [词汇] → 已替换为 [合规表述]（位置：第X段）
- [词汇] → 已删除相关句子（位置：第X段）
共处理 N 处违禁词，内容已达到平台合规标准。
```

## 渲染交接

正文完成后不要直接调用 `convert_markdown`。

正确交接路径：

1. `article-visual-design` 创建/回填 `$DIR/visual-rhythm-plan.md`。
2. 调用 `inspect_article` 检查 layout_plan、图片模式和 draft blockers。
3. 调用 `render_template`，保存 `$DIR/05-article.html`。
4. 把 `slots_rendered` / `render_audit` 写入 `$DIR/final-review.md`。

`convert_markdown` 只用于旧版 server 兼容降级；使用时必须在 final-review 中记录原因。

## 深入参考

- 写作工具参数：[writing-guide.md](references/writing-guide.md)
- 内容合规规则：[content-compliance.md](references/content-compliance.md)
- 违禁词：[prohibited-words.md](references/prohibited-words.md)
