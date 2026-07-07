---
name: seednote-visual-design
description: Generates cover (封面), content pages (内容图), and tail pages (尾图) for Seednote (种草笔记) posts with 3:4 ratio design norms. Use when creating seednote visual content including covers, content pages, and tail pages. Also use when user mentions '种草笔记图片', '封面生成', '内容图', '尾图', '图片规划', or when the seednote pipeline calls for image generation.
---

# 种草笔记图片生成

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


## 硬性纪律（违反视为流程失败，会被 SubagentStop 机械闸门拦截）

- **禁止跳过 image-plan.md 直接调 generate_image**
- **禁止 prompt 中省略「必须出现文字」字段**（封面是主文案，内容图是 2-4 条短句，尾图是 1-2 条文案）
- **每次调用 generate_image 后必须把实际 prompt + provider + model + revised_prompt 追加到 `$DIR/image-prompts.md`**
- **最后必须跑 Step 6 质量验证，写入 `$DIR/image-review.md`**
- **图片内所有可见文字必须是简体中文**（用户使用中文时），禁止英文/拼音/乱码/伪词
- **prompt 中文字必须用全角引号「」或书名号《》包裹**，让模型识别为"文字内容"而非视觉描述

> **AIGC 标识提醒（2026 强制，非机械闸门、属合规义务）**：本 skill 产出的封面 / 内容图 / 尾图均由 `generate_image` 生成，属 AI 生成合成内容——发布方须按平台规则声明 AI 生成（未标识→限流/封号）。在 Step 6 的 `image-review.md` 末尾标注「图片均为 AI 生成，建议发布时声明」，与 seednote-writing §9.5 的标识建议联动。

---

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (project_id, prompt, image_type, output_path, task_id, ref_image_path) | 生成单张图片。**`task_id=$TASK_ID` 必传**：服务端据此在「生成即落盘」的同一调用里把图片登记为 task_file，`list_task_files` 立即可见（漏传则任务运行中 `list_task_files` 返回 0，图片要等任务结束才被补登记） |
| `upload_image` (project_id, file_path) | 上传图片到微信素材库 |

---

## Guizang Social Card 路由

当任务 prompt 或项目/任务 `visual_style` 包含 `归藏`、`Guizang`、`social card`、`小红书组图`、`Swiss`、`瑞士`、`杂志`、`editorial card` 时，使用 `guizang-social-card` skill 生成原创 HTML/CSS + Playwright 渲染卡片，而不是本 skill 的默认 `generate_image` 路径。仍必须遵守 `seednote_image_mode`：按模式产出 `cover.png`、`image_01.png`...、可选 `tail.png`，并写 `image-plan.md` / `image-review.md`。

渲染 PNG 必须逐张调用 `register_rendered_image` 登记为 task_file；不要绕过 MCP，不要自写 HTTP 上传客户端。图文笔记默认不上传微信 CDN，除非上游项目明确需要发布侧 CDN。

---

## 平台 Gotcha

种草笔记图片是 **3:4 竖版**，强视觉驱动。封面决定点击率，内容图决定完读率，尾图决定互动率。三类图片目标不同，prompt 构建方式也不同。

---

## 视觉风格设计原则

风格无固定预设，每次根据账号定位和内容动态设计：

**三个维度定调**：
1. **账号定位** — 知识干货型（专业简洁，结构感强）/ 生活美学型（温暖氛围，情绪感强）/ 娱乐趣味型（活泼鲜艳，夸张对比）
2. **内容主题** — 美食/旅行/家居/时尚各有视觉惯例，参考主题的典型配色和构图
3. **目标受众** — 年龄层、消费力影响配色（年轻用户偏饱和鲜艳；成熟用户偏质感低饱和）

**封面与内容图的一致性**：
- 无配置参考图时：封面单独文生图确立基准风格；内容图/尾图各自独立文生图（不传 ref_image_path），通过共享文本风格块（配色/字体/批注/色调）保持调性统一，每张使用 image-plan.md 中独立的视觉主体/场景
- 有配置参考图时：仅当用户明确要求强一致才使用配置参考图；否则仍按文生图 + 独立场景生成，避免参考图把场景钉死导致雷同

