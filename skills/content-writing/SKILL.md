---
name: content-writing
description: Writes articles with style guidance, removes AI traces, converts Markdown to WeChat HTML, and checks content compliance. Use when writing articles, removing AI traces, converting Markdown to WeChat HTML, or checking content compliance.
---

# 微信公众号内容写作知识库

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `write_article` | server 端调用 LLM，按写作风格生成文章 |
| `convert_markdown` | server 端调用 LLM 转换 Markdown 为 WeChat HTML |
| `humanize_article` | server 端调用 LLM 去除 AI 痕迹 |

---

## 写作风格

内置风格定义文件位于 `writers/` 目录：

- [dan-koe.yaml](../../writers/dan-koe.yaml) - 简洁有力、直击要点、哲理深度
- [cultural-depth.yaml](../../writers/cultural-depth.yaml) - 文化底蕴、文学修辞、深度思考
- [casual-science.yaml](../../writers/casual-science.yaml) - 通俗易懂、生动有趣、科学严谨

## 质量标准

- **直接性**: 快速切入主题，避免冗长铺垫
- **节奏感**: 句子长短交替，避免单调
- **信任感**: 尊重读者智识，不过度解释
- **真实性**: 听起来像人写的，不像机器生成
- **精准性**: 无冗余内容，每句话都有价值

## 配图说明

配图占位符由 `article-visual-design` skill 在文章定稿后专门设计并插入，写作步骤不需要处理配图。

写作时应确保每个 `##` 章节有足够的实质性内容（具体的案例、比喻、场景描述等），为后续配图设计提供丰富的素材。

## AI 去痕参考

详见 [humanizer.md](references/humanizer.md)

## 写作指南

详见 [writing-guide.md](references/writing-guide.md)

## 平台内容合规

详见 [content-compliance.md](references/content-compliance.md)

## 违禁词合规检查

词库详见 [prohibited-words.md](references/prohibited-words.md)，涵盖微信平台违禁类和广告法违禁类。

**检查流程**：
1. **创作时**：主动规避词库中的高风险词汇，优先使用合规替代表述
2. **完稿后**：对全文执行违禁词扫描，按优先级处理：
   - 高风险（政治敏感/色情/暴力/赌博）：直接删除相关内容
   - 中风险（广告法绝对化用语/虚假承诺/医疗夸大）：用词库中的合规替代词替换
3. **禁止变相使用**：不得通过谐音字、拼音、特殊符号规避检查

**报告格式**（完成检查后输出）：
```
违禁词检查报告：
- [词汇] → 已替换为 [合规表述]（位置：第X段）
- [词汇] → 已删除相关句子（位置：第X段）
共处理 N 处违禁词，内容已达到平台合规标准。
```

## 微信 HTML 规范

- 所有 CSS 必须内联（style 属性）
- 禁止外部资源
- 安全标签：section, p, span, strong, em, h1-h6, ul, ol, li, blockquote, pre, code, table, img, br, hr

## 相关工具

- 风格写作：调用 `write_article` MCP 工具
- Markdown 转微信 HTML：调用 `convert_markdown` MCP 工具
- AI 去痕：调用 `humanize_article` MCP 工具
