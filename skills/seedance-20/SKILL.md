---
name: seedance-20
description: "This skill should be used when creating, improving, or troubleshooting Seedance 2.0 video on any surface - Dreamina, Jimeng, CapCut, Doubao, Volcengine/Ark, BytePlus, Runway's Seedance route, fal, or third-party provider/router surfaces such as EvoLink, OpenRouter, Kie.ai, PiAPI, LaoZhang, Runware, ModelsLab, AI/ML API, MuAPI, SeeGen, and Segmind - including text/image/video/reference-to-video prompts, first/last frame, dialogue, lip-sync and audio, IP-safe rewrites, API, pricing and model-ID questions, and zh/ja/ko/es/ru prompt work. Not for non-Seedance models (Sora, Veo, Kling, Runway's own Gen models) or image-only prompting."
license: MIT
user-invocable: true
tags: [seedance]
metadata:
  version: "6.6.0"
---

# seedance-20 — Seedance 2.0 Skill OS

Seedance 2.0 operating loop for agent-directed video work. Use this root skill to route, check facts, protect references, and keep prompts compact before loading specialized sub-skills.

## Anban Agent Integration

This distribution is loaded directly by the Anban `videocreator` agent. Treat the full Emily2040/seedance-2.0 Skill OS below as the creative, routing, sequence, prompt, retake, and QC brain. Studio only supplies project `CLAUDE.md` / instructions, `task.prompt`, `video_creator_input.brief`, `video_creator_input.references`, and `video_creator_input.hard_constraints`; business playbook, purpose, production mode, subject, audience, and single message are agent/SKILL decisions, not Studio form fields. Treat useful patterns from `songguoxs/seedance-prompt-skill` and `ZeroLu/awesome-seedance` as Anban business playbook inputs, not as copy-paste prompt contracts. Treat Anban MCP as the only execution boundary.

Mandatory Anban overrides:

1. Start every Anban task by calling `prepare_workspace(content_type="videocreator", task_id=$TASK_ID)` and writing `input-manifest.md` with `task_id=$TASK_ID`, `workflow=seedance-20`, `selected_skill=seedance-20`, `agent=videocreator`, raw user request, `video_creator_input`, references, hard constraints, business decisions, and default sources.
2. Call `get_project_profile(project_id, task_id)` before planning. Use only its project videocreator profile, `agent_brief`, `videocreator.input`, `videocreator.model_catalog`, `videocreator.policy`, resolved task `video_creator_config` snapshot when present, visual-anchor capability, and pricing context.
3. Never choose, persist, or pass a model key to generation MCP tools. The server resolves model, duration bounds, pricing, billing, and provider payloads.
4. Use MCP tools only for generation: `prepare_video_generation_inputs`, `register_video_reference`, `analyze_video_reference`, `generate_image`, `analyze_image`, `validate_video_generation_params`, `build_video_generation_plan`, `create_video_generation_job`, `query_video_generation_job`, `download_video_generation_results`, `compose_video_segments`, and `validate_video_delivery`.
5. External surface/API/provider references in this Skill OS are guidance for understanding Seedance behavior, not permission to call Volcengine/Dreamina/Runway/fal/provider-router APIs directly, handle API keys, or bypass Anban task files.
6. Translate external reference tags (`@图片1`, `[Image1]`, `[Video1]`, `[Audio1]`) into Anban `references[]` with explicit `reference_role`; preserve exact user-facing tags in planning notes when helpful, but call `prepare_video_generation_inputs` and register every media reference through MCP before build/create.
7. For Anban business workflows, also load `references/anban-business-playbooks.md`; for delivery, load `references/anban-delivery-qc.md`; for MCP details, load `references/anban-mcp-contract.md`; for sequence/continuation handoff inside Anban workspaces, load `references/anban-sequence-workflow.md`.
8. Final delivery is not complete until `video-task-submit.json`, terminal `video-task-result.json`, `delivery-manifest.json`, a registered non-empty `final_video` OSS-backed task file, `quality-review.md`, and `validate_video_delivery` all exist/pass.
9. Submit feedback only as `agent_name="videocreator"`. `seedance-20` is a workflow/Skill name, not an agent identity.

Strict remake mode is mandatory when the request or task input says `主体不变`, `完全一样`, `同款`, `复刻`, `参考视频`, `照着这个段子`, `strict remake`, or similar. Strict remake exits Fast Lane immediately. Flow: `prepare_video_generation_inputs` → read `video-input-contract.json` → `analyze_video_reference` for every required video → write `reference-timeline.json` → write segment-aware `shot-plan.md` → `validate_video_generation_params` → `build_video_generation_plan` → `create_video_generation_job`. Assign roles such as `full remake reference` and `joke timeline` when the reference video controls the whole structure or joke timing. If any user-supplied image/video reference from `video_creator_input.references` / profile `videocreator.input.references` is missing from final `references[]`, not measured, private, or absent from the resolved plan, stop before spending credits. generated visual anchors can supplement user media but cannot replace it. If a reference video exists and the user did not specify duration, match the measured reference-video duration subject to project policy; if the resolved plan has `input_video=false`, stop. When the plan has multiple segments, download all segment files, compose a final MP4, call `compose_video_segments`, and only then call `validate_video_delivery`.

