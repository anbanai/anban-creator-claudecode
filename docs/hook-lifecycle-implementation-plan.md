# Claude Code Hook Lifecycle Correction: Implemented Plan

> Final implementation record, updated 2026-07-15. All checkboxes describe
> changes already implemented and verified in the feature worktree.

## Goal

Make completion gates run on lifecycles they can observe, give every tool side
effect one tool-capable owner, and make retries, resume, concurrency, migration,
and Seednote archive publication safe and idempotent.

## Final architecture

```text
plugin Agent as subagent
  -> plugin SubagentStop
  -> deterministic command quality gate

managed main --agent session
  -> Claude Agent SDK Stop
  -> same deterministic command quality gate

Agent final stage
  -> final report
  -> title/template decisions and MCP side effects
  -> one valid submit_agent_feedback call

server
  -> exact business-key/fingerprint idempotency
  -> migration and startup fail-fast

Artifact / archive script
  -> evidence and recoverable state
  -> verified staging + reserved atomic publication
```

Prompt Hooks are not used for workspace inspection or MCP actions. Plugin Agent
frontmatter cannot provide this managed-main lifecycle because Claude Code
ignores plugin Agent `hooks`; managed Stop registration therefore remains in the
server SDK path.

## Scope

Included:

- command-only plugin `SubagentStop` gates for Seednote, VideoCreator, and
  VideoEditor;
- equivalent managed SDK `Stop` gates;
- exactly one schema-valid feedback call in each of 9 Agents;
- Agent-owned Seednote title finalization before visual work;
- feedback and template server idempotency under retries and concurrency;
- safe, verified, suffix-reserved Seednote archive publication;
- contract, migration, concurrency, and failure-injection tests;
- plugin documentation and release metadata.

Excluded:

- startup Skill preload reduction and Agent/umbrella-Skill deduplication;
- memory and `maxTurns` tuning;
- new gates for Agent types without an existing deterministic script;
- `seedance-20` changes or its future third-party migration;
- `humanizer` body changes; it remains an unchanged upstream mirror;
- `third_party/OpenMontage` changes;
- Codex/OpenClaw lifecycle redesign.

## Files changed

These lists use exclusive, reproducible baselines:

- Parent repository: `437b770de15064129e53c165145175d8e6168f4b`
  was `HEAD` immediately before Task 1. Reproduce the parent list with
  `git diff --name-only 437b770de15064129e53c165145175d8e6168f4b..HEAD`.
- Claude plugin repository: `4b37de4a89fdd80f0d41564fbb2c2a5c58681a17`
  was the plugin `HEAD` before this correction. From the parent root, reproduce
  the plugin list with
  `git -C claudecode diff --name-only 4b37de4a89fdd80f0d41564fbb2c2a5c58681a17..HEAD`.

`server/mcp/tools_test.go` was changed by the pre-existing parent baseline
commit `437b770d` (`fix(mcp): enforce task file ownership`). Because that change
is part of the baseline itself, not this lifecycle correction, it is not listed
below. `server/mcp/tools.go` did change after the baseline and remains included.

Claude plugin repository:

- `hooks/hooks.json`
- `agents/designer.md`
- `agents/ecommerce.md`
- `agents/live-slicer.md`
- `agents/moments.md`
- `agents/montage.md`
- `agents/seednote.md`
- `agents/videocreator.md`
- `agents/videoeditor.md`
- `agents/wechatarticle.md`
- `skills/seednote/SKILL.md`
- `scripts/archive-seednote-workspace.sh`
- `docs/plugin-development.md`
- `docs/gpt-5.6-prompt-guidance.md`
- `docs/agent-skill-optimization-audit.md`
- `docs/hook-lifecycle-implementation-plan.md`
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `CHANGELOG.md`

Parent repository runtime and contracts:

- `claudecode` (gitlink)
- `server/agent/managed_hooks.go`
- `server/agent/managed_hooks_test.go`
- `server/agent/claude_plugin_best_practices_test.go`
- `server/agent/moments_contract_test.go`
- `server/agent/video_contract_test.go`
- `server/agent/seednote_archive_script_test.go`
- `server/agent/plugin_binary_contract_test.go`
- `server/mcp/live_slice_skill_test.go`
- `server/mcp/seednote_hook_test.go`
- `server/mcp/agent_feedback_tools.go`
- `server/mcp/template_tools.go`
- `server/mcp/template_tools_test.go`
- `server/mcp/tools.go`
- `server/mcp/video_use_skill_test.go`
- `server/model/agent_feedback.go`
- `server/model/agent_feedback_migrate.go`
- `server/model/agent_feedback_migrate_test.go`
- `server/model/model.go`
- `server/repository/agent_feedback.go`
- `server/service/agent_feedback.go`
- `server/service/agent_feedback_test.go`
- `server/service/template.go`
- `server/service/template_test.go`
- `server/service/task.go`
- `server/main.go`
- `server/main_test.go`

## Implementation result

### 1. Lifecycle ownership

- [x] Removed the completion prompt Hooks and global `TaskCompleted` entry.
- [x] Kept anchored plugin `SubagentStop` command gates for
  `^anban:seednote$`, `^anban:videocreator$`, and
  `^anban:videoeditor$`.
- [x] Added one managed gate map that installs the same scripts as SDK `Stop`
  callbacks for main `--agent` sessions.
