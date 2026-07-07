# agent-reach Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [Panniantong/agent-reach](https://github.com/Panniantong/agent-reach) provides the external data boundary and install flow; [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files), [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code), and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show compact trigger guidance plus concrete reusable cases.
- These cases are original Anban scenarios generated from those structure patterns; do not copy third-party wording, prompts, or proprietary workflows verbatim.

## How To Use These Cases

Read the closest case before executing Agent-Reach when backend status, token provenance, or failure handling is ambiguous. Adapt the pattern to the current task flags and available backend. Keep research artifacts file-backed and record unavailable data instead of inventing it.

### Case 1: Agent-Reach unavailable

- Input: `agent-reach doctor --json` is missing or returns no Xiaohongshu backend.
- Recommended path: Stop external research and report the install/configuration repair hint.
- Artifacts: task report with `data_source=agent-reach`, `active_backend=unavailable`, and `fallback_reason`.
- Quality gate: Do not fabricate trending notes, comments, URLs, `feed_id`, or `xsec_token`.

### Case 2: Original topic research

- Input: Seednote original mode needs real notes for “春季花茶”.
- Recommended path: Run doctor, use only the active backend command family, collect search/feed results, and pass them to `seednote-research`.
- Artifacts: `topic-analysis.md` with `data_source=agent-reach`, active backend, missing fields, and candidate scoring evidence.
- Quality gate: Backend order and fallback belong to Agent-Reach; do not call backend tools directly by preference.

### Case 3: Source note retrieval

- Input: Replicate mode receives a Xiaohongshu URL or note id.
- Recommended path: Resolve source details through the active Agent-Reach backend and extract `feed_id` / `xsec_token` only from real backend output or URLs.
- Artifacts: `source-note.md`, raw source details, `token_source`, `missing_fields`, and `fallback_reason`.
- Quality gate: Never construct `xsec_token`; stop after the backend retry path fails.