**中文内容硬约束**：
- 用户使用中文时，图片内所有可见文字必须使用简体中文；禁止英文翻译、拼音、乱码、伪词和中英混排
- 每张图必须围绕 `content.md` 和 `image-plan.md` 的当页主题，不得把尾图预告、其他季节或无关茶类提前画进内容页
- 健康养生类主题只能表达生活方式建议和传统茶文化语境，禁止承诺治疗、治愈或绝对功效

---

## 封面设计规范

见 [references/cover.md](references/cover.md)

---

## 内容图设计规范

见 [references/content.md](references/content.md)

---

## 尾图设计规范

见 [references/tail.md](references/tail.md)

---

## 图片内容规划流程

调用本技能时，按以下流程完成从内容分析到图片生成的完整链路。**调用方只需提供 content.md，本技能内部完成全部规划与生成。**

### 输入

- `$DIR/content.md`：包含标题、正文、话题标签的完整内容文件
- 账号定位信息（如已知）
- 改写模式信息（如适用：`style-only` / `medium` / `tight`）
- `$DIR/viral-template.json`（仅复刻模式，如适用）：读取 `cover_template`、`do_not_copy`、`recommended_clone_depth`

### 步骤 1：内容分析

读取 `content.md`，提取：
- 核心主题和内容类型（干货/情感/测评/教程/...）
- 全部信息点（具体数据、方法、结论、场景描述）
- 正文总字数和段落数
- 目标受众和内容调性
- 用户锁定字段：若 `content.md` 标明用户指定封面标题、正文或标签，图片文案必须优先使用这些字段

### 步骤 2：信息点提取与分组

将提取的信息点按主题相关性分组，**每组对应一张内容图，组数即内容图张数（上限 3 张）**：
- 每组 2-4 个信息点
- 确保组间不重叠
- 组数参考阈值：信息点 ≤4 → 1 张、5-8 → 2 张、≥9 → 3 张（以可读性为先，宁少勿挤）
- 标记每组的关键词和推荐布局类型（参考 [references/content.md](references/content.md) 的 6 种布局模式）
- 优先级排序：最重要的信息 → 首张内容图

### 步骤 3：图片构成与布局选择

**图片构成严格按结构化运行控制 `seednote_image_mode` 执行**。缺失时按 `cover_content`。四种组合：

| `seednote_image_mode` | 应生成文件 | 总数 |
|---|---|---|
| `cover_only` | cover.png | 1 |
| `cover_content` | cover.png + image_01.png … image_0N.png（1~3 张） | 2~4 |
| `cover_tail` | cover.png + tail.png | 2 |
| `full` | cover.png + image_01.png … image_0N.png（1~3 张）+ tail.png | 3~5 |

> **禁止规则（与上表同等优先级）**：未包含尾图的模式（`cover_only` / `cover_content`）禁止生成 `tail.png`——`image-plan.md` 不得包含 `## tail` 节，步骤 5 不得执行尾图生成，步骤 6 质量验证跳过尾图项，最终产物不含尾图。未包含内容图的模式（`cover_only` / `cover_tail`）禁止生成 `image_0N.png`。

**内容图张数按信息点自适应（1~3 张）**：N 由步骤 2 的信息点分组决定，每张承载 2-4 个信息点，最多 3 张（image_01.png、image_02.png、image_03.png）。布局模式参考 [references/content.md](references/content.md) 的 6 种布局。

**image-plan.md 必须在「计划图片数量」字段写入实际生成的总张数**（1~5），机械闸门按此校验。

### 步骤 4：生成 image-plan.md

按以下模板生成 `$DIR/image-plan.md`：

