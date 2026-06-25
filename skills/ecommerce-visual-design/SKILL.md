---
name: ecommerce-visual-design
description: 电商视觉设计与生成——商业转化导向的视觉工艺，按已选模块规划并生成主图/详情/封面/分享/SKU，保证产品跨图一致。受众=买家，目标=点击→转化→降退货。当电商出图流程需要图片规划或生成时使用。
---

# 电商视觉设计与生成

## 受众与目标

服务于**点击与下单**的商业转化视觉——**不是种草情绪共鸣，也不是线稿保真**。每张图都要回答「它让买家更想点击/下单了吗」。

## 硬性纪律（违反视为流程失败）

- **禁止跳过 asset-plan.md 直接调 generate_image**
- **禁止生成未在 `selected_modules` 中的模块**——未选模块不出现在 asset-plan.md、不调 generate_image、不进 manifest
- **禁止在多张不同场景图上重复使用同一 `ref_image_path`**（Seedream 强 i2i 会把场景钉死导致雷同；详见「provider 与一致性策略」）
- **每次调用 generate_image 后必须把实际 prompt + provider + model + size + output_path + ref_image_path + revised_prompt 追加到 `$DIR/image-prompts.md`**
- **一致性关键模块的每张图必须 `verify_with_vision=true`**，自检结果写入 `$DIR/best-refs.md` 与 manifest
- **图内文字语言必须与用户语言一致**（中文场景用简体中文），文字用全角引号「」包裹；禁止英文/拼音/乱码/伪词

---

## MCP 工具

| MCP 工具 | 用途 |
|----------|------|
| `generate_image(project_id, prompt, image_type, output_path, size, ref_image_path, task_id, image_model_key, verify_with_vision, verification_prompt)` | 生成单张电商素材 |
| `analyze_image(project_id, file_path\|image_url, prompt)` | 视觉自检 / 锚点评估 |
| `compress_image(file_path)` | 大图压缩 |

> `generate_image` 当前**仅接受单个 `ref_image_path`**。多产品一致性靠「产品档案文本块（汇总全部产品图属性）+ 单张最佳锚点参考 + 视觉自检」实现。

---

## 输入

- `$DIR/product-bible.md`（产品档案 + `$ANCHOR_REF` 锚点）
- `$DIR/copywriting.md`（排序卖点 + 各模块文案）
- 项目画像（`image_strategy` provider 策略 + 风格）
- 任务选项：`selected_modules`、`target_platform`、`visual_style`、语言、各模块数量、`provider_strategy_override`

---

## 步骤 1：确定视觉风格基线 `$STYLE`

- 项目有参考图/风格描述 → 用之。
- 否则按**品类 × 平台 × 受众**动态设计 `$STYLE`（配色/版式/字体/质感/信息密度），写入 `$DIR/asset-plan.md` 的「视觉风格基线」。`$STYLE` 由主图①确立，后续图共享。

**电商视觉语言要素**：
- **卖点可视化**：把抽象卖点转成可视符号（如「长续航」→ 电量条/时钟图标；「轻」→ 羽毛/手持比例）。
- **促销/价格视觉钩子**：角标/价格牌/赠品标，真实且合规。
- **信息层级**：主体最大 → 卖点次之 → 钩子醒目，服务「先看什么→再看什么→点击/下单」。
- **商业品质感**：专业打光、材质质感、留白、栅格对齐。
- **移动端首屏可读**：主图①与详情首节在手机首屏即传达核心卖点。

## 步骤 2：产出 asset-plan.md（仅含已选模块）

按模块逐张规划。每张含：`用途 / 尺寸 / 视觉主体 / 必须出现的卖点文字 / 禁用元素 / provider 分配 / 是否用锚点参考 / 验收标准`。

**尺寸规范**（按 `target_platform`，详见 `ecommerce-platform-specs`）：
- 主图：`1:1:2K`（淘宝天猫/京东 800² 可放大）
- 详情页：`3:4:2K`（750-790 宽移动优先）
- 封面 banner：`16:9:2K` 或 `3:4:2K`
- 分享图：`1:1:2K` 或 `3:4:2K`（按平台）
- SKU：`1:1:2K`

各模块设计规范见：
- 主图 → [references/main-image.md](references/main-image.md)
- 详情页 → [references/detail-page.md](references/detail-page.md)
- 封面 banner → [references/cover-banner.md](references/cover-banner.md)
- 分享图 → [references/share-image.md](references/share-image.md)

**asset-plan.md 必须在「计划图片数量」字段写入实际总张数**（按已选模块求和），机械闸门按此校验。

## 步骤 3：provider 与一致性策略

读项目画像 `image_strategy`（`{primary, fallback, consistency_audit}`）；未配置则默认：一致性关键模块 primary=OpenAI、辅图 fallback=Seedream。任务级 `provider_strategy_override` 可覆盖。

**一致性策略（电商独有，独立设计）**：

