# Plugin developer notes

This file defines development boundaries for the Anban Claude Code plugin. It
lives under `docs/` because Claude Code does not load a plugin-root `CLAUDE.md`
as plugin context. Runtime workflow instructions belong in `agents/*.md` or
`skills/*/SKILL.md`.

## Project overview

`anban-creator-claudecode` provides autonomous workflows for WeChat articles,
Seednote posts, live slicing, line-art coloring, video generation and editing,
Montage, Moments, and ecommerce assets. An external Anban MCP server provides
business data and side effects.

## Ownership model (target)

The table below is the target ownership model. This release establishes the
Hook/Agent side-effect boundary: deterministic completion checks belong to
Hooks, while final reports and tool-capable side effects belong to Agents.
Existing umbrella Skills and Agent `skills:` preloads still contain orchestration
overlap; the optimization audit tracks their staged P0-1/P0-2 migration after
representative baselines and evals.

| Surface | Owns |
|---|---|
| Agent | End-to-end business orchestration, stage routing, recovery, success criteria, final report, and stop behavior |
| Skill | One domain capability, its input/output contract, decision rules, and supporting knowledge |
| Hook | Deterministic lifecycle gates or a bounded decision based only on hook input |
| MCP | Tool schema, validation, persistence, and server-side side effects |
| Artifact | File-backed state, evidence, failure details, and resume entrypoints across stages |

Agents must use Claude Code MCP tools for Anban product capabilities. Do not
replace MCP calls with ad hoc HTTP clients. For new changes, keep handlers and
Hooks out of business orchestration, and do not copy a full Agent pipeline into
an umbrella Skill. Do not interpret this rule as claiming the existing overlap
has already been removed.

## Agents

Plugin Agent frontmatter may use supported fields such as `name`, `description`,
`model`, `skills`, `memory`, `tools`, and `maxTurns`. A subagent starts with a
fresh context. Project memory contributes only its first 200 lines or 25 KB at
startup, so large workflow state belongs in task artifacts.

Treat `maxTurns` as a budget to validate against representative traces. The
managed SDK runtime may also impose a limit; verify effective behavior in this
repository before relying on frontmatter alone.

Do not add a `tools` allowlist to agents that need MCP tools; Claude Code treats `tools` as an allowlist and can hide inherited MCP tools from subagents. Omit `tools` unless you intentionally want to restrict an Agent to a narrow allowlist that includes every required MCP tool.

Do not add `mcpServers` to plugin agent frontmatter. Plugin subagents receive MCP servers from the plugin-level `.mcp.json`; Claude Code ignores `permissionMode`, `mcpServers`, and `hooks` in plugin Agent definitions. Managed lifecycle Hooks are installed by the server SDK path.

The nine Agent identities accepted by `submit_agent_feedback` are `designer`,
`ecommerce`, `live-slicer`, `moments`, `montage`, `seednote`, `videocreator`,
`videoeditor`, and `wechatarticle`. Each Agent owns exactly one final feedback
call after its delivery report.

### Designer runtime contract

The line-art workflow uses single-candidate by default, optional 2-candidate
generation when comparison is justified. If strict line preservation is not
possible, the delivery report records `needs_img2img` instead of claiming an
exact colorization. The current `generate_image` path is best-effort
reference-image generation, not a guaranteed line-preserving colorize tool.

## Skills

Every `skills/<name>/SKILL.md` has `name` and `description` frontmatter. Claude
Code keeps each Skill description in discovery context, then loads the Skill
body when invoked. Supporting files are read only when needed; keep self-authored
`SKILL.md` entrypoints under 500 lines and link directly to one-level references.

Agent frontmatter `skills:` is full-text startup injection, not a list of Skills
that are merely available. Several current Agents still preload phase-specific
Skills; do not describe that state as already migrated. The target is to retain
only knowledge required from the first turn, after representative baseline/eval
coverage proves the removal safe, then invoke each phase-specific Skill on
demand through Claude Code's official Skill tool. A discoverable Skill need not
be listed in `skills:` to be invoked.

`context: fork` turns the Skill task into a fresh subagent prompt. Validate its
routing and plugin Agent naming in the target Claude Code release before using
it as an entrypoint. Evaluate Skills in fresh sessions with should-trigger,
should-not-trigger, with-Skill, and without-Skill cases.

## MCP and artifacts

`.mcp.json` connects to `${user_config.api_url}/mcp`; its Authorization header
uses the sensitive `${user_config.api_key}` value. Never print keys, bearer
tokens, private draft URLs, or authorization headers.

MCP owns tool schemas and server-side side effects. In particular:

- `submit_agent_feedback` accepts `task_id`, `agent_name`, `scores` as a JSON
  string, `errors`, `optimizations`, and `summary`. The server upserts on
  `(task_id, agent_name)` and enforces the exact unique index.
