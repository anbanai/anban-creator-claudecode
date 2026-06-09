---
name: line-art-coloring
description: Line art coloring skill with cross-image color consistency guarantee. Uses incremental Color Bible building, 2-candidate selection, convergence correction, and backtracking unification. Use when coloring line art images, ensuring same character/object has identical colors across all images. Also use when user mentions "线稿上色", "上色", "填色", "coloring", "color consistency", "批量上色", "角色上色", "给线稿上色".
---

# 线稿上色——跨图颜色一致性保障

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type, output_path, ref_image_path, size, task_id) | 生成单张图片，返回 download_url 和 file_path |
| `upload_image` (channel_id, file_path) | 上传图片 |
| `compress_image` (file_path) | 压缩图片 |
| `download_image` (channel_id, url) | 下载在线图片 |

---

## 核心原则：一致性 > 效率

宁可多花 3 倍算力，也要保证同一实体在所有图中颜色完全一致。

## 核心机制

### 1. 渐进式 Color Bible

Color Bible 不在开始时一次性建完，而是逐图渐进构建：
- 处理第 1 张图时建立初始 Color Bible
- 处理第 N 张图时：匹配已有实体（复用颜色）+ 发现新实体（定义新颜色加入）
- 这避免了全局规划的遗漏问题

颜色定义方法论详见 [references/color-bible.md](references/color-bible.md)。

### 2. 语义颜色锚定

**不用 hex 色值**——AI 模型经常忽略 "#FF5733" 这种写法。

改用三层颜色描述：
- **语义色名**："bright cherry red, like a fire truck"
- **实物类比**："hair like dark chocolate, not milk chocolate"
- **反面约束**："must NOT be blonde or light brown, it must be very dark brown, almost black"

### 3. 多候选生成 + 最优选

每张线稿生成 **2 个候选**上色图：
- 候选 A 和 B 使用不同的 prompt 措辞（描述同一颜色但换说法）
- Read 两个候选 → 逐实体逐部位比对 Color Bible
- 选匹配度最高的作为正式结果
- 如果两个都 < 70% → 生成候选 C

为什么：AI 生成有随机性，2 个候选中至少 1 个颜色正确的概率远高于 1 个。

### 4. Per-Entity Best Reference 追踪

维护映射表 `$DIR/best-refs.md`：
```
## Entity: Girl with red hood
- best_ref: colored_00.png
- quality: hair=perfect, skin=perfect, hood=perfect
- images: colored_00, colored_02, colored_05

## Entity: Big bad wolf
- best_ref: colored_02.png
- quality: fur=perfect, eyes=perfect
- images: colored_00, colored_02
```

每完成一张上色图就更新：如果新图中某实体颜色比当前 best_ref 更好，更新 best_ref。

### 5. 收敛修正循环

全部上完后审计 → 修正 → 再审计 → 再修正，最多 3 轮，直到全部 PASS。

### 6. 回溯统一

如果修正后某实体的 best_ref 变了（后面的图颜色更好），回头重新上色前面的图。

---

## 完整工作流

### Phase 0 — 初始化

#### 步骤 1：获取频道和工作目录

- `echo $ANBANWRITER_DEFAULT_CHANNEL` → `$CHANNEL_ID`
- 如果为空，调用 `list_channels` 获取频道列表并选择
- 从 `.task-context` 获取 `$TASK_ID`，或使用 CWD 目录名
- 调用 `prepare_workspace(content_type="design", task_id=$TASK_ID)` → `$DIR`
- `mkdir -p "$DIR"`

#### 步骤 2：确认输入线稿

- 收集用户提供的线稿图路径列表
- Read 每张图验证存在且可读取
- 如果用户未指定顺序：
  - Read 每张线稿，快速评估角色密度（实体数量、构图复杂度）
  - 按角色数量降序排列（角色多、构图简单的先处理）
- 写入 `$DIR/input-manifest.md`：

