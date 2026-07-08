# Plugin developer notes

This file is development guidance for the Anban Claude Code plugin distribution.
It intentionally lives under `docs/` because Claude Code does not load a
plugin-root `CLAUDE.md` as plugin context. Runtime guidance belongs in
`agents/*.md` or `skills/*/SKILL.md`.

## Project Overview

**anban-creator-claudecode** is a Claude Code plugin for automated Chinese social media content creation. It targets these workflows:

- **WeChat Official Account articles** (微信公众号图文)
- **SeedNote posts** (种草笔记)
- **Live video slicing** (直播切片)
- **Line art coloring** (线稿上色)
- **AI video generation** (视频生成、即梦、Seedance、图生视频、参考图/参考视频生成)
- **Video editing and post-production** (素材剪辑、字幕、去口癖、调色、剪映草稿、成片交付)
- **E-commerce product imagery** (电商出图：主图/详情/封面/分享/SKU，多产品图输入保一致)

The plugin follows an **Agent + Skill + MCP** architecture: Claude Code agents orchestrate end-to-end pipelines, skills encapsulate domain knowledge, and an external MCP server provides WeChat/Seednote API access.

## Architecture

### Agents (`agents/`)

Orchestration engines that run fully autonomous, zero-interaction pipelines. Each agent has a frontmatter block with `name`, `skills`, `maxTurns`, and `memory` config. The agent definition is the single source of truth for its pipeline's flow, quality standards, risk mitigation, and success criteria. Do not add a `tools` allowlist to agents that need MCP tools; Claude Code treats `tools` as an allowlist and can hide inherited MCP tools from subagents.

Do not add `mcpServers` to plugin agent frontmatter. Plugin subagents receive MCP servers from the plugin-level `.mcp.json`; Claude Code ignores `mcpServers` inside plugin agent frontmatter.

| Agent | Trigger | Pipeline |
|-------|---------|----------|
| `wechatarticle` | "写文章", "发文章" | Research → Write → De-AI → SEO → Cover → Illustrations → HTML → Draft |
| `seednote` | "种草笔记", "种草", "复刻" | Research → Viral analysis (replicate) → Content → Image plan → Cover + Content images → Compliance → Archive |
| `live-slicer` | "直播切片", "剪直播", "听悟" | ffmpeg prep → TingWu transcription → Invalid sentence filter → Segment/subject planning → Batch cuts/concat → CapCut export → Report |
| `designer` | "上色", "填色", "线稿", "color consistency", "designer" | Init → Progressive coloring (single-candidate by default, optional 2-candidate) → Full audit → Best-effort correction/backtracking → Report with `needs_img2img` where strict line preservation is impossible |
| `videocreator` | "视频生成", "即梦", "Seedance", "图生视频", "参考图/参考视频生成" | seedance-20 generation planning → MCP video generation → Download/register final video → Quality review |
| `videoeditor` | "剪视频", "字幕", "剪映草稿", "去口癖", "调色", "成片交付" | video-use media audit → Transcript/EDL → Preview/final render or CapCut draft → Quality review |
| `ecommerce` | "电商出图", "电商素材", "商品图", "产品图", "主图", "详情页", "商详", "SKU图", "电商封面" | Product Bible (analyze product photos) → Selling points (FABE) → Asset plan → Anchor-first generation with provider-adaptive ref strategy (image_model from task) + vision self-check (max 3 rounds) → Compliance (广告法极限词) → Archive + manifest |

Agents use TaskCreate/TaskUpdate for progress tracking and report progress as `[N/M] step complete → path (detail)`.

### Skills (`skills/`)

Reusable knowledge modules referenced by agents. Each skill has a `SKILL.md` frontmatter file with `name` and `description`, and optional `references/` subdirectory for detailed guides.

Key skill groups:
- **Content**: `content-writing`, `topic-research`, `seo-optimization`
- **WeChat article**: `article`, `article-visual-design`, `article-publishing`
- **SeedNote**: `seednote`, `seednote-research`, `seednote-viral-analysis`, `seednote-writing`, `seednote-visual-design`
- **Live slicing**: `live-slice`, `capcut-draft`
- **Design**: `line-art-coloring`
- **Video**: `seedance-20`, `dreamina-video` (compatibility alias), `video-use`, `short-video-cover`, `portrait-pose-variants`, `capcut-draft`
- **E-commerce**: `ecommerce`, `ecommerce-product-analysis`, `ecommerce-copywriting`, `ecommerce-visual-design`, `ecommerce-platform-specs` (bespoke to e-commerce — buyer audience, conversion goals; does NOT reuse seednote/designer skill content)
- **Setup**: `anban-setup` (first-time setup, key configuration, and connectivity verification)

### MCP Server (`.mcp.json`)

Connects to the `anban-creator` MCP server at `${user_config.api_url}/mcp` (default `https://api.creator.anbanai.com/mcp`). The `Authorization` header uses the sensitive `${user_config.api_key}` value declared in `.claude-plugin/plugin.json`; agents and docs must never print the key value.

