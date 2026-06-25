---
name: seednote
description: 种草笔记图文全自动创作。用户提到"种草笔记"、"seednote"、"种草"、"复刻"、"仿写"、"改写笔记"、"爆款改写"、"克隆"、"clone"时使用此 skill。
---

# /seednote 种草笔记内容创作命令

## 强制执行声明

**你正在执行种草笔记内容创作任务。你必须使用工具（MCP 工具、Write、Bash、TaskCreate 等）完成完整的创作流水线。**

**禁止直接用文字回答用户的主题问题。** 你不是在回答问题，你是在创作一篇种草笔记。如果你直接输出文字回答而没有使用任何工具，说明你理解错了任务。

用户输入 `/seednote` 后面的内容是创作主题，不是让你回答的问题。

---

## 必须执行的步骤

按顺序执行以下步骤。每一步都必须调用对应的工具，不能跳过。

### 步骤 1：获取账号信息

**先解析 `$TASK_ID`**：检查 CWD 下是否存在 `.task-context` 文件，从中读取 `TASK_ID=xxx`；否则使用 CWD 目录名作为 `$TASK_ID`。后续所有需要 task_id 的 MCP 工具调用都复用此值。

然后通过 Bash 执行 `echo $ANBAN_DEFAULT_PROJECT` 检查环境变量。若非空，直接使用其值作为 `$PROJECT_ID`，跳过下面的 `list_projects`。若为空（如本地无服务端上下文的纯 CLI 场景），调用 MCP 工具：
- `list_projects(platform="seednote")` → 获取项目列表。只有一个匹配项目时记为 `$PROJECT_ID`；多个匹配时按用户话题与项目 `name`/`positioning`/`keywords` 语义匹配，能明确判断则用之，否则向用户展示候选让其选择
- `get_project_profile(project_id="$PROJECT_ID", scope="seednote", task_id="$TASK_ID")` → 获取账号定位、关键词等信息。`task_id` 让服务端用任务派生的模板风格覆盖 project 默认风格（`style_source="task"`），不传则只拿到 project 级风格。
- `list_project_titles(project_id="$PROJECT_ID")` → 查看系统内已有标题，后续标题避开

### 步骤 2：创建工作目录

调用 MCP 工具：
- `prepare_workspace(content_type="seednote", task_id=$TASK_ID)` → 获取工作目录路径，记为 `$DIR`
- 通过 Bash 执行 `mkdir -p "$DIR"` 创建目录

### 步骤 3：研究选题

原创模式使用 `seednote-research` skill：
- 采集热门笔记数据
- 自动选 Top 1 选题
- 评分结果写入 `$DIR/topic-analysis.md`

复刻模式使用 `seednote-research` skill：
- 获取源笔记详情、互动数据和评论数据
- 原始详情写入 `$DIR/source-note.md`

然后使用 `seednote-viral-analysis` skill：
- 证据驱动拆解源笔记
- 生成 `$DIR/source-analysis.md`、`$DIR/viral-template.json`、`$DIR/template-meta.json`

### 步骤 4：创作内容

使用 `seednote-writing` skill：
- 生成标题（≤20 字）、正文、话题标签
- 复刻模式读取 `$DIR/viral-template.json`，不得重新拆解源笔记
- 内容保存到 `$DIR/content.md`

### 步骤 5：生成图片

使用 `seednote-visual-design` skill：
- 传入 `$DIR/content.md`
- 生成封面 `$DIR/cover.png`、内容图 `$DIR/image_01.png` ... `$DIR/image_03.png`、尾图 `$DIR/tail.png`（**仅当「图片构成要求」指令含尾图时**；指令不含或禁止尾图则不生成尾图、`image-plan.md` 不含 `## tail` 节）
- 图片规划写入 `$DIR/image-plan.md`

### 步骤 6：合规检查（复刻模式）

如果是复刻模式（用户提供了笔记 ID 或链接）：
- 使用 `seednote-writing` skill 扫描标题与正文
- 生成 `$DIR/compliance-report.md`

### 步骤 7：归档

- 确认 AI 最终选定标题 `$FINAL_TITLE`，必须是真实发布标题，不得是 `图片内容规划`、`标题候选与评分`、`选题研究报告`、`违禁词合规检查报告` 等内部产物标题
- 调用 `archive_workspace(content_type="seednote", name="$FINAL_TITLE")` 获取归档路径 `$ARCHIVE_DIR`
- 通过 Bash 执行 `mkdir -p "$ARCHIVE_DIR" && mv "$DIR"/* "$ARCHIVE_DIR/" 2>/dev/null` 移动文件
- 报告成果目录路径 `$ARCHIVE_DIR`
- 最终标题写入系统排重库由 seednote 完成 hook 统一负责，本 skill 不直接上报标题

---

## 模式判断

- 用户提供笔记 ID 或链接 → **复刻模式**（步骤 3 改为获取源笔记并分析）
- 其他情况 → **原创模式**（按上述步骤执行）

---

## 质量标准

- 图片总数符合 image-plan.md「计划图片数量」声明值（封面 1 + 内容图 1~3 + 尾图 0~1）
- 所有图片视觉风格一致
- `content.md` 包含标题、正文、话题标签三部分
- 标题 ≤ 20 字，关键词前置

---

## 任务追踪要求

流程启动时用 `TaskCreate` 创建任务列表，每个步骤对应一个任务。开始前 `TaskUpdate status → in_progress`，完成后 `TaskUpdate status → completed`。报告进度示例：`[3/7] 内容创作完成 → $DIR/content.md`

---

## 子技能调用顺序

| 步骤 | 调用技能 | 产出 |
|------|----------|------|
| 1 | Bash + MCP 调用 | `$PROJECT_ID` |
| 2 | 直接 MCP 调用 | `$DIR` |
| 3 | `seednote-research` | `topic-analysis.md`（原创）或 `source-note.md`（复刻） |
| 3b | `seednote-viral-analysis` | `source-analysis.md`, `viral-template.json`, `template-meta.json`（仅复刻模式） |
| 4 | `seednote-writing` | `content.md` |
| 5 | `seednote-visual-design` | `cover.png`, `image_0*.png`, `tail.png`（可选，按「图片构成要求」指令）, `image-plan.md` |
| 6 | `seednote-writing` | `compliance-report.md`（仅复刻模式） |
| 7 | 直接 MCP 调用 | 归档到 `$ARCHIVE_DIR` |