```markdown
# Input Manifest

## Processing Order

| # | File | Reason |
|---|------|--------|
| 0 | /path/to/lineart_01.png | 3 characters, simple composition → anchor |
| 1 | /path/to/lineart_03.png | 2 characters, shares Girl with #0 |
| 2 | /path/to/lineart_02.png | 1 character, complex pose |
```

---

### Phase 1 — 渐进式上色循环

对 `input-manifest.md` 中的每张线稿（按顺序）执行步骤 3-7：

#### 步骤 3：读取线稿，识别实体

Read 当前线稿图，识别所有实体：

- **角色类**：人物、动物、拟人角色
  - 描述：位置、姿态、朝向、大小、服装特征、配饰、与其他角色的空间关系
  - 识别依据：外观特征（发型、服装轮廓、体型比例）、上下文线索
- **物体类**：关键道具、标志性物品
  - 描述：位置、大小、材质暗示
- **环境类**：场景背景、氛围元素
  - 描述：整体色调方向（温暖/冷调/中性）

关键原则：**识别的目的是匹配**——描述要足够详细，以便与后续图中的同一实体匹配。

#### 步骤 4：实体匹配与 Color Bible 更新

将识别到的实体与 `$DIR/color-bible.md` 中已有实体逐一匹配：

**匹配方法**（详见 [references/color-bible.md](references/color-bible.md)）：
- 基于外观特征描述：体型、发型轮廓、服装类型、配饰
- 基于上下文线索：角色在场景中的位置、与其他角色的关系
- 基于语义线索：故事中的角色功能（主角、对手、配角）

**已知实体**：
- 从 Color Bible 读取颜色规格
- 读取 `$DIR/best-refs.md` 确定该实体的最佳参考图路径

**新实体**：
- 为该实体定义颜色规格（语义色名 + 实物类比 + 反面约束）
- 颜色选择原则：
  - 角色性格匹配（活泼角色用暖色、沉稳角色用冷色）
  - 场景氛围匹配（户外场景用自然色、室内场景用柔和色）
  - 跨实体区分（不同角色的颜色应有足够区分度，避免混淆）
  - 与已有实体颜色的关系（互补/和谐/对比）
- 追加到 `$DIR/color-bible.md`

写入/更新 `$DIR/color-bible.md`。

#### 步骤 5：构建上色 Prompt

构建包含以下要素的 prompt（颜色描述使用英文，因为 image generation 模型对英文颜色术语响应更精确；其余指令可用中文）：

```
Color this line art illustration.

COLOR SPECIFICATIONS (must match exactly):

[Known entities — match the reference image]:
- [Entity A]: [element] is [语义色名, e.g. "deep dark chocolate brown, NOT light brown"],
  wearing [garment] in [语义色名, e.g. "bright cherry red, like a fire truck"],
  [element] in [语义色名]
  CONSTRAINT: [Entity A]'s [element] must NOT be [常见错误色]

[New entities — use these colors]:
- [Entity B]: [element] [语义色名], wearing [garment] in [语义色名]

COLOR RELATIONSHIPS:
- [Entity A]'s [element] is the same color as [Entity B]'s [element]

PRESERVE the exact line art composition and poses. Only add color.
Do not modify lines, proportions, or layout.
```

**Prompt 要点**：
- 已知实体：强调与参考图一致 + 反面约束
- 新实体：完整定义颜色 + 实物类比
- 跨实体颜色关系明确写出
- 最后固定语：保持线稿构图不变

#### 步骤 6：多候选生成

确定参考图：
- 有已知实体 → `ref_image_path = 包含当前图实体最多且 best_ref 最好的那张`
- 全部新实体 → 无参考图（纯 prompt）
- 多个已知实体但各自 best_ref 不同 → 选包含实体最多的那张

生成候选 A：
```
generate_image(
  channel_id="$CHANNEL_ID",
  prompt="[主 prompt]",
  image_type="content",
  output_path="$DIR/colored_NN_a.png",
  ref_image_path="[参考图路径]"
)
```