Every input video reference, strict remake or not, must be understood through `model_routes.video_understanding` / `analyze_video_reference` as native video before planning. `video-understanding.json` must include `deep_intent`, `business_intent`, `must_keep_meaning`, `can_adapt_meaning`, and `must_not_break_meaning`; if these are missing or shallow, stop instead of falling back to sampled frames, screenshots, image understanding, transcript-only analysis, or marketing copy guesses.

Standard Anban artifacts and references: run the 完整 AI 视频生成流程 for 即梦 / Seedance and save `reference-anchors.md`, `creative-brief.md`, `video-input-contract.json`, `video-understanding.json`, `reference-timeline.json`, `script.md`, segment-aware `shot-plan.md`, `quality-review.md`, `anchor-strategy.md`, `visual-anchor-pack.md`, and accepted `visual-anchors/`. Load `references/methodology.md`, `references/stability.md`, `references/prompt-templates.md`, `references/mcp-contract.md`, `references/sequence-workflow.md`, `references/business-playbooks.md`, and `references/delivery-qc.md`. Commercial modes include 种草、带货、获客、推广、个人 IP、高效段子、主体一致性、黄金三秒、首尾帧、视频延长、动态海报、穿搭变装、直播带货、广告复刻、真人短剧、AI漫剧. Use `project videocreator profile`, `agent_brief`, `videocreator.model_catalog`, `fixed retail SKU settlement`, `reference_role`, 目标成片时长, 单次生成片段, 参考视频时长, Fast Lane, Mode Gate, Reference map, Sequence Gate, Project State Capsule, Retake Protocol, Director Formula, anti-slop, one-variable retakes, Delivery And QC, `generate_image`, `verify_with_vision`, and 最多自动 3 张 visual anchors.

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

- 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
- 项目/频道默认比例次之。
- 业务默认比例只作兜底。
- 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例。
- 微信文章封面/正文图默认 `16:9`。
- Seednote/XLS/移动信息流默认 `3:4`。

## Soul

This skill exists so that a person who arrives with a feeling leaves with a film. Three principles govern everything below:

1. **Hear the intent behind the words.** Users describe outcomes ("make it feel like home"), not parameters. Every gate and sub-skill translates feeling into craft; none of them may hand the translation work back to the user.
2. **Keep the story alive.** Hold a story state across the conversation: subject, mode, look, references, decided constraints, and what failed before. Every skill reads it before asking anything and updates it after acting. A user should never have to repeat a decision, and a new request inherits the world already built.
3. **Evolve with the user.** Speak plainly to a beginner and in director language to a professional - and notice when the same user grows from one into the other across a project. The register adapts; the standards never do.

## Fast Lane

Most requests are one short clip from someone who just wants to see their idea. Do not run the full gate loop on them. Take the fast path when the request is a single standalone clip, from a non-expert, with no IP/likeness/brand/real-person or safety flag and no platform-fact question (API, pricing, model ID, limits, region):

1. Go straight to `[skill:seedance-interview-short]` - or write the brief immediately if the idea is already clear - then `[skill:seedance-prompt-short]`.
2. Apply craft inline from memory: one visible beat, one motivated camera move, one motivated light source, sound intent, and the directing coherence rule (name one intention; make camera, light, and performance serve it). Load `[ref:directing-engine]`, `[ref:capability-map]`, `[ref:allocation-model]`, and the source or professional gates only when something actually invokes them.
3. Treat it as one clip: do not ask sequence or continuation questions yet. Raise "should this be a series, part two, or longer" only after the first draft, or when the user says continue, extend, next part, or longer.
4. Keep the single-clip prompt compact (about 40-110 words) unless the active surface is a verified stricter API, and keep director language (blocking, directorial voice, shot contracts) inside the internal brief - speak to the user in plain words.

Leave the fast lane the instant the request earns a gate: IP/likeness/brand/safety risk goes to the safety gate (step 9); a platform-fact question loads the source gate; a film, client, or delivery request loads the professional gate; a long story, connected clips, or continuation goes to the Sequence Gate. When in doubt about safety, leave the fast lane. The Operating Loop below is the full procedure - the fast lane is the default for the common case, and every gate it skips stays one signal away.

## Operating Loop

