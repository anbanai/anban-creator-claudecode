# Changelog

All notable changes to the Anban Creator Claude Code plugin are documented here.

This project follows semantic versioning for the plugin package. Patch releases cover documentation, compatibility, hook, and workflow contract fixes that do not change the public agent or MCP behavior.

## [2.10.41] - 2026-07-08

### Changed

- Split the unified video agent into dedicated `videocreator` and `videoeditor` agents with separate hooks, quality gates, and feedback identities.
- Refined the Seednote visual workflow into a model-image-first methodology with content distillation, visual strategy, Prompt blueprints, generation records, quality review, and recoverable image API failure reporting.

## [2.10.40] - 2026-07-08

### Changed

- Added Stable Video Generation V2 guardrails to the video generation workflow and Seedance 2.0 Skill OS: `prepare_video_generation_inputs`, strict remake triggers, fail-closed user references, reference timelines, and multi-segment compose-before-delivery.

## [2.10.39] - 2026-07-08

### Changed

- Removed the experimental rendered-card visual route from Claude, Codex, and OpenClaw distributions so image workflows use the standard platform visual-design skills.
- Simplified the moments workflow contract around the three required text artifacts: `material-analysis.md`, `content.md`, and `quality-review.md`.

## [2.10.38] - 2026-07-07

### Changed

- Unified Studio video intake around `video_input` and the `video` agent, leaving business playbook, mode, subject, audience, and message decisions to the Seedance/video skills.
- Documented that video task creation charges only the base task fee; `video_gen` provider costs are deducted by MCP execution.

## [2.10.37] - 2026-07-07

### Changed

- Normalized distributed Skill descriptions to start with explicit invocation conditions so Claude can decide when to load them from frontmatter.
- Added contents sections to long Skill references and linked long top-level references directly from each Skill entrypoint for one-level progressive disclosure.

## [2.10.36] - 2026-07-07

### Changed

- Added the `moments` completion review hook so 朋友圈素材包 runs verify required artifacts, evidence boundaries, and feedback submission.

## [2.10.35] - 2026-07-07

### Changed

- Moved auxiliary skill README content into `references/` files so shipped skills follow Agent Skills progressive-disclosure packaging guidance.
- Added a mirrored `agent-reach` boundary skill and tightened plugin agent skill-path contracts so Seednote research uses real Agent-Reach backends without missing local skill references.

## [2.10.34] - 2026-07-07

### Added

- Added the independent `moments` Agent and mirrored `moments` skill for WeChat Moments / 朋友圈素材包 generation.
- Documented the Caihui public-method reference boundary and fixed required artifacts.

## [2.10.33] - 2026-07-07

### Changed

- Added an experimental rendered-card skill for Seednote/WeChat visual workflows.
- Documented the upstream adapter posture without vendoring external templates, scripts, validators, or assets.

## [2.10.32] - 2026-07-07

### Changed

- Expanded the video editing workflow around file-based video transcripts, local `anban video` rendering, overlay/subtitle QC, and no nested agent delegation.
- Added contract coverage that keeps the Claude Code plugin manifest version represented in this changelog.

## [2.10.31] - 2026-07-07

### Documentation

- Added a Skill upstream-source and batch-update index to the README, covering copied/adapted open-source skills, structural references, mirror synchronization, and validation commands.

## [2.10.30] - 2026-07-07

### Changed

- Added a human-readable Claude Code plugin display name for plugin UI surfaces.
- Removed `AskUserQuestion` from the humanizer skill's preapproved tools so autonomous writing pipelines stay zero-interaction by default.
- Added contract coverage for Claude Code plugin, agent, hook, and skill best-practice constraints.

## [2.10.27] - 2026-07-06

### Changed

- Moved WeChat article preflight ownership into skills and agents, with anti-diversion review, automatic adjustment loops, and visual prompt guards for QR/contact/link cues.
- Removed the `inspect_article` MCP preflight path from the article workflow.
- Routed Seednote external Xiaohongshu research through Agent-Reach doctor/backend selection, with Anban-managed OpenCLI/xiaohongshu-mcp install guidance removed from the main flow.

## [2.10.24] - 2026-07-06

### Documentation

- Added progressive `references/examples.md` case libraries for complex workflow skills, following Anthropic Skill disclosure patterns and GitHub high-star skill repository structures.

## [2.10.23] - 2026-07-06

### Changed

- Switched Claude Code hook commands that reference plugin paths to exec-form command declarations with `args`.
- Marked the bootstrap hook as asynchronous so Claude Code session startup is not blocked by background binary preparation.
- Updated SubagentStop hook matchers to use plugin-scoped Claude Code agent names.
- Updated agent diagnostics to test whether `ANBAN_API_KEY` exists without printing the secret value.
- Added GitHub health files for contribution and vulnerability reporting.
- Trimmed the line-art coloring skill entrypoint to stay under the official Claude Code Skill size guideline while keeping detailed guidance in `references/`.

### Documentation

- Clarified release, security, and plugin-maintenance practices for the Claude Code distribution.

## [2.10.22] - 2026-07-05

### Changed

- Previous Claude Code plugin release.