生成候选 B（微调 prompt 措辞）：
- 换一种方式描述同一颜色（如 "crimson red" → "deep blood red"）
- 或换一种实体描述顺序
- 或在 prompt 开头增加更强的一致性声明

```
generate_image(
  channel_id="$CHANNEL_ID",
  prompt="[微调后 prompt]",
  image_type="content",
  output_path="$DIR/colored_NN_b.png",
  ref_image_path="[参考图路径]"
)
```

#### 步骤 7：候选评估 + 最优选

1. Read 候选 A 和候选 B
2. 对每个候选，逐实体逐部位比对 Color Bible：
   - 对每个实体：列出所有部位（hair, skin, outfit-primary, outfit-secondary, accessories 等）
   - 对每个部位：描述观察到的颜色，与 Color Bible 定义比对
   - 打分：匹配部位数 / 总部位数
3. 选择得分最高的候选
4. `cp [选中候选] $DIR/colored_NN.png`
5. 如果两个候选都 < 70% 匹配：
   - 生成候选 C（换参考图或加强 prompt 约束）
   - 选三者中最好的
6. 更新 `$DIR/best-refs.md`：如果新图中某实体颜色比当前 best_ref 更好，更新
7. 删除未选中的候选文件

**产出**：`$DIR/colored_NN.png`

---

### Phase 2 — 全量一致性审计

验证与修正方法论详见 [references/verification.md](references/verification.md)。

#### 步骤 8：全面审计

读取所有 `$DIR/colored_NN.png`，对 Color Bible 中每个跨图实体进行逐部位比对。

生成 `$DIR/consistency-report.md`：

```markdown
# Consistency Report

## Entity: Girl with red hood

| Image | Hair | Skin | Hood | Dress | Overall |
|-------|------|------|------|-------|---------|
| colored_00 | ✅ dark chocolate | ✅ warm beige | ✅ cherry red | ✅ navy blue | PASS |
| colored_02 | ✅ dark chocolate | ✅ warm beige | ⚠️ slightly darker red | ✅ navy blue | MINOR |
| colored_05 | ✅ dark chocolate | ✅ warm beige | ❌ appears orange | ✅ navy blue | FAIL |

## Summary
- PASS: 5 entities across 12 appearances
- MINOR: 2 entities across 3 appearances
- FAIL: 1 entity across 1 appearance
```

---

### Phase 3 — 收敛修正循环（最多 3 轮）

#### 步骤 9：修正轮次

**每轮修正**：

**9a. FAIL 级修正**（用最佳参考图重新生成）：

对每个 FAIL 实体，构建修正 prompt：
```
CORRECTION PASS for color inconsistency.
The reference image shows the CORRECT color scheme for [Entity].

SPECIFIC ISSUES TO FIX:
- [Entity]'s [element] should be [语义色名] (currently appears [错误色描述])
- [Entity]'s [element] should be [语义色名] (currently appears [错误色描述])

Use the reference image's colors EXACTLY. The result must be visually
indistinguishable from the reference in terms of [Entity]'s colors.
PRESERVE the exact line art composition — only fix the colors.
```

- 同样生成 2 个候选选最优
- `ref_image_path = 该实体当前 best_ref 路径`
- 更新 best-refs.md

**9b. MINOR 级修正**（增加反面约束）：

在原 prompt 基础上增加反面约束：
```
IMPORTANT COLOR CORRECTION:
- [Entity]'s [element] must be [语义色名], NOT [当前错误方向]
- The reference shows the correct shade — match it exactly
```

生成 1 个候选即可。

**9c. 重新审计**：
- 更新 consistency-report.md
- 判断：
  - 全部 PASS → 跳出循环，进入 Phase 4
  - FAIL 数减少 → 继续下一轮
  - 无改善 → 停止循环，剩余 FAIL 标记 `needs_manual_review`

---

### Phase 4 — 回溯统一

#### 步骤 10：回溯检查

检查 Phase 3 中是否有实体的 best_ref 发生了变化：

