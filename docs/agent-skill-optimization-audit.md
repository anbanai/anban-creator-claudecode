# Claude Code Agent 与 Skill 优化审计

> 审计日期：2026-07-15
>
> 范围：`claudecode/agents`、顶层 `claudecode/skills`、`claudecode/hooks` 和相关开发文档。
>
> 依据：[GPT-5.6 Prompt Guidance](./gpt-5.6-prompt-guidance.md)、Claude Code 官方 [Subagents](https://code.claude.com/docs/en/sub-agents)、[Skills](https://code.claude.com/docs/en/skills) 与 [Hooks](https://code.claude.com/docs/en/hooks-guide)。

## 范围与例外

本轮盘点包含 9 个 Agent 和 37 个顶层 Skill。

以下资产不进入本轮自研优化范围：

- `skills/seedance-20/`：计划迁移为 third-party 类型，本审计不提出正文拆分、描述改写或 eval 调整。
- `skills/humanizer/`：来自上游的字节级镜像。即使当前 `SKILL.md` 超过 500 行，也不在仓库内改写；业务约束继续留在各自工作流中。

`dreamina-video` 是 `seedance-20` 的兼容入口。后续 third-party 迁移时应与 `seedance-20` 一并决定保留、重定向或删除，不在本轮单独优化。

## 总体判断

当前体系已经具备清晰的 Agent + Skill + MCP 分层意识，关键产物也普遍采用文件化契约。本轮已经修正 Hook 生命周期、最终副作用所有权和 Seednote 归档安全；仍待优化的主要问题是同一行为在 Agent、总控 Skill 和专业 Skill 中重复定义，导致：

- 每次 Agent 启动都注入大量固定上下文；
- 修改一个流程时需要同步多个提示词表面；
- 错误处理、用户交互和完成条件容易发生冲突；
- 历史 Hook 曾在不恰当的生命周期做昂贵的 LLM 验收；本轮已改为确定性 gate，但需要持续防止职责回流；
- 缺少能够证明“删减后质量没有下降”的 eval 基线。

目标不是简单缩短文件，而是建立单一职责和可测契约：

```text
Agent       = 业务流程所有者、阶段路由、完成与恢复语义
Skill       = 单一专业能力、输入输出契约、按需知识
Hook        = 生命周期上的确定性约束或轻量判断
MCP         = 服务端动作与结构化数据边界
Artifact    = 跨阶段状态、证据和恢复入口
```

## 现状数据

Claude Code 会把 Agent frontmatter `skills:` 中列出的 Skill 全文注入 Agent 启动上下文。下面是 Agent 文件与预加载 Skill 文件的原始字节数之和；`B` 是文件的 raw bytes，不是 token，也不包含 Claude Code 系统提示词、工具描述、`CLAUDE.md`、memory、任务消息和 supporting references。

| Agent | Agent 文件 | 预加载 Skill | 启动固定文本合计 |
|---|---:|---:|---:|
| `wechatarticle` | 61,290 B | 154,554 B | **215,844 B** |
| `seednote` | 31,913 B | 110,766 B | **142,679 B** |
| `ecommerce` | 23,377 B | 84,804 B | **108,181 B** |
| `designer` | 20,761 B | 28,481 B | 49,242 B |
| `live-slicer` | 21,133 B | 24,567 B | 45,700 B |
| `moments` | 4,576 B | 39,854 B | 44,430 B |
| `videoeditor` | 4,197 B | 30,704 B | 34,901 B |
| `videocreator` | 4,846 B | 20,409 B | 25,255 B |
| `montage` | 2,954 B | 3,435 B | 6,389 B |

`videocreator` 的数据包含即将迁移的 `seedance-20`，只作为现状记录，不作为本轮优化目标。

## P0：优先处理

### P0-1 降低 Agent 启动固定上下文

证据：

- [`agents/wechatarticle.md`](../agents/wechatarticle.md) `L6-L15` 预加载 9 个 Skill。
- [`agents/seednote.md`](../agents/seednote.md) `L6-L13` 预加载 7 个 Skill。
- [`agents/ecommerce.md`](../agents/ecommerce.md) 预加载总控、分析、文案、humanizer、视觉和合规 Skill。
- Claude Code 官方文档明确说明：`skills:` 注入完整 Skill 内容；未预加载的可发现 Skill 仍可在运行中通过 Skill 工具调用。

问题：

- 阶段 8 才需要的发布 Skill，从 Agent 启动第一轮起就占用上下文。
- `humanizer` 的 34 KB 上游正文被 `wechatarticle`、`seednote`、`ecommerce`、`moments` 全程预加载，但实际只在改写阶段使用。
- 总控 Skill 又包含一套完整业务流程，和 Agent body 重复。
- Skill 全文会在 compaction 后按预算重新附着，固定成本不仅发生一次。

建议：

1. Agent `skills:` 只保留从第一轮起就必须作为系统知识存在的最小 Skill；默认不预加载阶段性 Skill。
2. 专业 Skill 在对应阶段开始时通过 Claude Code 官方 Skill 调用机制按需加载。
3. `humanizer` 保持上游原文不变，但改为写作定稿阶段按需加载。
4. [`docs/plugin-development.md`](./plugin-development.md) 已改为官方 Skill tool 语义；后续 Agent 优化必须沿用该调用机制。
5. `system/init` 继续验证 Skill 可发现和可加载，不把“已安装”错误等同于“必须全部预加载”。

验收：

- 用相同任务比较调整前后的 Agent 启动上下文、总输入 token、turn、成本和耗时。
- 业务成功率、必需产物完整率和质量门槛不得下降。
- 每个阶段的 Skill 调用在 trace 中可观察。

### P0-2 消除 Agent 与总控 Skill 的双轨编排

证据：

- [`agents/wechatarticle.md`](../agents/wechatarticle.md) 和 [`skills/article/SKILL.md`](../skills/article/SKILL.md) 都定义 10 步文章流水线、错误处理、成功标准、红旗清单和任务追踪。
- [`agents/seednote.md`](../agents/seednote.md) 与 [`skills/seednote/SKILL.md`](../skills/seednote/SKILL.md) 都定义项目选择、研究、写作、视觉、合规、归档及参考素材契约。
- [`agents/ecommerce.md`](../agents/ecommerce.md) 与 [`skills/ecommerce/SKILL.md`](../skills/ecommerce/SKILL.md) 都定义产品档案、FABE、视觉生成、合规和归档。

问题：

- 流程顺序、失败语义和 schema 需要多文件同步。
- 同一硬规则在 Agent、总控 Skill、专业 Skill 和 Hook 中各有一份。
- 模型同时看到多套近似契约时，无法可靠判断哪一份优先。

建议采用单一所有权：

- Agent 是端到端流程的唯一所有者。
- 专业 Skill 只拥有一个领域能力，例如选题、写作、视觉、发布或合规。
- `article`、`seednote`、`ecommerce` 总控 Skill 不再保留完整流水线。
- 如果仍需要 `/anban:article` 这类用户入口，把总控 Skill 收缩为薄入口：只描述任务、输入、目标 Agent 和交付预期，不复制流程。
- 实施薄入口前，先用目标 Claude Code 版本验证 `context: fork` + plugin agent 的命名与调用行为；验证不通过时，直接由 Agent 承担入口，不保留第二套编排作为兼容路径。

验收：任一业务规则只能指出一个权威文件。搜索重复规则时，其他位置只能链接或引用该文件，不能复制正文。

### P0-3 统一停止、降级和询问语义

已确认的冲突：

- [`agents/wechatarticle.md`](../agents/wechatarticle.md) `L27` 要求全程零用户交互；`L610`、`L616` 又要求请求用户协助。
- 同文件 `L72` 要求 MCP 失败立即停止；`L628` 要求配置类 MCP 失败后继续流程。
- `L43` 允许非关键步骤跳过；后续多个质量闸门又把部分相同产物设为发布硬条件。

建议每个 Agent 只保留一张失败矩阵：

| 字段 | 含义 |
|---|---|
| `stage` | 失败发生在哪个阶段 |
| `classification` | transient / degradable / blocker / approval-required |
| `retry_budget` | 最大尝试次数，首次是否计入 |
| `fallback` | 允许的替代路径及其质量影响 |
| `required_artifacts` | 停止前必须落盘的证据和状态 |
| `resume_from` | 修复外部条件后从哪个阶段恢复 |
| `user_action` | 用户必须提供的最小信息；没有则不询问 |

专业 Skill 只返回结构化失败和建议，不重新定义整个流程是否继续。Hook 只验证失败状态是否完整，不再发明新的恢复路径。

### P0-4 修正 Hook 生命周期与职责（本轮已完成）

本轮落地结果：

1. [`hooks/hooks.json`](../hooks/hooks.json) 已删除全局 `TaskCompleted` 和所有 completion prompt Hook。插件只为 Seednote、VideoCreator、VideoEditor 注册锚定的 command-only `SubagentStop` quality gate；文件存在、schema、数量和交付一致性由确定性脚本检查。
2. Plugin `SubagentStop` 只覆盖以 subagent 方式启动的 plugin Agent。服务端 managed `--agent` 主会话通过 Claude Agent SDK `Stop` Hook 运行同一组 Seednote/Video gates，并保持 fail-closed。
3. 9 个 Agent 都在最终交付阶段各自调用一次 schema 有效的 `submit_agent_feedback`。最终摘要、Seednote `finalize_task_title` 以及其他需要 MCP/tool 的副作用归 Agent 所有，不再归 Hook 所有。
4. Feedback 服务以 `(task_id, agent_name)` 为业务键 upsert；启动迁移会去重、创建并精确验证唯一索引，失败则阻止服务启动。并发测试证明重复提交收敛到同一行和 canonical ID。
5. `save_template` 只接收真实 MCP schema 字段，并按规范化后的持久字段计算确定性 fingerprint/ID；重复、resume 和并发调用返回同一模板，服务端负责幂等。
6. Seednote 在任何 image planning/generation 前完成 `title_finalization`。归档只调用 [`scripts/archive-seednote-workspace.sh`](../scripts/archive-seednote-workspace.sh)：它复制到外部 sibling staging，比较 relative path、size、SHA-256 manifest，以候选级 reservation 选择后缀并原子发布；失败返回结构化可恢复状态，source 始终保留。

已由结构、迁移、真实并发、归档竞争/失败注入和 Agent 顺序测试覆盖。后续 P0/P1 优化仍包括启动上下文缩减、双轨编排收敛、统一失败矩阵、description 路由、渐进披露、eval、memory 与 `maxTurns`；不得把这些未完成项描述为已由 Hook 修复。

## P1：随后优化

### P1-1 收紧 Agent 与 Skill 的触发描述

高风险描述：

- `wechatarticle` 的“写一篇”过于宽泛，可能截获非公众号写作请求。
- `designer` 的“设计”“color”覆盖范围过大，可能截获普通设计或前端颜色任务。
- `article`、`seednote`、`ecommerce` 总控 Skill 与对应 Agent 使用几乎相同的触发词。

调整原则：

- 描述首句先写唯一职责和目标平台。
- 写清正向触发和一个关键排除项。
- 删除不能提高路由准确率的同义词堆叠。
- 不在 description 中写流程、质量 rubric 或营销式能力介绍。
- 为每个描述建立 should-trigger 与 should-not-trigger 用例。

示例方向：

```yaml
description: >-
  Creates and publishes a complete WeChat Official Account article from a topic
  or brief. Use for 公众号文章 workflows that require research, article files,
  WeChat-safe HTML, images, and a draft. Do not use for generic writing,
  Seednote posts, or standalone cover design.
```

### P1-2 对自研长 Skill 做渐进披露

Claude Code 官方建议保持 `SKILL.md` 在 500 行以内，并把详细参考资料移到 supporting files。当前接近上限的自研 Skill 包括：

- `line-art-coloring`: 494 行；
- `article`: 492 行，但按 P0-2 应优先收缩为薄入口；
- `portrait-pose-variants`: 455 行；
- `short-video-cover`: 377 行；
- `article-visual-design`: 376 行；
- `seednote-visual-design`: 347 行；
- `seednote-writing`: 339 行。

拆分规则：

- `SKILL.md`：触发、输入、输出、核心决策、停止条件、资源导航。
- `references/`：详细方法、schema、rubric、平台规则、长示例。
- `scripts/`：确定性校验和机械转换，执行而不是加载进上下文。
- 只允许一层直接引用；明确说明什么时候读取哪个文件。

`humanizer` 不适用此项，因为它是上游镜像。`seedance-20` 不在本轮范围。

### P1-3 建立 Agent/Skill eval 基线

当前顶层业务 Skill 中，只有即将迁移的 `seedance-20` 带有 eval 资产。自研 Agent 和 Skill 缺少统一的触发与结果评估。

每个 Agent 至少建立：

- 3 个正常任务；
- 2 个硬阻塞任务；
- 2 个应路由到其他 Agent 的负例；
- 1 个恢复或 resume 任务；
- 1 个工具不可用或部分失败任务。

每个 Skill 分开评估：

- **触发质量**：should-trigger / should-not-trigger；
- **输出质量**：with-skill / without-skill 对比；
- **契约质量**：必需字段、文件、证据和失败状态；
- **效率**：输入/输出 token、turn、工具调用、重试、耗时和成本。

Agent 关键指标：

- 正确路由率；
- 端到端完成率；
- 必需产物完整率；
- 质量闸门通过率；
- 禁止 HTTP/绕过 MCP 的违规率；
- 可恢复失败状态完整率；
- 每次成功任务的 token、turn、工具调用和成本。

先用真实代表任务建立 baseline，再做提示词删减。不要把 seedance-20 的 eval 结构直接复制给所有业务；保留统一指标，测试输入和 grader 应由各业务契约决定。

### P1-4 明确 memory 的单一用途

所有 9 个 Agent 都声明 `memory: project`。与此同时，运行时还会：

- 通过 `autoMemoryDirectory` 指向任务本地的项目记忆目录；
- 在工作区写入项目 `CLAUDE.md`，供所有 Skill/Subagent 读取；
- 在任务结束后合并和持久化项目 memory。

这不一定是错误，但必须验证 Claude Code frontmatter memory 与 Anban 的 `autoMemoryDirectory` 是否形成重复注入或两个写入位置。

建议：

1. `CLAUDE.md` 只承载项目定位和稳定约束。
2. 项目 memory 只承载跨任务仍有价值的事实、偏好和经验。
3. 任务过程、原始内容、错误日志和大 JSON 留在 task artifacts，不写 memory。
4. 禁止写入密钥、授权头、私有 URL、用户隐私和未经确认的推断。
5. 为 memory 设置体积、主题、去重和过期规则。
6. 在确定没有双路径前，不批量删除 `memory: project`。

### P1-5 让 `maxTurns` 成为评估结果

当前值跨度很大：`seednote=20`、`wechatarticle=300`、`montage=180`。`wechatarticle` 有实测说明，其他 Agent 的预算依据不一致。

建议：

- 运行时的 `WithMaxTurns` 是全局硬上限，Agent frontmatter 是 Agent 自身上限；文档和测试必须明确最终生效顺序。
- 以成功任务的 P95 turn 加合理恢复余量设置上限。
- 先减少固定上下文和重复步骤，再评估是否需要更高 turn。
- 到达上限时必须写失败阶段、已有产物和恢复入口，不能只返回截断结果。

## P2：治理与维护

### P2-1 建立提示词资产 lint

建议增加只读检查，至少覆盖：

- frontmatter YAML 可解析；
- Agent/Skill name 与目录约定一致；
- description 长度和首句完整；
- 自研 `SKILL.md` 行数阈值；
- referenced supporting files 存在；
- Agent 预加载 Skill 存在；
- plugin Hook matcher 使用锚定的 plugin-scoped Agent 名；
- 同一长规则在多个 prompt 表面重复；
- 明显冲突词组，例如同一文件同时出现“零交互”和“请求用户协助”；
- third-party 与 upstream mirror 跳过自研正文规则，只校验来源、版本和完整性。

### P2-2 建立变更所有权表

| 变更类型 | 权威位置 | 需要同步 |
|---|---|---|
| 业务阶段、恢复语义 | `agents/<name>.md` | Agent eval、相关 Hook |
| 专业方法和输入输出 | `skills/<capability>/SKILL.md` | Skill eval、references |
| MCP schema 与服务端行为 | 服务端 MCP/测试 | Skill 只引用契约 |
| 确定性质量门槛 | Hook script 或服务端测试 | Agent 成功标准引用 |
| 平台规范和违禁词 | 专业 Skill references | 业务流程只声明调用时机 |
| 上游 mirror | third-party 更新流程 | hash/version/parity tests |

### P2-3 更新开发文档

[`docs/plugin-development.md`](./plugin-development.md) 需要在实施时同步更新：

- Agent 不再是“流程、质量、风险和成功标准全部内容”的唯一大文件，而是业务编排所有者；专业细节由 Skill 拥有。
- `skills:` 明确为全文预加载，不是可用 Skill 清单。
- 阶段性 Skill 使用官方 Skill 调用机制按需加载。
- Hook 的 command / prompt 职责和生命周期写清楚。
- third-party Skill、upstream mirror 和自研 Skill 使用不同治理规则。

## 建议实施顺序

### 阶段 0：先建立基线

1. 固定当前 Claude Code 版本、模型、运行时 max turns 和 MCP 工具集。
2. 为 `wechatarticle`、`seednote`、`ecommerce` 采集代表性成功、失败和恢复 trace。
3. 记录质量与效率指标。

### 阶段 1：修 Hook（已完成）

1. 已删除全局 `TaskCompleted` prompt Hook 和 completion prompt Hooks。
2. 已将最终反馈、标题终稿与交付摘要收归 tool-capable Agent。
3. 已将文件/schema/数量检查放入 command quality gate，并为 managed 主 Agent 接入 SDK Stop。
4. 已补充服务端幂等、真实并发、迁移与 Seednote 安全归档验证。

### 阶段 2：单轨编排

按 `wechatarticle` → `seednote` → `ecommerce` 顺序逐个处理：

1. 以 Agent 为流程权威。
2. 收缩或移除总控 Skill 的重复流程。
3. 建立统一失败矩阵。
4. 跑原 baseline，确认行为保持。

### 阶段 3：按需加载

1. 从 Agent `skills:` 移除阶段性 Skill。
2. 在阶段入口显式调用对应 Skill。
3. 先迁移 `humanizer` 和发布/合规类 Skill，再迁移视觉与研究 Skill。
4. 比较启动上下文和端到端指标。

### 阶段 4：触发与渐进披露

1. 收紧 Agent/Skill descriptions。
2. 为长 Skill 拆 supporting files。
3. 加入 trigger eval 和 prompt lint。

### 阶段 5：memory 与 turn 调优

1. 验证 memory 两条路径的实际加载和写回行为。
2. 制定 memory 治理规则。
3. 用 trace 分布调整各 Agent `maxTurns`。

## 完成定义

本轮建议全部落地后，应同时满足：

- 每条业务规则只有一个权威位置；
- Agent 启动固定文本显著下降，且质量基线不下降；
- 阶段性 Skill 按需加载并在 trace 中可观察；
- 一次 Agent 运行只提交一次最终反馈；
- 错误分类、重试、降级、停止和恢复无冲突；
- 自研 Agent/Skill 有正例、负例、失败和恢复 eval；
- third-party 与 upstream mirror 不被自研 lint 误改；
- 所有变更按插件分发规则更新 manifest version、CHANGELOG 和镜像资产。

## 不建议做的事

- 不要一次性重写所有 Agent 和 Skill。
- 不要在没有 baseline 时把“文件更短”当成成功。
- 不要修改 `humanizer` 上游正文来适配业务。
- 不要继续把完整流程复制到 Hook prompt。
- 不要用更高 reasoning effort 或更大 max turns 掩盖矛盾契约。
- 不要把 `seedance-20` 的 third-party 迁移混入本轮自研 Prompt 优化。