```markdown
# 图片内容规划

## 总体策略

- 主题方向: {从 content.md 提取的核心主题}
- 内容类型: {干货/情感/测评/教程/...}
- 目标受众: {从 content.md 提取}
- 内容调性: {从 content.md 判断}
- 图片内容定位: {图片要传达什么}
- 计划图片数量: N 张

---

## cover 封面

- 钩子: （≤10 字，从标题提取最吸引人的点）
- 辅助信息: （≤15 字，补充封面信息）
- 必须出现文字: （1-2 行简体中文主文案，优先用用户指定封面标题）
- 视觉主体: （必须能直接看出主题的实物/场景）
- 禁止元素: （英文、错别字、无关品类、医疗功效承诺等）
- 验收标准: （0.5 秒内能读懂主题 + 主体与标题一致）

---

## image_01 [内容] 主题：{第一组信息点主题}

- 信息点1: （8-15 字）
- 信息点2: （8-15 字）
- 推荐布局: {编号清单/对比双栏/步骤流程/标注图解/数据卡片/Q&A 对话}
- 必须出现文字: （2-4 条简体中文短句，必须来自信息点）
- 视觉主体: （当页知识对应的实物/过程/对比对象）
- 禁止元素: （英文、伪词、无关主题、误导性参数）
- 验收标准: （文字准确 + 主体准确 + 与其他页面不重复）

（按步骤 2 分组重复 image_02、最多到 image_03；每组独立填写信息点 / 推荐布局 / 必须出现文字 / 视觉主体）

---

## tail [尾部] 类型：{follow|comment|traffic}（**仅当 `seednote_image_mode` 包含尾图时添加本节；不含尾图则整节省略**）

匹配依据：{根据内容类型自动判断——知识干货→follow, 测评对比→comment, 种草推荐→traffic}
- 内容点: （见 tail.md 规范，根据类型填充）
```

### 步骤 5：图片生成

按 image-plan.md 逐一生成：

1. **封面**：使用 [references/cover.md](references/cover.md) 的 Prompt 模板生成
2. **内容图**：使用 [references/content.md](references/content.md) 的 Prompt 模板逐张生成（1~3 张），每张独立调用 `generate_image`（不传 ref_image_path，纯文生图），传入对应分组的信息点和布局，并在 prompt 中显式写明本页独立场景/视觉主体；通过共享「风格延续：{style}」文本块保持调性统一，多张内容图之间保证视觉多样性（不同实景背景 / 构图角度）
3. **尾图（仅当 `seednote_image_mode` 包含尾图时）**：使用 [references/tail.md](references/tail.md) 的 Prompt 模板单独生成；不含尾图则跳过此步，不调用 generate_image 生成尾图
4. **Prompt 备份**：每次调用 `generate_image` 后，必须把实际 prompt、`image_type`、`size`、`output_path`、`ref_image_path`、返回的 `provider`、`model`、`response_type`、`revised_prompt`、`output_mime` 追加写入 `$DIR/image-prompts.md`

### 步骤 6：质量验证

生成后写入 `$DIR/image-review.md`，逐张打分并给出结论：
- [ ] 文件存在且可访问，真实 MIME 与文件扩展名一致
- [ ] 封面 0.5 秒内能读出主题，主文案与用户指定标题一致
- [ ] 每张图主题相关度 ≥4/5，与 image-plan.md 当页主题一致
- [ ] 图片内文字为简体中文，无英文、拼音、乱码、伪词或错别字
- [ ] 茶类/产品/数字参数准确，不出现误导性内容（例如"10 秒出汤"不得写成"焖泡10秒"）
- [ ] 封面、内容图（、尾图，仅当生成）视觉风格一致，内容图之间有视觉多样性
- [ ] **AIGC 标识提醒（2026 强制）**：图片均为 `generate_image` 生成的 AI 内容，在 `image-review.md` 末尾标注「图片均为 AI 生成，建议发布时声明」（未声明→限流/封号）

任一图片低于 4/5 或命中硬性错误时，使用更具体的 prompt 重试一次，并在 `image-review.md` 记录失败原因、重试 prompt 和最终结果。封面重试后仍不合格时停止并报告，不要继续生成后续图片。重试必须覆盖同一个 output_path（禁止新增 `image_03_v2.png` 之类的候选文件）；归档前检查目录，仅保留 image-plan.md 中列出的 N 张图（cover/image_01..03/tail），删除任何多余候选/旧版文件，避免交付目录残留重复图。

---

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 风格不一致 | 共享风格块描述过弱/被忽略 | 强化「风格延续：{style}」块（明确配色/字体/批注/色调），重申禁用元素 |
| 封面文字渲染错误/缺失 | prompt 文字约束力不够 | 检查 prompt 是否用「」包裹 required_text；缩短到 ≤15 字；明确字号占图宽 12-15% 和位置 |
| 出现英文/拼音/乱码 | 未显式独立禁止 | prompt 末尾追加独立「禁止项」段，明确「禁止任何英文/拼音/乱码/伪词」 |
| 内容图信息点错乱 | 模型把多条短句合并或乱序 | 每条短句单独用「」包裹并编号，明确「按列表顺序，禁止合并/拆分/修改任何字符」 |
| 内容图信息点模糊 | prompt 中信息点描述过于抽象 | 使用 image-plan 中的具体数据/场景作为视觉主体 |
| 尾图与正文调性断裂 | 尾图 prompt 未沿用统一风格 | 尾图沿用共享「风格延续：{style}」块（不传参考图） |
| 茶类识别错误 | 视觉主体不具体 | 明确茶类外观、茶干、花材、茶汤颜色和器具 |

