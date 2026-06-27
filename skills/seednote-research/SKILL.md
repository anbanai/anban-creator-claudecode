---
name: seednote-research
description: Analyzes Seednote (种草笔记) topics, trending notes (热门笔记), and scores engagement potential (互动率评分). Use when analyzing Seednote topics, scoring engagement, researching trending seednote content, or fetching source note details for replicate mode. Also use when user mentions '种草笔记选题', '热门笔记', '竞品分析', '笔记分析', or when the seednote pipeline calls for topic discovery or source note fetching.
---

# 种草笔记选题研究

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `claim_topic` (project_id, task_id?) | 从项目选题池认领下一个未用选题（原创模式选题**首选来源**，池非空必用） |
| `list_project_titles` (project_id) | 查看系统内已有标题（定标题前必调） |
| `search_feeds` (keyword) | 搜索相关话题的热门笔记 |
| `list_feeds` () | 获取推荐流 |
| `get_feed_detail` (feed_id, xsec_token) | 获取具体笔记详情+评论数据 |

---

## 完整研究流程

### 步骤 0：确定选题来源（优先选题池，仅原创模式）

> 复刻模式（用户提供笔记 ID/链接）不做选题，直接看下方「复刻模式源笔记获取」专节。

原创模式下，先确定本次笔记选题，**不要凭空搜**。

**如何判断任务是否已指定主题**：检查本任务的 user prompt——
- 含 `create content about: <X>` → `<X>` 就是任务指定主题。
- 是 `research and create content ... choose the optimal theme` 这类让你**自己选题**的措辞 → 任务**未**指定主题。
- ⚠️ 项目 profile 的 keywords **不是**主题。

1. **任务已指定主题**（user prompt 含 `about: <X>`）：**直接采用 `<X>`，禁止调用 `claim_topic`**（避免与服务端预认领重复消费），把它作为步骤 2 的搜索关键词；步骤 4 跳过「选最高分」（评分仅作参考）。
2. **任务未指定主题**：先认领选题池：
   ```
   claim_topic(project_id="$PROJECT_ID", task_id="$TASK_ID")
   ```
   - 返回非空 `topic` → 采用，作为步骤 2 的搜索关键词，步骤 4 不再另选。
   - 返回 `null`（池空）→ 继续下方步骤 1～4 的完整研究流程。

> 选题池是用户预置、希望被优先消费的选题。只要池里有，就必须用池里的。

### 步骤 1：查重

调用 `list_project_titles(project_id="$PROJECT_ID")` 查看已有标题，后续标题避开。

### 步骤 2：搜索热门笔记

根据账号定位和用户需求，确定搜索关键词（2-3 个），调用：

```
search_feeds(keyword="咖啡馆选址")    // 返回 feed_id + xsecToken
list_feeds()                         // 了解平台当前推广内容
```

**xsec_token 工作流**：`feed_id` 和 `xsec_token` 只能从 `search_feeds`/`list_feeds` 的返回结果中提取，不能凭空构造。将这两个值传入 `get_feed_detail` 获取详细数据。

### 步骤 3：分析热门笔记

对搜索结果中的 Top 3-5 条笔记，调用 `get_feed_detail` 获取详情，提取：

- **标题模板**：句式、情绪词、字数分布
- **封面模板**：信息层级、文字密度、配色规律
- **正文模板**：开场钩子、段落结构、结尾 CTA 形式
- **评论信号**：高频关键词、用户痛点、争议点
- **标签组合**：核心话题 + 垂直话题 + 长尾话题

### 步骤 4：评分与选题

使用 2026 小红书 CES 互动评分模型（业界共识权重，2025→2026 未变，字段名直接取自 `get_feed_detail` 返回）：

```
topic_score = engagement_rate × recency_weight × novelty_bonus

# CES 核心原则：深度互动权重远高于浅层互动（关注 > 转发 ≈ 评论 > 收藏 ≈ 点赞）
# 关注(follow)是账号级指标，单条笔记取不到，选题期用点赞/收藏/评论/转发四项
engagement_rate = (like_count×1 + collect_count×1 + comment_count×4 + share_count×4) / max(total, 1)

# 按内容类型差异化核心信号权重（覆盖到上式对应项）
# - 干货 / 教程 / 攻略类：收藏是核心信号 → collect_count 权重 ×3
# - 话题 / 情绪 / 争议类：评论是核心信号 → comment_count×4（已含）
# - 种草 / 好物推荐类：点赞 + 收藏并重（默认权重即可）

recency_weight: 24h→1.0, 7d→0.8, 30d→0.5, 更早→0.3
novelty_bonus: 同角度笔记<3 → 1.2, 否则 → 1.0
```

> **字段缺失降级**：若某条笔记的 `share_count` 取不到（部分接口不返回），按 0 计入并继续评分，**不阻塞流程**；在 `$DIR/topic-analysis.md` 标注数据完整度。为什么这么做：宁可少算一项也不要凭空补数，CES 的评论×4 仍是主导项，足以区分候选优劣。

计算所有候选选题的 `topic_score`，自动选择得分最高者。**为什么用这套权重**：2026 小红书官方 CES 把转发/评论/关注这类"深度互动"权重抬到远高于点赞收藏——旧公式 `(likes + favorites + 2×comments)` 完全漏掉转发、且把评论低估一倍，会让真正有传播潜力的选题（高评论/高转发）排到后面。选题占爆款成败约 50%，这个权重对得越准，选题越接近真实流量潜力。

**产出**：将评分明细与选题理由写入 `$DIR/topic-analysis.md`。

---

## 复刻模式源笔记获取

当用户提供笔记 ID 或链接时，本 skill 只负责获取源笔记详情，不做爆款模板分析：

1. 通过 `search_feeds` 或 `list_feeds` 获取真实返回的 `feed_id` 与 `xsec_token`
2. 调用 `get_feed_detail(feed_id, xsec_token)` 获取源笔记详情、互动数据和评论数据
3. 将原始详情、token 来源、互动数据、评论摘要和数据缺失项写入 `$DIR/source-note.md`
4. 后续由 `seednote-viral-analysis` skill 读取 `$DIR/source-note.md`，生成 `$DIR/source-analysis.md`、`$DIR/viral-template.json`、`$DIR/template-meta.json`

**边界**：不要在本 skill 中提取爆款模板，不要调用 `save_template`，不要生成改写正文。

---

## 产出要求

| 模式 | 产出文件 |
|------|----------|
| 原创模式 | `$DIR/topic-analysis.md`（候选话题列表、评分明细、最终选题理由） |
| 复刻模式 | `$DIR/source-note.md`（源笔记原始详情、互动数据、评论摘要、数据缺失项） |
