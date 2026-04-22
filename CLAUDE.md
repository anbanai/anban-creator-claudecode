# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**anbanwriter-claudecode** is a Claude Code plugin for automated Chinese social media content creation. It targets three platforms:

- **WeChat Official Account articles** (微信公众号图文)
- **Xiaohongshu/RedNote posts** (小红书笔记)
- **WeChat "Xiaolvshu" image posts** (小绿书图片帖)
- **Flower photography** (鲜花图片)

The plugin follows an **Agent + Skill + MCP** architecture: Claude Code agents orchestrate end-to-end pipelines, skills encapsulate domain knowledge, and an external MCP server provides WeChat/Xiaohongshu API access.

## Architecture

### Agents (`agents/`)

Orchestration engines that run fully autonomous, zero-interaction pipelines. Each agent has a frontmatter block with `name`, `tools`, `skills`, `mcpServers`, `maxTurns`, and `memory` config. The agent definition is the single source of truth for its pipeline's flow, quality standards, risk mitigation, and success criteria.

| Agent | Trigger | Pipeline |
|-------|---------|----------|
| `wechatarticle` | "写文章", "发文章" | Research → Write → De-AI → SEO → Cover → Illustrations → HTML → Draft |
| `rednote` | "小红书", "种草", "复刻" | Research → Content → Image plan → Cover + Content images → Compliance → Archive |
| `wechatxls` | "小绿书", "图片帖" | Research → Visual style → Image generation → Compliance → Upload → Draft |
| `flower` | "鲜花", "花卉图片" | Flower research → Prompt generation → Batch image generation → Summary |

Agents use TaskCreate/TaskUpdate for progress tracking and report progress as `[N/M] step complete → path (detail)`.

### Skills (`skills/`)

Reusable knowledge modules referenced by agents. Each skill has a `SKILL.md` frontmatter file with `name` and `description`, and optional `references/` subdirectory for detailed guides.

Key skill groups:
- **Content**: `content-writing`, `topic-research`, `seo-optimization`
- **WeChat article**: `article`, `article-visual-design`, `article-publishing`
- **RedNote**: `rednote`, `rednote-research`, `rednote-writing`, `rednote-visual-design`
- **XLS**: `xls`, `xls-visual-design`, `xls-publishing`
- **Flower**: `flower-content-design`, `flower-visual-design`
- **Init**: `init` (first-time setup, key configuration, and connectivity verification)

### MCP Server (`.mcp.json`)

Connects to the `anbanwriter` MCP server at `$ANBANWRITER_API_URL` (default `localhost:18060`). Key MCP tools:
- `list_channels`, `get_account_info`, `list_drafts`, `list_published`, `list_topics`
- `prepare_workspace`, `archive_workspace`
- `write_article`, `convert_markdown`, `humanize_article`
- `image upload`, `draft article`, `draft xls`
- `get_feed_detail` (RedNote source note fetching)

### Themes (`themes/`)

YAML files defining visual styling for article排版. Each has `name`, `type` (api), `description`, and `api_theme`. Themes are referenced by the MCP server's article publishing tools.

### Writers (`writers/`)

YAML files defining writing styles. Each has `name`, `english_name`, `writing_prompt` (required), plus optional `cover_prompt`, `core_beliefs`, `title_formulas`. Built-in styles: `dan-koe`, `cultural-depth`, `casual-science`.

### Hooks (`hooks/hooks.json`)

Lifecycle hooks for quality verification:
- **SubagentStop**: Agent-specific delivery summaries checking output files, draft status, and completeness
- **TaskCompleted**: Generic quality verification (file existence, format compliance)

## Key Conventions

- **Zero user interaction**: All agents run autonomously. Decisions are recorded in `$DIR/*.md` files, never by asking the user.
- **Workspace isolation**: Each creation task uses `prepare_workspace` MCP tool to create an isolated `$DIR` under `output/{content_type}/`, with auto-archive of residual files.
- **File naming**: Agents use numbered prefixes (`01-research.md`, `02-outline.md`...) or semantic names (`cover.png`, `content.md`, `image-plan.md`).
- **Image reference chain**: First image establishes visual style; subsequent images use the first as `--ref` to maintain consistency.
- **Skill references**: Agents invoke skills via `using the <skill-name> skill` phrasing, not the Skill tool.
- **Content is Chinese**: All generated content targets Chinese social media platforms. Prohibited words lists (违禁词) are in `references/prohibited-words.md`.

## Modifying This Plugin

- **Adding a new agent**: Create `agents/<name>.md` with frontmatter (name, tools, skills, mcpServers, maxTurns) and pipeline definition following existing agent structure.
- **Adding a new skill**: Create `skills/<name>/SKILL.md` with frontmatter name/description. Add `references/` for detailed guides.
- **Adding a new theme**: Add `themes/<name>.yaml` with `name`, `type: api`, `api_theme`, `description`.
- **Adding a new writer style**: Add `writers/<name>.yaml` with required `name`, `english_name`, `writing_prompt`.