- 如果某实体原来的 best_ref 是 `colored_00.png`，修正后变成了 `colored_05.png`
- 那么包含该实体的其他图（如 `colored_00.png`、`colored_02.png`）中，该实体的颜色可能不再与新的 best_ref 一致
- 需要：用新的 best_ref 作参考，重新上色这些图

回溯修正同样 2 候选选最优。

回溯修正后重新审计，确认一致性。

---

### Phase 5 — 归档报告

#### 步骤 11：最终报告

向用户交付结果：

```
线稿上色完成

总图数: 8
修正轮次: 2
最终一致性: 100% PASS

Color Bible 实体数: 5（3 角色 + 2 物体）
一致性报告: $DIR/consistency-report.md

成果文件:
- colored_00.png ~ colored_07.png

人工复核: 无
```

如果有人工复核项：
```
需要人工复核:
- colored_05.png: [Entity] 的 [element] 经 3 轮修正仍偏差
  建议: 手动指定该部位颜色后重新运行修正步骤
```

---

## Prompt 构建技巧

### 语义色名参考

不用 hex，用 AI 模型能准确理解的色名：

| 色系 | 好的描述 | 差的描述 |
|------|---------|---------|
| 红色 | bright cherry red, like a fire truck | #FF0000 |
| 深红 | deep crimson, like dried blood | dark red |
| 蓝色 | bright sky blue on a clear day | #0000FF |
| 深蓝 | dark navy blue, like a midnight suit | #000080 |
| 绿色 | fresh grass green, like spring lawn | #00FF00 |
| 棕色 | dark chocolate brown, not milk chocolate | brown |
| 金色 | warm golden, like honey in sunlight | #FFD700 |
| 粉色 | soft rose pink, like cherry blossoms | pink |
| 紫色 | rich plum purple, like ripe grapes | #800080 |
| 黑色 | deep jet black, like polished obsidian | black |
| 白色 | pure clean white, like fresh snow | white |
| 灰色 | cool slate gray, like overcast sky | gray |

关键：**始终附带实物类比**——"like a fire truck"、"like dark chocolate"——这给模型一个具体的视觉锚点。

### 反面约束模板

```
[Entity]'s [element] must NOT be:
- [常见错误色 1] (too light / too dark / wrong hue)
- [常见错误色 2] (common AI generation mistake)
It must be [正确色名], [实物类比]
```

### 跨实体颜色关系

如果两个实体共享某种颜色，明确写出：
```
COLOR RELATIONSHIPS:
- Girl's hood is the SAME bright cherry red as the picnic blanket
- Wolf's eyes are the SAME amber gold as the sunset
```

这帮助模型理解颜色必须跨实体一致。

---

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 颜色不跟随参考图 | 模型随机性过大 | 2 候选选最优 + 收敛修正 + 回溯统一 |
| 角色色偏（如头发偏亮） | 模型对浅色有偏好 | 增加反面约束："must NOT be blonde" |
| 背景色渗入角色 | 模型无法分离前景/背景 | prompt 明确分离："character colors must NOT be influenced by background" |
| 多角色图中某角色颜色错误 | 多实体增加复杂度 | 单独指定每个实体的反面约束 |
| 实体匹配错误 | 不同角色外观相似 | 增加 more specific 描述（位置、配饰、体型差异） |
| 新实体颜色与已有实体冲突 | 颜色区分度不够 | 选色时确保跨实体区分度 |

---

## 验证清单（每张图完成后）

- [ ] 所有已识别实体都有颜色规格
- [ ] Color Bible 已更新
- [ ] 候选评估完成，选中匹配度最高的
- [ ] best-refs.md 已更新
- [ ] 正式上色图 `$DIR/colored_NN.png` 存在

## 验证清单（全部完成后）

- [ ] 所有上色图存在
- [ ] consistency-report.md 已生成
- [ ] 收敛修正完成（全部 PASS 或达最大轮次）
- [ ] 回溯统一完成（如需要）
- [ ] 无 FAIL 项或已标记人工复核
- [ ] 最终报告已交付