1. **产品档案前缀块**：每个 prompt 以 `【产品档案·必须严格遵守】{产品档案的「一致性锁定项」：品牌 logo 文字与颜色 / 主色 HEX / 形状轮廓 / 包装可见文字}` 开头。
2. **锚点优先**：先生成主图①（点击主图），确立色系/版式/字体基准。
3. **ref 使用规则**（规避 Seedream 场景雷同）：
   - **一致性关键模块**（主图①、详情核心场景如「核心卖点解析」「对比证明」）→ 用 `image_strategy.primary`（默认 OpenAI，单参考保真最好）+ `ref_image_path=$ANCHOR_REF`。
   - **场景差异大的辅图**（多场景使用图、不同构图的分享/封面辅图、SKU 不同款）→ **纯文生图（不传 ref）+ 共享 `$STYLE` + 产品档案文本块**，每张独立视觉主体/场景。**禁止把同一锚点 ref 重复用于多张不同场景图**——会让所有图长得一样。
   - **同产品不同角度/细节特写** → 可用锚点 ref（应保持同一商品）。
4. **视觉自检循环**：一致性关键模块每张 `verify_with_vision=true`，verification_prompt 由产品档案派生（见步骤 5）。FAIL → 强化产品档案约束 + 收紧卖点文字约束重生成，**最多 3 轮**；仍不达标标 `needs_reference` 并在 manifest 披露。
5. **诚实标注**：当前 `generate_image` 是参考图生成，非专用 product-lock img2img；不能保证像素级 100% 一致，差异作为风险记录。

## 步骤 4：图片生成

按 asset-plan.md 逐张生成。**主图①先行**确立基准。

每张 generate_image 调用：
- `project_id=$PROJECT_ID`
- `prompt` = 产品档案前缀块 + 本张视觉描述（视觉主体/场景/构图/打光）+ 必须出现的卖点文字（用「」包裹）+ `$STYLE` 风格延续块 + 禁用元素
- `image_type`：主图/封面/分享/SKU 用 `"cover"` 配置，详情图用 `"content"` 配置（按项目 image API 配置；默认 cover 用更高质量）
- `size`：按 asset-plan
- `output_path`：`$DIR/<模块>_<NN>.png`
- `ref_image_path`：按步骤 3 规则（锚点 or 不传）
- `task_id=$TASK_ID`
- `verify_with_vision`：一致性关键模块 true
- `verification_prompt`：见步骤 5

**Prompt 备份**：每次调用后把实际 prompt/provider/model/size/output_path/ref_image_path/revised_prompt 追加 `$DIR/image-prompts.md`。

**失败处理**：单图失败重试一次仍失败则跳过并在 manifest 标注；主图①失败重试两次仍失败则**停止并请求用户协助**（主图是 CTR 之战，不可缺）。重试必须覆盖同一 output_path，禁止新增 `_v2` 候选文件；归档前清理目录，仅保留 asset-plan 列出的文件。

## 步骤 5：视觉自检（电商专属维度）

一致性关键模块的 `verification_prompt` 由产品档案派生，要求模型返回 JSON `{all_entities_present, missing_entities, relevance_score, overall_pass, has_forbidden_content, forbidden_notes}`：

```
你是电商视觉质检员。检查这张电商素材图是否满足：
1. 产品一致性：产品品牌/logo 文字、主色（{HEX}）、形状轮廓、包装可见文字（{包装文字}）是否与产品档案一致？有无多出或漏掉的品牌标记/文字？
2. 卖点文字：要求出现的卖点文字「{本张必须出现文字}」是否清晰可读、无错别字/乱码/英文（中文场景）？
3. 信息层级：主体是否突出、卖点是否在合理层级？
4. 合规：是否含极限词/违禁词/虚假承诺？
返回严格 JSON：{all_entities_present, missing_entities, relevance_score(high/medium/low), overall_pass(bool), has_forbidden_content(bool), forbidden_notes}
```

自检结果写入 `$DIR/best-refs.md`（逐图：provider/自检 PASS-FAIL/重试轮次/needs_reference）。

## 步骤 6：模块内一致性复查

同模块多张图生成后，复查视觉风格一致（同色系/版式/字体/信息密度）与卖点不重复堆砌。不一致则按 `$STYLE` 块重生成偏离的那张。

---

## 常见失败与修复

| 问题 | 原因 | 修复 |
|------|------|------|
| 产品跨图不一致 | 锚点未用 / 档案约束弱 | 一致性关键模块加 `ref_image_path=$ANCHOR_REF` + 强化档案前缀块 + 自检重生成 |
| 多张场景图雷同 | 复用同一 ref | 改纯文生图 + 独立场景 + 共享 `$STYLE`，不重复 ref |
| 图内文字乱码/英文 | 语言约束弱 | 文字用「」包裹 + 末尾独立「禁止英文/拼音/乱码」段 + 缩短到 ≤12 字 |
| 卖点未可视 | prompt 只描述产品没描述卖点符号 | 把卖点转成可视符号写进 prompt（见 `$STYLE` 卖点可视化） |
| 主图①无冲击 | 缺钩子/层级混乱 | 按 main-image.md 的 CTR 模板重做：主体最大→卖点→钩子 |
| 详情节无叙事 | 章节乱序 | 按 detail-page.md 黄金结构重排 |
| 极限词 | 文案带禁用词 | 删除/改写，重生成相关图 |

---

## 产出

- `$DIR/asset-plan.md`（仅含已选模块的计划）
- `$DIR/image-prompts.md`（全部 prompt 备份）
- `$DIR/best-refs.md`（逐图 provider/自检/重试/needs_reference）
- 各模块图片：`main_01..05.png`、`detail_01..NN.png`、`cover_01..NN.png`、`share_01..NN.png`、`sku_<variant>.png`
