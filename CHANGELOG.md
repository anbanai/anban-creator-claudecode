# Changelog

All notable changes to the Anban Creator Claude Code plugin are documented here.

This project follows semantic versioning for the plugin package. Patch releases cover documentation, compatibility, hook, and workflow contract fixes that do not change the public agent or MCP behavior.

## [2.10.35] - 2026-07-07

### Changed

- Moved auxiliary skill README content into `references/` files so shipped skills follow Agent Skills progressive-disclosure packaging guidance.
- Added a mirrored `agent-reach` boundary skill and tightened plugin agent skill-path contracts so Seednote research uses real Agent-Reach backends without missing local skill references.

## [2.10.34] - 2026-07-07

### Added

- Added the independent `moments` Agent and mirrored `moments` skill for WeChat Moments / 朋友圈素材包 generation.
- Documented the Caihui public-method reference boundary, fixed required artifacts, and optional `guizang-social-card` visual handoff.

## [2.10.33] - 2026-07-07

### Changed

- Added the Anban-native `guizang-social-card` skill and routed Seednote/WeChat visual workflows to opt-in rendered social-card assets through `register_rendered_image`.
- Documented the upstream AGPL-3.0 adapter posture without vendoring upstream templates, scripts, validators, or assets.

## [2.10.32] - 2026-07-07

### Changed

- Expanded the `videoeditor` agent workflow around file-based video transcripts, local `anban video` rendering, overlay/subtitle QC, and no nested agent delegation.
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