1. Intake: identify the user's goal, production phase, target surface, mode, duration, aspect ratio, references, audio needs, deliverables, and safety/IP risks. If intake surfaces a clear safety, IP, likeness, or evasion risk, jump straight to the safety gate (step 9) before any planning.
2. Source gate: before platform claims, load `[ref:api-status]` and `[ref:source-registry]`. For Runway, Volcengine, fal, provider/router, or China-facing surface specifics, also load `[ref:platform-surface-matrix]`.
3. Professional gate: if the user asks for film, ad, campaign, client, delivery, localization, color, sound, subtitle, post, QC, or multi-shot work, load `[ref:pro-filmmaking-standards]` before drafting.
4. Sequence Gate: classify the request as `standalone_clip` or `sequence_project` before the Mode Gate. Use `sequence_project` for long stories, connected clips, continuation/extend/next-part requests, dense action/dialogue scenes, campaigns, or any idea whose beats cannot clearly fit inside one verified active-surface generation. For sequence work, load `[skill:seedance-sequence]`, `[ref:sequence-project-state]`, `[ref:continuation-handoff]`, and `[ref:prompt-compiler]`; for continuation, repair-tail, or re-anchor requests, also load `[skill:seedance-continuation]`.
5. Mode gate: choose T2V, I2V, V2V, R2V, FLF2V, edit, native extend when verified for that surface, or troubleshoot before writing prose.

   Mode availability is surface-specific: edit and extend exist on Dreamina and Ark routes; fal has no dedicated extend endpoint - to continue a clip on fal, prefer reference-to-video with the previous clip as a video reference (keeps motion and audio context), and chain image-to-video from its last frame as the fallback. Provider/router surfaces can rename the same job type, hide fields, or expose only selected modes; recheck their current docs before implementation.

6. Capability check: when planning any shot, mode, or budget, load `[ref:capability-map]` to design into model strengths and around known limits, and `[ref:allocation-model]` to decide where the prompt spends its fidelity budget before drafting.
7. Reference map: assign every asset one primary role: identity, first frame, last frame, product, environment, motion, camera, timing, audio, or style. State what must not transfer.
8. Multilingual gate: if the prompt uses Chinese, Russian, Japanese, Korean, Spanish, or code-mixed wording, load `[ref:multilingual-community-examples]` and preserve reference tags exactly. For native Chinese, Japanese, or Korean example-driven requests, route to `[skill:seedance-examples-zh]`, `[skill:seedance-examples-ja]`, or `[skill:seedance-examples-ko]`.
9. Safety gate: route IP, likeness, voice, brand, real-person, graphic, or evasion-like wording through `[skill:seedance-copyright]` or `[skill:seedance-filter]`.
10. Direction: before drafting any scene, name one intention and make camera, lens, light, blocking, performance, and sound serve it instead of picking a "cinematic look" - apply this coherence rule inline. Load `[ref:directing-engine]` only when scenes need distinct treatment, one directorial voice must hold across many clips, or the right setup is genuinely unclear.
11. Prompt build: route to `[skill:seedance-interview]`, `[skill:seedance-prompt]`, `[skill:seedance-prompt-short]`, `[skill:seedance-sequence]`, `[skill:seedance-continuation]`, or a domain skill for camera, motion, lighting, audio, characters, VFX, style, recipes, or pipeline.
12. Quality pass: run anti-slop and the directing coherence test, then check one visible beat, one primary camera move, physical motivated light, sound intent, continuity anchors, constraints, delivery caveats, and source-date caveats.
13. Repair loop: when a take returns, triage it with `[ref:retake-protocol]` (keep / fix in post / edit / re-roll / rewrite, one variable per retake, inside an attempt budget); if it fails outright, diagnose root cause before adding adjectives via `[skill:seedance-troubleshoot]`.

## Sequence Gate

For a sequence project, do not write Clip 01 until these are known: story objective, final story outcome, ordered major beats grouped into scenes, active surface or conservative surface assumption, clip budget, current clip narrative job and felt intent, and current clip completed endpoint.

Do not write a continuation prompt until the previous accepted clip or its actual final frame has been reviewed and its observed end state recorded.

Sequence invariants:

- every sequence prompt has `project_id` and `clip_id` lineage;
- accepted observed state overrides planned state;
- rejected footage is excluded from canon and cannot become a continuation source;
- future prompts remain provisional until the preceding accepted take is reviewed;
- exact reference tags survive every clip unchanged;
- seamless continuation stays inside a scene; a scene boundary opens from canonical references and resets `extension_depth`;
- completed beats cannot replay and reserved future beats cannot leak early;
- continuity state must be updated after each accepted take;
- final Seedance prompts remain natural language unless the user explicitly asks for structured output.

## Load Map

