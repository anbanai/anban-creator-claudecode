---
name: seednote
description: 'Use when 种草笔记图文全自动创作。用户提到"种草笔记"、"seednote"、"种草"、"复刻"、"仿写"、"改写笔记"、"爆款改写"、"克隆"、"clone"时使用此 skill。'
---

# /seednote 种草笔记内容创作命令

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


## 强制执行声明

**你正在执行种草笔记内容创作任务。你必须使用工具（MCP 工具、Write、Bash、TaskCreate 等）完成完整的创作流水线。**

**禁止直接用文字回答用户的主题问题。** 你不是在回答问题，你是在创作一篇种草笔记。如果你直接输出文字回答而没有使用任何工具，说明你理解错了任务。

用户输入 `/seednote` 后面的内容是创作主题，不是让你回答的问题。

---

## 图片构成规则（运行控制）

图片构成以结构化运行控制 `seednote_image_mode` 为准。缺失时按 `cover_content`。四种模式：`cover_only`（仅封面）、`cover_content`（封面 + 1~3 张内容图）、`cover_tail`（封面 + 尾图）、`full`（封面 + 1~3 张内容图 + 尾图）。未包含尾图的模式禁止生成 `tail.png`，`image-plan.md` 不得含 `## tail` 节；未包含内容图的模式禁止生成 `image_0N.png`。

---

## Seednote 视觉方法论

Seednote 最终图片产物由 `generate_image` MCP 生成；本地文件只承载规划、Prompt 蓝图、生成记录和质量复盘。图片链路按以下方法执行：

1. **内容蒸馏**：从 `$DIR/content.md` 提取主题、卖点、情绪、证据、关键短句和每页承载的信息密度。
2. **视觉策略**：先确定统一色彩、画面主体、标题层级、信息密度和内容页节奏，再写入 `$DIR/image-plan.md`。社交图文视觉原则用于提升模型出图方向：`editorial 信息层级` 让主标题、辅助信息、证据点和视觉主体各司其职；`Swiss/magazine 秩序感` 用留白、对齐、分组和对比服务移动端可读性；`图文节奏` 要求封面负责点击，内容图负责理解，尾图负责收束。
3. **Prompt 蓝图**：每张图都有角色、可见文案、视觉主体、构图层级、风格延续和验收标准；Prompt 只描述要得到的画面效果和内容关系。
4. **生成记录**：每次调用 `generate_image` 后，把实际 prompt、`provider`、`model`、`output_path`、返回字段和修订信息写入 `$DIR/image-prompts.md`。
5. **质量复盘**：逐图写 `$DIR/image-review.md`，检查主题相关度、文字准确性、移动端可读性、风格一致性和是否符合 `seednote_image_mode`。

如果图片 API、视觉核验依赖或重试预算失败，写 `$DIR/image-review.md` 与结构化 `$DIR/failure-state.json` 后停止。每张图必须通过 `generate_image(..., verify_with_vision=true, verification_prompt=<动态核验提示词>)` 原子核验；禁止用 prompt 质量、文件尺寸或 MIME 代替视觉核验。

---

<!-- seednote-reference-contract:start -->
## 多参考素材自动决策流程

1. 先读取用户统一提示词、项目资料、`.anban-creator/input-attachments/index.json` 和可选的 `errors.json`，写出 `request-analysis.json` 与 `request-analysis.md`。此阶段不得先分析图片。
2. 遍历 `index.json` 中每张可用图片。针对已完成的需求分析和该图片的可选 `instruction`，动态编写该图片独有的 `analyze_image` prompt；每张可用图片都必须分析，单张最多 3 次理解尝试。`errors.json` 中的条目必须记为 `analysis_failed`；若它是产品身份、Logo、包装、型号或核心结构的唯一证据则停止任务，其他素材能可靠补足时才可继续并记录依据。
3. 写出 `reference-analysis.json` 与 `reference-analysis.md`，记录可见事实、不确定性、需求支持点、可参考维度、必须保持、必须避免、不可推出结论，并完成同产品/系列/型号、新旧包装、角度、事实图/氛围图、Logo/文字/颜色/结构冲突分析。
4. 写出 `image-plan.md`。对每张输出图独立决定使用 0、1 或多张附件，记录附件编号、每张用途、保持项、禁止项。不得把所有素材传给所有页面；超过服务端返回的数量上限时按当页相关性排序选择子集。
5. 写出 `image-prompts.md`。调用 `generate_image` 时只传当前输出图相关的原始路径，数组顺序必须与 prompt 中“参考图 1、参考图 2”一致。不得传分析后的截图、拼图或转码替代原图。
6. 每张生成图片都在 `generate_image` 中传 `verify_with_vision=true` 和动态 `verification_prompt`，以服务端 `verification.passed` 作为唯一通过依据并写入 `image-review.md`；`analyze_image` 只用于理解输入参考图。
7. 核验不通过时自动调整参考组合/顺序、生成 prompt、保持项/禁止项、构图复杂度或核验 prompt。每张输出图最多 3 次生成尝试，初次生成计入。不得请求用户决定。
8. 写出 `reference-usage-summary.json`。关键事实无法保证时任务失败；非关键氛围或轻微构图问题可保留并记录 warning。
<!-- seednote-reference-contract:end -->