### 复刻模式适配

当提供改写模式和 `$DIR/viral-template.json` 时：
- `style-only`：只参考 `cover_template` 的风格方向、信息层级和色彩倾向，完全重做具体构图
- `medium`：参考源笔记的信息结构重新设计内容图主题，但替换视觉主体、场景和版式
- `tight`：仅在 `recommended_clone_depth=tight` 且 `do_not_copy` 风险低时参考图片张数和各页主题关键词；不得复用源图人物姿势、图标组合、文字框位置或可识别构图。**图片构成仍以 `seednote_image_mode` 为准；若源笔记超过模式允许张数，按信息点优先级合并到该模式允许范围内，并在 image-plan.md 记录合并理由**

无论哪种模式，`do_not_copy` 中列出的元素都必须写入 `image-plan.md` 的风险提示，并在生成 prompt 时显式避开。若模板 `confidence=low` 或视觉证据不足，按 `style-only` 处理。

---

## 图片生成方式

通过 MCP 工具调用。**每次 `generate_image` 都必须传 `task_id=$TASK_ID` 和 `project_id=$PROJECT_ID`**——服务端据此在生成瞬间把图片登记为 task_file，`list_task_files` 随即可见（漏传 `task_id` 会导致任务运行中 `list_task_files` 返回 0，中途可见性丢失；图片要等任务结束才被补登记）。`$TASK_ID`/`$PROJECT_ID` 由 seednote agent 一次解析、全程复用。

1. **生成封面（单张）**：调用 `generate_image`，image_type 设为 `"cover"`
2. **逐张生成内容图（image_01.png 起，张数由信息点分组决定）**：逐张调用 `generate_image`，每张使用 image-plan.md 中对应的信息点构造 prompt（独立场景），不传 ref_image_path（纯文生图）
3. **单独生成尾图（仅当 `seednote_image_mode` 包含尾图时）**：调用 `generate_image`，不传参考图，沿用共享风格块；不含尾图则跳过
4. **带参考图（保持风格一致）**：仅当项目配置了参考图且用户要求强一致时才传 ref_image_path；默认不传
5. **带风格描述**：在 prompt 中加入风格描述（如"手绘感，暖色调，小清新"）

**调用示例（封面，务必带上 task_id）**：

```
generate_image(project_id=$PROJECT_ID, task_id=$TASK_ID, prompt=<封面提示词>, image_type="cover", output_path="$DIR/cover.png")
```

内容图、尾图同理，逐张调用时只替换 `image_type` 与 `output_path`（如 `$DIR/image_01.png`、`$DIR/tail.png`），`task_id=$TASK_ID` 每张都必须带。`$DIR` 由 `prepare_workspace(task_id=$TASK_ID)` 返回，任务模式下为相对路径 `output`，故 output_path 形如 `output/cover.png`，服务端可直接登记为 task_file。

**关键规则**：内容图逐张调用 `generate_image` 生成，每张使用 image-plan.md 中对应的信息点构造独立 prompt（output_path 设为 `image_01.png`、`image_02.png` ...），通过共享「风格延续：{style}」块保持调性统一，每张使用独立场景/视觉主体（禁止与其他内容图复用同一场景，避免雷同）；不使用封面作为参考图。尾图单独生成（`tail.png`，仅含尾图的模式），封面单独生成（`cover.png`）。

### 春季花茶/白茶回归示例

当输入包含"春季｜百花复苏，宜饮花茶/白茶"、"春日饮茶指南"时，`image-plan.md` 至少包含：
- 封面必须出现：`春日饮茶指南`、`花茶+白茶`
- 内容图必须包含：`茉莉花茶`、`白牡丹白茶`、`85-90°C`、`10秒出汤`
- 禁止出现：英文标注、"焖泡10秒"、夏季主题提前出现在封面或内容图、非茶相关主体