- `save_template` accepts its declared visual-template fields only. The server
  normalizes persisted fields and derives a deterministic fingerprint so
  repeated, resumed, or concurrent submissions are idempotent.
- `prepare_workspace` and `archive_workspace` return canonical paths; they do
  not create directories or move files.

Live slicing keeps planning and completion side effects in MCP: use
`build_live_clip_plan` for segment-based clip plans,
`build_live_subject_clip_plan` for subject-based plans,
`build_live_clip_manifest` for the server-backed delivery manifest,
`recognize_live_subjects` for subject discovery, and `complete_live_subject` to
record subject completion. The Agent owns local `ffmpeg` execution and
file-backed evidence around those tool calls.

Task artifacts are the resume contract. Store generated content, manifests,
quality evidence, and structured `failure-state.json` files in the workspace.
Do not place transient logs, large payloads, or secrets in project memory.

## Hook lifecycle

Use Hooks according to the event they actually observe:

- Plugin `SubagentStop` applies to plugin Agents spawned as subagents. Its
  matchers use anchored scoped names such as `^anban:seednote$`.
- Managed main sessions launched with `--agent` are not covered by plugin
  `SubagentStop`; the server installs equivalent Claude Agent SDK `Stop` Hooks.
- Command Hooks perform deterministic file, schema, quantity, and consistency
  checks. Production completion gates should fail closed on script or output
  errors.
- Prompt Hooks make one LLM call and return `ok` or `reason` from hook input.
  They cannot read workspace files or call MCP tools.
- Agent Hooks can use tools and read files, but this project does not use them
  for critical production acceptance. Prefer auditable command gates.
- `TaskCompleted` fires when an individual task item is marked completed and
  does not support matchers. It is not a whole-workflow completion event.

Final summaries, Seednote title finalization, template eligibility decisions,
and `submit_agent_feedback` belong to tool-capable Agent stages. Hooks must not
attempt those side effects.

Command Hooks that reference plugin paths use `command` plus `args`. The
SessionStart bootstrap remains asynchronous so binary preparation does not block
Claude Code startup.

## Seednote finalization and archive

Seednote finalizes the accepted title after writing/humanization and before any
image plan or generation. If final compliance would change that title, it writes
a recoverable failure and resumes from `title_finalization`; it does not archive
visuals produced for a different title.

The Agent calls `scripts/archive-seednote-workspace.sh SOURCE_DIR
PROPOSED_ARCHIVE_DIR`. The script:

- rejects unsafe paths, symlinks, special files, and cross-device publication;
- copies source, including dotfiles, into an external sibling staging directory;
- compares sorted relative-path, size, and SHA-256 manifests;
- reserves each candidate suffix independently and atomically renames verified
  staging into `title`, `title-2`, and so on;
- retains source, skips abandoned reservations without TTL takeover, cleans its
  own temporary resources, and emits one JSON result.

Any nonzero exit, invalid JSON, non-`archived` status, or empty `archive_dir`
becomes `failure-state.json` with `stage=archive` and `resume_from=archive`.
Template saving and success feedback must not run after an archive failure.

## Content and runtime conventions

- All workflows are autonomous. Record decisions in artifacts instead of using
  `AskUserQuestion` from the business Agents.
- Server-appended `运行控制：` keys are structured state. Agents route stages;
  Skills own detailed domain behavior.
- Local live/video processing uses `ffmpeg` and `ffprobe`.
- WeChat HTML must use inline CSS and avoid unsafe tags.
- Number or semantically name task files so delivery and recovery are explicit.

## Asset governance

Classify a Skill before editing it:

- Self-authored assets follow this repository's prompt lint, progressive
  disclosure, eval, ownership, manifest, and changelog rules.
- Upstream mirrors preserve upstream bytes and are updated through source,
  version, and parity checks. `humanizer` remains an unchanged upstream mirror;
  business rules belong in the owning Agent or Skill.
- Third-party runtime assets use their own update and verification process.
  `seedance-20` migration is a separate third-party plan and is out of scope for
  self-authored prompt optimization. `third_party/OpenMontage` remains governed
  as an external runtime/submodule, not copied into Agent text.

## Modifying the plugin

- Add Agents under `agents/<name>.md`; keep workflow/recovery ownership there.
- Add Skills under `skills/<name>/SKILL.md`; move long details into direct
  `references/` files.
- Keep deterministic validation in scripts or server tests.
- Bump `.claude-plugin/plugin.json` and the marketplace plugin entry together,
  and update `CHANGELOG.md` for any distributed runtime or documentation change.
- Validate metadata, run affected contract tests, run `claude plugin validate`,
  and check the final diff before release.
