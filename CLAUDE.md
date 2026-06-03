# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**anbanwriter-claudecode** is a Claude Code plugin for automated Chinese social media content creation. It targets these workflows:

- **WeChat Official Account articles** (微信公众号图文)
- **SeedNote posts** (种草笔记)
- **Live video slicing** (直播切片)

The plugin follows an **Agent + Skill + MCP** architecture: Claude Code agents orchestrate end-to-end pipelines, skills encapsulate domain knowledge, and an external MCP server provides WeChat/Seednote API access.

## Architecture

### Agents (`agents/`)

Orchestration engines that run fully autonomous, zero-interaction pipelines. Each agent has a frontmatter block with `name`, `tools`, `skills`, `mcpServers`, `maxTurns`, and `memory` config. The agent definition is the single source of truth for its pipeline's flow, quality standards, risk mitigation, and success criteria.

| Agent | Trigger | Pipeline |
|-------|---------|----------|
| `wechatarticle` | "写文章", "发文章" | Research → Write → De-AI → SEO → Cover → Illustrations → HTML → Draft |
| `seednote` | "种草笔记", "种草", "复刻" | Research → Viral analysis (replicate) → Content → Image plan → Cover + Content images → Compliance → Archive |
| `live-slicer` | "直播切片", "剪直播", "听悟" | ffmpeg prep → TingWu transcription → Invalid sentence filter → Segment/subject planning → Batch cuts/concat → CapCut export → Report |

Agents use TaskCreate/TaskUpdate for progress tracking and report progress as `[N/M] step complete → path (detail)`.

### Skills (`skills/`)

Reusable knowledge modules referenced by agents. Each skill has a `SKILL.md` frontmatter file with `name` and `description`, and optional `references/` subdirectory for detailed guides.

Key skill groups:
- **Content**: `content-writing`, `topic-research`, `seo-optimization`
- **WeChat article**: `article`, `article-visual-design`, `article-publishing`
- **SeedNote**: `seednote`, `seednote-research`, `seednote-viral-analysis`, `seednote-writing`, `seednote-visual-design`
- **Live slicing**: `live-slice`, `capcut-draft`
- **Init**: `init` (first-time setup, key configuration, and connectivity verification)

### MCP Server (`.mcp.json`)

Connects to the `anbanwriter` MCP server at `$ANBANWRITER_API_URL` (default `https://api.creator.anbanai.com`). Key MCP tools:
- `$ANBANWRITER_DEFAULT_CHANNEL`: Optional default channel ID. When set, agents skip `list_channels` and use this directly.
- `list_channels`, `get_channel_profile`, `list_drafts`, `list_published_articles`, `list_channel_titles`
- `prepare_workspace`, `archive_workspace`
- `write_article`, `convert_markdown`, `humanize_article`
- `image upload`, `draft article`
- `get_feed_detail` (SeedNote source note fetching)
- `upload_live_audio`, `create_live_analysis_task`, `query_live_analysis_task`, `recognize_live_invalid_sentences`, `recognize_live_segments`, `build_live_clip_plan`, `build_live_subject_clip_plan`, `build_live_clip_manifest`, `recognize_live_subjects`, `complete_live_subject`

### Themes (Server-managed)

Themes define visual styling for article排版. Themes are managed server-side via the MCP server's `convert_markdown` tool. Each channel has a configured theme that is applied automatically during Markdown-to-WeChat-HTML conversion.

### Writers (`writers/`)

YAML files defining writing styles. Each has `name`, `english_name`, `writing_prompt` (required), plus optional `cover_prompt`, `core_beliefs`, `title_formulas`, `quote_templates`. Built-in styles: `dan-koe`, `cultural-depth`, `casual-science`.

### Layout Modules (`layouts/`)

YAML files defining structured article layout modules (callout, steps, timeline, metrics, CTA, etc.). Agents use these as reference when writing articles to add visual richness. Each module specifies `when_to_use`, `markdown_syntax`, and concrete `example`. All modules use standard Markdown syntax (not md2wechat's `:::` fenced blocks) that the server-side LLM converter interprets and renders as WeChat HTML.

### Image Prompt Presets (`prompts/image/`)

YAML files defining reusable image generation prompt templates for covers and infographics. Each preset has `{{VARIABLES}}` that agents fill with article context. Categories: cover presets (default, hero, metaphor, editorial, minimal) and infographic presets (comparison, timeline, process, bento, handdrawn).

### Hooks (`hooks/hooks.json`)

Lifecycle hooks for quality verification:
- **SubagentStop**: Agent-specific delivery summaries checking output files, draft status, and completeness
- **TaskCompleted**: Generic quality verification (file existence, format compliance)

## Key Conventions

- **Zero user interaction**: All agents run autonomously. Decisions are recorded in `$DIR/*.md` files, never by asking the user.
- **Workspace isolation**: Each creation task calls `prepare_workspace` MCP tool to obtain the canonical workspace path, then creates the directory locally with `mkdir -p`. The MCP tool only computes and returns the path — it does not create directories or move files.
- **File naming**: Agents use numbered prefixes (`01-research.md`, `02-outline.md`...) or semantic names (`cover.png`, `content.md`, `image-plan.md`).
- **Image reference chain**: First image establishes visual style; subsequent images use the first as `--ref` to maintain consistency.
- **Skill references**: Agents invoke skills via `using the <skill-name> skill` phrasing, not the Skill tool.
- **Content is Chinese**: All generated content targets Chinese social media platforms. Prohibited words lists (违禁词) are in `references/prohibited-words.md`.
- **Live slicing media dependency**: `live-slicer` and `live-slice` require local `ffmpeg` and `ffprobe`; they support continuous clips and subject-script multi-part concat clips without a local helper runtime.

## Modifying This Plugin

- **Adding a new agent**: Create `agents/<name>.md` with frontmatter (name, tools, skills, mcpServers, maxTurns) and pipeline definition following existing agent structure.
- **Adding a new skill**: Create `skills/<name>/SKILL.md` with frontmatter name/description. Add `references/` for detailed guides.
- **Adding a new theme**: Themes are managed server-side. Contact the server admin to add new themes.
- **Adding a new writer style**: Add `writers/<name>.yaml` with required `name`, `english_name`, `writing_prompt`.
- **Adding a new layout module**: Add `layouts/<name>.yaml` with `name`, `category`, `serves`, `description`, `when_to_use`, `markdown_syntax`, and `example`.
- **Adding a new image prompt preset**: Add `prompts/image/<name>.yaml` with `name`, `kind: image`, `archetype`, `primary_use_case`, `variables`, and `template`.