- [x] Preserved fail-closed behavior for missing scripts, command failures, and
  invalid Hook JSON.
- [x] Left unsupported task types without a Stop gate.

### 2. Valid feedback ownership

- [x] Required exactly one documented `submit_agent_feedback(...)` expression
  in each of the 9 Agent bodies, with the exact Agent name.
- [x] Validated argument names against the MCP schema: `task_id`, `agent_name`,
  `scores`, `errors`, `optimizations`, and `summary`.
- [x] Kept `scores` as a valid JSON string and rejected unsupported fields,
  ellipses, malformed calls, or calls before the delivery anchor.
- [x] Moved final report and feedback responsibility into the Agent stage; no
  Hook performs that side effect.

### 3. Feedback persistence idempotency

- [x] Defined `(task_id, agent_name)` as the feedback business key.
- [x] Added `idx_agent_feedback_task_agent` as a unique composite index with
  exact column order.
- [x] Added a bounded migration that detects malformed legacy indexes,
  deterministically keeps the newest duplicate, creates the correct index, and
  verifies its shape.
- [x] Made startup run this migration and fail fast if it cannot establish the
  contract.
- [x] Changed writes to conflict-update mutable feedback fields and then return
  the canonical row, so sequential and concurrent retries share one ID.

### 4. Template idempotency

- [x] Limited `save_template` to its declared fields: `type`, `name`,
  `category`, `style_prompt`, and `tags`.
- [x] Normalized whitespace, newlines, deduplicated/sorted tags, and the derived
  name before fingerprinting.
- [x] Derived a deterministic UUID from the normalized persisted payload.
- [x] Returned the existing canonical template on retry/resume/concurrent
  creation and rejected a fingerprint collision with different persisted data.
- [x] Made created/existing status independent of unreliable affected-row
  reporting.

### 5. Seednote title order

- [x] Added `title_finalization` after writing and humanization but before image
  planning or generation.
- [x] Allowed at most three duplicate-title attempts, updating `content.md`,
  re-running title humanization/compliance, and retrying the server call.
- [x] Wrote structured recoverable failures for non-duplicate errors or retry
  exhaustion and stopped before visual/template/archive stages.
- [x] Required all later artifacts to use the server-accepted title.
- [x] If final compliance requires a title change after visuals, failed
  recoverably and resumed from title finalization so visuals are regenerated.

### 6. Verified archive protocol

- [x] Added executable `scripts/archive-seednote-workspace.sh` with strict mode
  and a single JSON result contract.
- [x] Resolved and constrained source/destination paths to the workspace root;
  rejected control characters, symlinks, special files, and cross-device
  publication.
- [x] Copied all source entries, including dotfiles, to an external sibling
  staging directory and excluded an archive root nested below source.
- [x] Compared source and staging using sorted relative path, file size, and
  SHA-256 manifests before publication.
- [x] Used per-candidate reservation directories for suffix selection. An
  abandoned reservation is skipped, never stolen by TTL.
- [x] Published verified staging by same-filesystem atomic rename and detected
  an external destination race by inode identity.
- [x] Retained source on success and failure, cleaned only owned temporary state,
  and surfaced stable recoverable error codes.
- [x] Made template saving conditional on successful archive publication.

## Verification implemented

Contract and lifecycle tests cover:

- plugin Hook JSON roles, anchored matchers, and command scripts;
- all managed gate mappings, unsupported task types, and fail-closed outputs;
- 9-Agent feedback parsing, exact ownership, argument schema, order, and summary
  requirements;
- Seednote title-finalization order, duplicate retries, failure-state fields,
  final report order, template fields, and archive protocol.

Persistence tests cover:

- feedback sequential retry, trimmed keys, unique constraint, and true
  concurrent upsert against a file-backed SQLite database;
- malformed-index replacement, legacy deduplication, exact index inspection,
  migration retry/failure, and startup fail-fast;
- template normalization, deterministic IDs, resume, collision protection,
  true concurrent creation, and affected-row edge cases.

Archive tests execute the real script and cover:

- dotfiles, nested directories, existing suffixes, true concurrent writers, and
  a paused writer with another publisher;
- copy/hash/rename failures, unsafe paths and file types, nested archive roots,
  abandoned reservations, destination races, JSON results, source retention,
  and temporary-resource cleanup.

Release verification requires the following commands. Run them from the parent
`anbanwriter` repository root so the `claudecode/` paths resolve as written:

```bash
ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' claudecode/.claude-plugin/plugin.json
ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' claudecode/.claude-plugin/marketplace.json
go test ./server/agent -run 'TestClaudePlugin|TestPluginBinary|TestPluginsWireAnbanBootstrap' -count=1
claude plugin validate --strict ./claudecode
git -C claudecode diff --check
git diff --check
```

The optimization audit additionally recomputes all 9 Agent file sizes and their
frontmatter-preloaded Skill raw bytes, confirms 37 top-level Skills, and checks
that the table matches exactly.

## Remaining work

This correction does not complete the broader prompt optimization. Follow-up
work still needs representative eval baselines before reducing startup Skill
preload, collapsing Agent/umbrella-Skill dual orchestration, normalizing failure
matrices, tightening routing descriptions, applying progressive disclosure,
and tuning memory or `maxTurns` from observed traces.

Do not modify the `humanizer` mirror for those improvements. Keep
`seedance-20` third-party migration separate.