## 参考素材追踪产物与失败策略

每次运行都必须归档以下 8 个产物；即使任务失败，也不得删除已经写出的文件：

```text
request-analysis.json
request-analysis.md
reference-analysis.json
reference-analysis.md
image-plan.md
image-prompts.md
image-review.md
reference-usage-summary.json
```

`reference-usage-summary.json` 使用以下结构；`status` 使用 `used`、`excluded` 或 `analysis_failed`，模型字段记录服务端实际返回值：

```json
{
  "version": "1.0",
  "inputs": [
    {
      "attachment_index": 1,
      "file_name": "attachment_01_front.png",
      "url": "https://example.invalid/front.png",
      "instruction": "保持包装和 Logo",
      "status": "used",
      "decision_summary": "正面图是产品身份和包装文字的主要证据",
      "analysis_attempts": 1,
      "warnings": []
    }
  ],
  "outputs": [
    {
      "file_name": "cover.png",
      "references": [{ "attachment_index": 1, "purpose": "保持产品身份、包装和 Logo" }],
      "generation_attempts": 2,
      "verification": { "passed": true, "score": "high", "missing_entities": [], "notes": "产品身份、包装和当页文字核验通过" },
      "provider": "openai",
      "model": "gpt-image-2",
      "selection_reason": "reference_compatible_fallback"
    }
  ],
  "warnings": [],
  "model_fallback_reason": "首选模型的参考图上限不足，服务端选择了兼容模型"
}
```

执行预算固定为：每张输入图最多 3 次理解尝试；每张输出图最多 3 次生成尝试，首次生成计入。不得向用户发起中途确认，也不得把参考素材选择、模型回退或重试决策转交给用户。

关键失败包括：唯一产品身份、Logo、包装、型号或核心结构证据不可用；身份或结构幻觉；冲突版本融合；出现禁止内容；页面无法履行职责。遇到关键失败时停止在当前阶段，但必须保留已生成文件和 trace artifacts，记录失败阶段和下一步建议，后续从失败阶段恢复。非关键氛围或轻微构图问题只记录 warning，不得把它升级成需要用户中途决策的阻塞。

停止时写入 `failure-state.json`：`{"version":"1.0","status":"recoverable_failure","stage":"<stage>","error_code":"<stable_code>","message":"<原始错误摘要>","resume_from":"<stage>"}`。该文件表示任务未成功，供 Stop hook 与服务端完成校验使用。

恢复运行时必须保留旧的 `failure-state.json`，直到 `resume_from` 指向的阶段已成功重做且全部交付校验满足；仅在即将报告成功前删除旧失败态。不得在恢复开始时提前删除，也不得交付仍带失败态的结果。

---

## 必须执行的步骤

按顺序执行以下步骤。每一步都必须调用对应的工具，不能跳过。

### 步骤 1：获取账号信息

**先解析 `$TASK_ID`**：检查 CWD 下是否存在 `.task-context` 文件，从中读取 `TASK_ID=xxx`；否则使用 CWD 目录名作为 `$TASK_ID`。后续所有需要 task_id 的 MCP 工具调用都复用此值。

然后通过 Bash 执行 `echo $ANBAN_DEFAULT_PROJECT` 检查环境变量。若非空，直接使用其值作为 `$PROJECT_ID`，跳过下面的 `list_projects`。若为空（如本地无服务端上下文的纯 CLI 场景），调用 MCP 工具：
- `list_projects(platform="seednote")` → 获取项目列表。只有一个匹配项目时记为 `$PROJECT_ID`；多个匹配时按用户需求与项目 `name`/`positioning`/`keywords` 计算相关性，并按“相关性降序、`project_id` 升序”稳定排序后自动选择第一名，把依据写入 `request-analysis.md`，不得询问用户
- `get_project_profile(project_id="$PROJECT_ID", scope="seednote", task_id="$TASK_ID")` → 获取账号定位、关键词等信息。`task_id` 让服务端用任务级 `visual_style` 覆盖 project 默认风格（`visual_style_source="task"`），不传则只拿到 project 级风格。
- `list_project_titles(project_id="$PROJECT_ID")` → 查看系统内已有标题，后续标题避开

### 步骤 2：创建工作目录

调用 MCP 工具：
- `prepare_workspace(content_type="seednote", task_id=$TASK_ID)` → 获取工作目录路径，记为 `$DIR`
- 通过 Bash 执行 `mkdir -p "$DIR"` 创建目录
- 所有产物始终保留在 `$DIR`；任务完成前不得移动、复制或按标题重命名成果目录。`task_files`、`execution_id` 与 OSS 持久化由服务端维护各自的登记、执行和版本边界

### 步骤 3：研究选题

