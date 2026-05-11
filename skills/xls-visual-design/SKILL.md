---
name: xls-visual-design
description: Generates cover and content images for WeChat Xiaolvshu (小绿书/图片帖) image posts with 3:4 ratio. Use when creating visual content for WeChat newspic format. Also use when user mentions '小绿书图片', '图片帖配图', 'newspic images', '小绿书封面', or when the xls pipeline calls for image generation.
---

# 小绿书图片生成

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type, output_path, ref_image_path) | 生成单张图片 |
| `upload_image` (channel_id, file_path) | 上传图片到微信素材库 |

---

## 平台 Gotcha

小绿书（微信图片帖）最多 20 张图片，用户通过左右滑动浏览。封面决定点击率，内容图决定完读率，尾图决定互动转化。与小红书相比：微信用户相对成熟，设计感接受度更高，但仍需保持视觉一致性。

---

## 视觉风格设计

风格无固定预设，每次根据账号定位和内容动态设计。

**三个维度定调**：
1. **账号定位** — 知识型（专业简洁）/ 生活型（温暖氛围）/ 娱乐型（活泼鲜艳）
2. **内容主题** — 旅行/美食/好物/知识各有视觉惯例
3. **目标受众** — 影响配色饱和度和设计复杂度

**常见小绿书内容风格参考**：
- 旅行图集：真实感照片风，自然色温，minimal 文字叠层
- 好物测评：产品感，纯净背景，数据对比清晰
- 知识干货：结构感强，信息图式，配色克制
- 日常打卡：生活感，暖色调，随拍质感

---

## 图片内容规划流程

调用本技能时，按以下流程完成从内容分析到图片生成的完整链路。

### 输入

- `$DIR/` 下的选题研究产出（标题、内容页规划）
- 账号定位信息（从 `get_channel_profile` 获取）
- 图片数量（从频道配置或默认值获取）

### 步骤 1：内容分析

从选题研究产出中提取：
- 帖子标题和封面钩子
- 每页的核心信息点（1 页 1 个信息点，3 秒能懂）
- 目标受众和内容调性

### 步骤 2：生成 image-plan.md

按以下模板写入 `$DIR/image-plan.md`：

```markdown
# 图片内容规划

## 总体策略

- 主题方向: {从选题提取}
- 内容调性: {干货/情感/测评/教程/...}
- 视觉风格: {从三维分析确定}
- 色彩基调: {与风格匹配}
- 图片数量: N 张

---

## cover 封面

- 钩子: （≤10 字，从标题提取）
- 视觉主体: {封面的核心画面}

---

## image_01 [内容] 主题：{信息点主题}

- 核心信息: （8-15 字）
- 视觉表达: {如何把信息变成画面}
- 推荐构图: {居中/分栏/步骤/特写/对比/留白}

{重复 image_02 ... image_0{N-2}}

---

## tail [尾部]

- 类型: {follow|comment|traffic}
- 内容: {提炼的记忆点或互动问题}
```

### 步骤 3：图片生成

按 image-plan.md 逐一生成：

1. **封面**（单张）：调用 `generate_image`，image_type 设为 `"cover"`
2. **内容图**（N-2 张）：逐张调用 `generate_image`，每张使用独立 prompt，以封面作为参考图
3. **尾图**（单张）：调用 `generate_image`，传入封面作为参考图

### 参考链

```
封面先生成 → $DIR/cover.png（确立基准风格）
所有内容图和尾图：ref_image_path="$DIR/cover.png"（始终用封面）
```

为什么始终用封面：使用上一张会导致风格漂移（每张图的微小差异累积放大），封面是风格锚点。

---

## Prompt 模板

### 封面 Prompt

```
A 3:4 vertical image for a WeChat newspic cover. {VISUAL_STYLE}.
{COLOR_PALETTE}. {COVER_HOOK} — {VISUAL_SUBJECT}.
Clean layout, text area ≤25%. {COMPOSITION}.
Photographic quality, no watermarks, no logo.
```

### 内容图 Prompt

```
A 3:4 vertical image, style consistent with cover. {VISUAL_STYLE}.
{COLOR_PALETTE}. {PAGE_INFO_POINT} visualized as {VISUAL_EXPRESSION}.
{COMPOSITION_TYPE}. Information-dense but scannable.
Photographic quality, no watermarks, no logo.
```

### 尾图 Prompt

```
A 3:4 vertical image, style consistent with cover. {VISUAL_STYLE}.
{COLOR_PALETTE}. {TAIL_CONTENT} — {TAIL_TYPE_SPECIFIC_GUIDANCE}.
Generous negative space, clean and memorable.
Photographic quality, no watermarks, no logo.
```

### Prompt 构建要点

- 封面：钩子（吸引点击）+ 视觉主体 + 风格描述
- 内容图：每页 1 个信息点 → 转化为具体视觉画面
- 尾图：记忆点提炼 + 互动引导（知识干货→关注提醒，测评→评论区，种草→分享引导）
- 所有 prompt 包含统一的 `{VISUAL_STYLE}` 和 `{COLOR_PALETTE}` 确保一致性

---

## 质量验证

生成完成后检查：

- [ ] 所有图片文件存在且可访问
- [ ] 封面、内容图、尾图视觉风格一致（色调、构图、质感）
- [ ] 内容图之间有视觉多样性（不同背景、构图、焦点位置）
- [ ] 每张内容图信息点与 image-plan.md 一致
- [ ] 封面钩子清晰可读
- [ ] 图片数量符合预期

未通过时：重试对应图片（更换 prompt 措辞），仍失败则记录问题继续。

---

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 风格不一致 | 未使用封面作为参考图 | 确保所有内容图传入 `ref_image_path="$DIR/cover.png"` |
| 文字渲染错误 | 图片生成模型不擅长文字 | 减少图片中文字量，依赖排版而非图片内文字 |
| 构图重复 | 内容图 prompt 过于相似 | 在 prompt 中明确区分构图类型和视觉主体 |
| 封面吸引力不足 | 钩子不明确或视觉主体模糊 | 强化封面 prompt 的视觉隐喻和情绪引导 |

---

## 设计规范

详见 [references/design-norms.md](references/design-norms.md)

---

> 视频合成功能已移至独立 skill：[video-composition](../video-composition/SKILL.md)