Key MCP tools:
- `$ANBAN_DEFAULT_PROJECT`: Optional default project ID. When set, agents skip `list_projects` and use this directly.
- `list_projects`, `get_project_profile`, `list_drafts`, `list_published_articles`, `list_project_titles`
- `prepare_workspace`, `archive_workspace`
- `render_template`, `convert_markdown`
- `image upload`, `draft article`
- `get_feed_detail` (SeedNote source note fetching)
- `upload_live_audio`, `create_live_analysis_task`, `query_live_analysis_task`, `recognize_live_invalid_sentences`, `recognize_live_segments`, `build_live_clip_plan`, `build_live_subject_clip_plan`, `build_live_clip_manifest`, `recognize_live_subjects`, `complete_live_subject`
- `prepare_file_upload`, `create_video_asr_task`, `query_video_asr_task`, `pack_video_transcripts`

### Themes (Server-managed)

Themes define visual styling for article排版. Themes are managed server-side via the MCP server's `convert_markdown` tool. Each project has a configured theme that is applied automatically during Markdown-to-WeChat-HTML conversion.

### Writers (`writers/`)

YAML files defining **writing** styles (the writer dimension only). Each has `name`, `english_name`, `writing_prompt` (required), plus optional `core_beliefs`, `title_formulas`, `quote_templates`. Writers **do not** carry visual identity — image visual style is an orthogonal dimension configured per project/task (see `article-visual-design` skill). Built-in styles: `dan-koe`, `cultural-depth`, `casual-science`.

### Hooks (`hooks/hooks.json`)

Lifecycle hooks for quality verification:
- **SubagentStop**: Agent-specific delivery summaries checking output files, draft status, and completeness
- **TaskCompleted**: Generic quality verification (file existence, format compliance)

Command hooks that reference plugin paths use exec form (`command` plus `args`) rather than shell-form quoting. The SessionStart bootstrap hook is async so binary preparation does not block Claude Code startup.

Plugin agent hook matchers use Claude Code's plugin-scoped agent type, for example `anban:seednote`, not the bare frontmatter name `seednote`. Hook scripts may accept both forms for local compatibility, but plugin `hooks.json` must use the scoped matcher.

## Key Conventions

- **Zero user interaction**: All agents run autonomously. Decisions are recorded in `$DIR/*.md` files, never by asking the user.
- **Runtime controls**: The server may append a compact `运行控制：` block to the user message, for example `article_image_mode=cover_only` or `seednote_image_mode=cover_content`. Treat these keys as structured state, not prose. Agents route pipeline steps from the keys, skills define the detailed skip/quality/publishing semantics, and server-side Go code should not embed long workflow instructions that duplicate agent or skill documents.
- **Workspace isolation**: Each creation task calls `prepare_workspace` MCP tool to obtain the canonical workspace path, then creates the directory locally with `mkdir -p`. The MCP tool only computes and returns the path — it does not create directories or move files.
- **File naming**: Agents use numbered prefixes (`01-research.md`, `02-outline.md`...) or semantic names (`cover.png`, `content.md`, `image-plan.md`).
- **Image reference chain**: First image establishes visual style; subsequent images use the first as reference to maintain consistency. For line-art coloring, current `generate_image` is best-effort reference-image generation, not a guaranteed line-preserving colorize tool.
- **Skill references**: Agents invoke skills via `using the <skill-name> skill` phrasing, not the Skill tool.
- **Content is Chinese**: All generated content targets Chinese social media platforms. Prohibited words lists (违禁词) are in `references/prohibited-words.md`.
- **Video media dependency**: `live-slicer`, `live-slice`, and `video-use` require local `ffmpeg` and `ffprobe`; `video-use` uses Aliyun FunASR HTTP MCP tools for word-level ASR.
- **Secret handling**: Never print API keys, bearer tokens, private draft URLs, or MCP Authorization headers. Diagnostics may state whether a sensitive value is present.

## Modifying This Plugin

- **Adding a new agent**: Create `agents/<name>.md` with frontmatter (name, skills, maxTurns) and pipeline definition following existing agent structure. Omit `tools` unless you intentionally want to restrict the agent to a small allowlist that includes every required MCP tool. Omit `mcpServers`; plugin agents inherit the plugin-level `.mcp.json`.
- **Adding a new skill**: Create `skills/<name>/SKILL.md` with frontmatter name/description. Keep `SKILL.md` concise; move long examples, rubrics, and implementation details into one-level `references/` files.
- **Adding a new theme**: Themes are managed server-side. Contact the server admin to add new themes.
- **Adding a new writer style**: Add `writers/<name>.yaml` with required `name`, `english_name`, `writing_prompt`.
- **Changing distribution assets**: Bump `.claude-plugin/plugin.json` in the same change and update `CHANGELOG.md`. Security-sensitive changes should also review `SECURITY.md`; contributor-facing process changes should update `CONTRIBUTING.md`.
