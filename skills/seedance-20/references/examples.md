# seedance-20 Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) keep skill entrypoints compact and move reusable scenarios into references for progressive disclosure.
- GitHub high-star: [Emily2040/seedance-2.0](https://github.com/Emily2040/seedance-2.0), [songguoxs/seedance-prompt-skill](https://github.com/songguoxs/seedance-prompt-skill), and [ZeroLu/awesome-seedance](https://github.com/ZeroLu/awesome-seedance) show the public Seedance pattern of routing by mode, references, sequence state, and failure repair.
- These cases are original Anban scenarios adapted from those structural patterns; do not copy third-party prompts, copyrighted scripts, or provider-specific API payloads verbatim.

## How To Use These Cases

Read the closest case before choosing a branch when the task involves visual anchors, sequence work, business conversion, or quality recovery. Adapt the case to the current project profile, `videocreator.model_catalog`, task video_creator_config, registered references, available MCP tools, and billing estimate. Keep all artifacts file-backed and record downgrades in `quality-review.md` or `take-log.md`.

### Case 1: Seednote Product Seed Video

- Input: 用户给出产品图和卖点，希望生成 6-8 秒小红书种草短片。
- Recommended path: Load `references/business-playbooks.md`, map the product image as `reference_role=product`, generate up to three visual anchors only if the supplied image cannot lock appearance, then draft one visible beat with a clear CTA.
- Artifacts: `reference-anchors.md`, `anchor-strategy.md`, `visual-anchor-pack.md` when anchors are generated, `creative-brief.md`, `shot-plan.md`, `video-task-submit.json`, `quality-review.md`.
- Quality gate: Preserve product shape, logo, label, and promised effect; do not infer aspect ratio from provider defaults; record any text-only anchor fallback as a consistency risk.

### Case 2: Multi-Clip Personal IP Campaign

- Input: 用户要求连续三条真人 IP 获客视频，已有头像、口播人设和第一条主题。
- Recommended path: Classify as `sequence_project`, load `references/sequence-workflow.md`, maintain `project-state.json`, reserve future beats, and compile each clip from the current `Project State Capsule`.
- Artifacts: `project-state.json`, `take-log.md`, per-clip `script.md`, `shot-plan.md`, `video-task-result.json`, and final `delivery-manifest.json`.
- Quality gate: Accepted observed state overrides the planned ending; retakes change one variable at a time; do not regenerate accepted identity anchors unless the user explicitly asks.

### Case 3: Reference Video Rhythm Rebuild

- Input: 用户上传参考视频，希望复刻节奏做新品广告，但更换主体、场景和文案。
- Recommended path: Register the source video as motion/timing reference, analyze it through MCP, keep identity/background transfer forbidden, then use `references/methodology.md` and `references/prompt-templates.md` to build a new scene contract.
- Artifacts: `video-understanding.json`, `reference-anchors.md`, `creative-brief.md`, `shot-plan.md`, `quality-review.md`.
- Quality gate: Transfer only rhythm, camera density, and transition logic; replace recognizable people, locations, logos, and copy; cite any provider limitation or analysis downgrade in the review.