| Situation | Load |
|---|---|
| Vague idea or missing brief | `[skill:seedance-interview]` or `[skill:seedance-interview-short]` |
| Long story, connected clips, campaign sequence, dense action/dialogue scene, or a prompt that needs several generations | `[skill:seedance-sequence]`, `[ref:sequence-project-state]`, `[ref:prompt-compiler]` |
| Continue, extend, next part, repair tail, bridge known states, or re-anchor drift from accepted footage | `[skill:seedance-continuation]`, `[ref:continuation-handoff]`, `[ref:continuity-qc]` |
| Review a generated take and update canon before the next prompt | `[ref:retake-protocol]`, `[ref:sequence-project-state]`, `[ref:continuation-handoff]` |
| First multi-clip project, or how the sequence loop actually runs end to end | `[ref:sequence-worked-trace]` |
| Dense animation storyboard or multi-shot prompt | `[ref:dense-storyboard-mode]`, `[ref:multishot-grammar]`, `[ref:2d-anime-grammar]` |
| Production prompt | `[skill:seedance-prompt]`, `[ref:quick-ref]`, `[ref:prompt-examples]` |
| Planning any shot, mode, or budget | `[ref:capability-map]` |
| Where the prompt spends fidelity: identity vs motion vs scene density | `[ref:allocation-model]`, `[ref:intent-vs-precision]` |
| Multi-shot prompt, cuts inside one clip, or shots-per-duration budget | `[ref:multishot-grammar]` |
| 2D, anime, or cel-style motion | `[ref:2d-anime-grammar]`, `[skill:seedance-style]` |
| Professional film, commercial, campaign, or delivery workflow | `[ref:pro-filmmaking-standards]`, `[ref:shot-list-continuity]`, `[ref:delivery-qc]` |
| Compact prompt or Chinese compression | `[skill:seedance-prompt-short]`, language vocab reference |
| Choosing the right camera, light, blocking, performance, and voice for a scene, keeping every choice motivated, or holding one directorial style across a long story | `[ref:directing-engine]` |
| Camera, lens, blocking, shot contract | `[skill:seedance-camera]`, `[ref:cinematography-shot-language]` |
| Image reference / first frame | `[ref:i2v-guide]`, `[ref:reference-workflow]` |
| First and last frame | `[ref:first-last-frame-guide]` |
| API, Runway, Volcengine, fal, provider/router surfaces, China-facing surfaces, workflow, pricing, model IDs | `[skill:seedance-pipeline]`, `[ref:api-workflow]`, `[ref:model-name-map]` |
| Color, ACES, HDR/SDR, aspect ratio, subtitles, audio post, or QC | `[ref:color-pipeline-aces]`, `[ref:aspect-ratio-delivery]`, `[ref:subtitles-localization]`, `[ref:audio-post-delivery]`, `[ref:delivery-qc]` |
| Genre template, examples, or a worked directing example in a specific genre | `[skill:seedance-recipes]`, `[ref:examples-by-mode]`, `[ref:genre-guides]`, `[ref:directing-engine-genre-library]` |
| Chinese examples or safe Chinese rewrites | `[skill:seedance-examples-zh]`, `[skill:seedance-vocab-zh]`, `[ref:vocab/zh]` |
| Japanese examples or safe Japanese rewrites | `[skill:seedance-examples-ja]`, `[skill:seedance-vocab-ja]`, `[ref:vocab/ja]` |
| Korean examples or safe Korean rewrites | `[skill:seedance-examples-ko]`, `[skill:seedance-vocab-ko]`, `[ref:vocab/ko]` |
| Russian/Spanish or mixed-language examples | `[skill:seedance-vocab-ru]`, `[skill:seedance-vocab-es]`, `[ref:multilingual-community-examples]` |
| Slop-heavy or filter-tripping English wording | `[skill:seedance-vocab-en]`, `[skill:seedance-antislop]` |
| Bad result | `[skill:seedance-troubleshoot]` |
| A take came back: keep, fix in post, edit, re-roll, or rewrite | `[ref:retake-protocol]` |
| Why a rule works, or a novel case no rule covers | `[ref:model-mechanics]` |

Preserve reference tags exactly, keep prompts short, and never convert field-observed community tricks into official platform guarantees. For professional filmmaker requests, deliver the workflow object the role needs: shot list, shot contract, continuity ledger, prompt, post handoff, localization plan, or QC checklist.

## Reference Map

Load these long references only when the current task needs that detail:
- [references/directing-engine.md](references/directing-engine.md) - directing engine.
- [references/directing-engine-genre-library.md](references/directing-engine-genre-library.md) - directing engine genre library.
- [references/sequence-project-state.md](references/sequence-project-state.md) - sequence project state.
- [references/multilingual-community-examples.md](references/multilingual-community-examples.md) - multilingual community examples.
- [references/prompt-examples.md](references/prompt-examples.md) - prompt examples.
- [references/api-status.md](references/api-status.md) - api status.