原创模式使用 `seednote-research` skill：
- Agent-Reach 健康时采集真实热门笔记数据；不可用时基于用户主题、选题池、账号画像和已有标题继续
- 自动选 Top 1 选题，不得把降级判断描述成外部热门数据
- 外部评分或降级依据写入 `$DIR/topic-analysis.md`；原创模式不得因 Agent-Reach 不可用写 `failure-state.json`

复刻模式使用 `seednote-research` skill：
- 通过 Agent-Reach 获取源笔记详情、互动数据和评论数据
- 原始详情写入 `$DIR/source-note.md`
- 仅有外部 ID/链接且仍无法取得源内容时，写结构化失败态并停止

然后使用 `seednote-viral-analysis` skill：
- 证据驱动拆解源笔记
- 生成 `$DIR/source-analysis.md`、`$DIR/viral-template.json`、`$DIR/template-meta.json`

### 步骤 4：创作内容

使用 `seednote-writing` skill：
- 生成标题（≤20 字）、正文、话题标签
- 复刻模式读取 `$DIR/viral-template.json`，不得重新拆解源笔记
- 内容保存到 `$DIR/content.md`

### 步骤 4b：标题终稿锁定

- 内容写作与 humanizer 完成后，由 seednote Agent 在任何图片规划/生成前调用 `finalize_task_title`
- 重复标题先更新 `content.md` 第一行并重跑 humanizer 与标题合规，再重试
- 服务端接受的标题是后续视觉、合规与交付校验的唯一 `$FINAL_TITLE`；本 skill 不复制 Agent 的重试与失败算法

### 步骤 5：生成图片

使用 `seednote-visual-design` skill：
- 传入 `$DIR/content.md`
- 生成封面 `$DIR/cover.png`、内容图 `$DIR/image_01.png` ... `$DIR/image_03.png`（仅含内容图的模式）、尾图 `$DIR/tail.png`（仅含尾图的模式）；不含尾图的模式不得生成尾图、`image-plan.md` 不含 `## tail` 节
- 技能内部按 `seednote_image_mode` 完成内容蒸馏、视觉策略、Prompt 蓝图、图片内容规划（`$DIR/image-plan.md`）和全部图片生成
- 每张图都通过带 `verify_with_vision=true` 和动态 `verification_prompt` 的 `generate_image` 原子生成、登记与核验，并写入 `$DIR/image-prompts.md` 和 `$DIR/image-review.md`
- 图片 API 或核验依赖失败时写 `failure-state.json` 并停止，待模型、额度、网络或配置修复后从图片生成阶段继续

### 步骤 6：合规检查（复刻模式）

如果是复刻模式（用户提供了笔记 ID 或链接）：
- 使用 `seednote-writing` skill 扫描标题与正文
- 生成 `$DIR/compliance-report.md`

### 步骤 7：交付校验

- 使用服务端已接受的 `$FINAL_TITLE`，不得在图片生成后静默改名
- 直接校验 `content.md`、图片规划、图片核验记录、合规报告和计划中的全部图片都位于 `$DIR`
- 报告成果目录路径 `$DIR`，不得移动、复制或按标题重命名成果目录
- 最终标题排重与入库由 seednote Agent 的 title_finalization 阶段负责；本专业流程不另建 Hook 副本。

---

## 模式判断

- 用户提供笔记 ID 或链接 → **复刻模式**（步骤 3 改为获取源笔记并分析）
- 其他情况 → **原创模式**（按上述步骤执行）

---

## 质量标准

- 图片总数符合 image-plan.md「计划图片数量」声明值（封面 1 + 内容图 1~3 + 尾图 0~1）
- 所有图片视觉风格一致
- 所有图片均由 `generate_image` 生成，并保留 `image-prompts.md` 与 `image-review.md`
- `content.md` 包含标题、正文、话题标签三部分
- 标题 ≤ 20 字，关键词前置

---

## 任务追踪要求

流程启动时用 `TaskCreate` 创建任务列表，每个步骤对应一个任务。开始前 `TaskUpdate status → in_progress`，完成后 `TaskUpdate status → completed`。报告进度示例：`[N/M] 标题终稿锁定 → $DIR/content.md`

---

## 子技能调用顺序

| 步骤 | 调用技能 | 产出 |
|------|----------|------|
| 1 | Bash + MCP 调用 | `$PROJECT_ID` |
| 2 | 直接 MCP 调用 | `$DIR` |
| 3 | `seednote-research` | `topic-analysis.md`（原创）或 `source-note.md`（复刻） |
| 3b | `seednote-viral-analysis` | `source-analysis.md`, `viral-template.json`, `template-meta.json`（仅复刻模式） |
| 4 | `seednote-writing` | `content.md` |
| 4b | Agent 直接调用 `finalize_task_title` | 服务端接受的 `$FINAL_TITLE` |
| 5 | `seednote-visual-design` | `cover.png`, `image_0*.png`（按 `seednote_image_mode`）, `tail.png`（按 `seednote_image_mode`）, `image-plan.md` |
| 6 | `seednote-writing` | `compliance-report.md`（仅复刻模式） |
| 7 | Agent 交付校验 | `$DIR` 中的最终成果 |
