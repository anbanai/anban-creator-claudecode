---
name: flower-visual-design
description: Generates flower arrangement image series (花卉图片) with sequential reference chain for visual consistency. Use when creating multi-image flower series with style coherence. Also use when user mentions '花卉图片', '鲜花图片', 'flower images', '花卉系列', or when the flower pipeline calls for batch image generation.
---

# 花卉图片视觉一致性生成

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type="content", output_path, ref_image_path) | 生成花卉图片（单张） |

---

## 核心 Gotcha

花卉图片系列中每张花的 prompt 不同（不同花种），必须逐张生成，可通过参考图（ref）保持风格一致。

---

## 批量生成工作流

### 步骤 1：确定风格

`$STYLE` 需涵盖三个维度：

```
[氛围关键词], [光线描述], [构图原则], 9:16 portrait format
```

示例风格：
- 雨后清新：`post-rain atmosphere, water films on petals, soft diffused light, varied composition, 9:16`
- 晨雾空灵：`morning mist, low fog layers, pollen particles in air, varied negative space, 9:16`
- 黄金时刻：`golden hour backlight, rim-lit petal edges, warm shadows, dynamic composition, 9:16`
- 清新小清新：`pastel tones, soft diffused light, light pink and white bokeh, delicate quality, 9:16`

### 步骤 2：生成首图（无参考图）

首图用完整 `$STYLE` 描述确立基准风格：

```
generate_image(
  channel_id="$CHANNEL_ID",
  prompt="[完整 $STYLE 描述] + [花种特有描述]",
  image_type="content",
  output_path="$DIR/flower_01_[花名].png"
)
```

### 步骤 3：生成后续图片（以首图为参考）

第 2 张起，始终传入首图路径作为 ref：

```
generate_image(
  channel_id="$CHANNEL_ID",
  prompt="[风格描述] + [当前花种特有描述]",
  image_type="content",
  output_path="$DIR/flower_0N_[花名].png",
  ref_image_path="$DIR/flower_01_[花名].png"
)
```

### 步骤 4：质量检查

生成完成后验证：
- [ ] 所有图片文件存在
- [ ] 所有内容图使用首图作为 `ref_image_path`
- [ ] 不同花种之间视觉风格一致（色调、光线、氛围）
- [ ] 同批次构图有多样性（避免所有图片相同构图）

---

## 参考链流程

```
第1张（首图）：不使用参考图，用完整 $STYLE 描述确立基准
    → generate_image → flower_01_[name].png

第2张起：使用第1张作为参考图（ref）
    → generate_image(ref=flower_01) → flower_02_[name].png

第3张及以后：继续使用第1张（基准图）作为参考图
    → 始终用第1张，不用上一张
```

**为什么始终用第1张**：用上一张会导致风格漂移（每张图的微小差异累积放大），第1张是风格锚点。

---

## 命名规范

格式：`flower_序号_花名.png`

示例：
- `flower_01_peony.png` — 牡丹
- `flower_02_rose.png` — 玫瑰
- `flower_03_lavender.png` — 薰衣草
- `flower_04_sunflower.png` — 向日葵

花名使用英文小写，确保文件名在所有系统上可用。

---

## 参数说明

- 在 prompt 中指定 `9:16 portrait format` 竖版比例
- 在 prompt 中包含全局风格描述（色调、光线、氛围），每张保持一致
- ref 参数始终传入第1张图片路径
- output_path 按命名规范设置

---

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 风格漂移 | 未使用首图作为参考图 | 确保所有后续图片传入首图路径 |
| 单张生成失败 | prompt 过于复杂或花种描述冲突 | 简化 prompt，聚焦一种视觉表现 |
| 构图重复 | 所有图片使用相同构图 | 在 prompt 中明确不同构图类型 |
| 色彩不一致 | 首图和后续图片的色调描述不一致 | 确保所有 prompt 包含相同的色彩基调描述 |

---

## 风格一致性元素清单

| 元素 | 统一策略 |
|------|----------|
| 主环境氛围 | 同批次统一（如全部"雨后"、全部"晨雾"） |
| 光线色温 | 统一冷暖倾向 |
| 背景色调 | 统一 bokeh 颜色范围 |
| 景深程度 | 统一虚化程度 |
| 构图比例 | 花朵占 30-60%，留白 40-70% |
| 构图多样性 | 不同图片分配不同构图类型 |

---

完整的 prompt 模板和花卉调研指南见 [flower-content-design](../flower-content-design/SKILL.md)。
