# Commercial Video Methodology

## Reference Anchor Method

Before writing prompts, classify every reference as person, object, or scene.

Person anchors:
- Must keep: identity, age impression, hairstyle, clothing, facial expression range, body posture, distinctive accessories.
- Can change: micro-expression, hand position, small camera angle changes, background details that do not define identity.
- Must not change: gender/age category, hairstyle silhouette, clothing color family, facial feature impression, role identity.

Object anchors:
- Must keep: product category, silhouette, color, material, logo/mark if allowed, core selling point, use method.
- Can change: camera distance, supporting props, hand position, small lighting differences.
- Must not change: shape, colorway, capacity/spec impression, number of parts, key surface texture.

Scene anchors:
- Must keep: space type, time of day, light direction, mood, core props, depth/scale.
- Can change: secondary props, exact layout, background motion.
- Must not change: indoor/outdoor category, lighting mood, setting identity, unrealistic transitions.

Write these into `reference-anchors.md` as three blocks: `must_keep`, `can_change`, `must_not_change`.

## Reference Role Assignment / 素材角色分配

Before using any reference in a prompt, assign one `reference_role`. A reference without a role increases drift because the model must guess what to copy.

Use these roles:
- 主体身份: keep a person, character, mascot, or recurring subject recognizable.
- 产品外观: lock product silhouette, color, logo/mark, material, package, or key part.
- 场景背景: control space type, light, time, props, mood, or depth.
- 首帧: anchor the opening composition or first visual state.
- 尾帧: anchor the final frame, product packshot, CTA frame, or result state.
- 动作: borrow pose, movement path, hand operation, dance, or demonstration.
- 运镜: borrow camera movement, shot scale, angle, or transition rhythm.
- 节奏: borrow pacing, beat cuts, fast/slow alternation, or music-card timing.
- 音色: borrow voice tone, delivery style, emotional intensity, or narration texture.
- BGM: borrow background music mood, tempo, or energy curve.
- 字体/文字风格: borrow title typography, subtitle style, product label layout, or CTA text style.

When writing `reference-anchors.md`, include `reference_role` beside the source. If one source has multiple roles, split them into separate bullets so each role has its own must-keep/can-change/must-not-change rules.

## Business Goal Translation

## 创作定位 / Creative Type Selection

Start by separating content format from business purpose. `purpose` tells the commercial goal; `creative_type` tells the story form.

- 个人 IP: Use when the stable asset is a person, founder, expert, creator, or recurring narrator. Default `purpose=planting`; use `lead_gen` when the video should drive consultation, private messages, forms, or diagnosis. Lock identity, voice energy, values, outfit family, expression range, recurring phrases, and trust posture.
- 高效段子: Use when humor, reversal, or social recognition is the retention engine. Default `purpose=promotion`; use `planting` when a product/idea is recommended softly, and `ecommerce` only when the punchline directly supports a purchase.
- 产品演示: Use when the audience must see a product feature, material, before/after, operation, or proof. Usually `purpose=ecommerce` or `planting`.
- 品牌推广: Use when memory, event awareness, or brand association matters more than immediate conversion. Usually `purpose=promotion`.
- 自定义: Use only when none of the above fits; still write one audience, one subject, one message, and one CTA.

## 完整视频创作流程

1. Intent lock: write the user's real outcome in one sentence. If the user gives many ideas, choose the strongest single message instead of stuffing all into 15s.
2. Reference understanding: run `analyze_video_reference` for input videos and read `video-understanding.json`. Extract visual facts: who appears, how they move, how the camera behaves, how cuts and beats work, and which details define consistency.
3. Subject consistency: convert `subject_profile` and subject references into visible anchors. A person anchor must include age impression, hairstyle, outfit color family, expression range, posture, and role identity. A product anchor must include shape, color, material, logo/mark if allowed, and use method.
4. Content structure: choose a proven structure for the creative type. Personal IP uses trust + insight + proof. Jokes use setup + pressure + reversal + payoff. Product demos use problem + visible proof + result + CTA.
5. Shot economy: match complexity to duration. 5s supports one idea. 10-15s supports 3-5 shots. Longer deliverables should be segmented but still preserve the same identity, scene, and rhythm anchors.
6. Prompt construction: every shot gets subject, action, scene, camera, visual focus, audio cue, business role, and negative constraints. Avoid compound actions.
7. Quality review: score output before accepting. Retry only when a concrete dimension fails; change one class of variables per retry.

## 个人 IP Method

Personal IP videos win by recognizability and trust. The viewer should feel "this person has a stable point of view" within the first seconds.

- Identity anchors: face impression, hairstyle, outfit family, speaking energy, posture, gesture habits, environment, and expertise role.
- Hook types: direct pain, contrarian insight, mini confession, workflow promise, or "I used to do X, now I do Y."
- Proof types: screen/process, small demo, before/after, one concrete sentence, or one visual checklist.
- CTA strength: usually soft. "收藏", "下次照着用", "评论关键词", or "私信拿清单" when `lead_gen`.
- Avoid: random scene changes, changing clothing mid-video, over-polished ad tone, too many claims, and generic influencer gestures that erase the creator's identity.

## 高效段子 Method

High-efficiency joke videos are not random comedy; they are compressed recognition plus reversal.

- Setup: a situation the audience recognizes immediately.
- Pressure: what makes it painful, absurd, or socially familiar.
- Reversal: a surprising reframing or method.
- Payoff: the laugh, insight, or memorable line.
- Bridge to product/idea: one visual proof after the payoff, not a long sales lecture.
- CTA: short and in-tone; the joke should not collapse into a hard-sell unless `purpose=ecommerce`.

## 参考视频复刻 Method

When the user provides a reference video, copy structure, rhythm, camera logic, and visual grammar only as allowed by `reference_role`.

- If role is 主体身份: preserve identity traits, not necessarily the original scene.
- If role is 动作: borrow movement path, pose, hand operation, or demonstration.
- If role is 运镜: borrow camera move, shot scale, angle, and transition logic.
- If role is 节奏: borrow beat density, cut timing, speed changes, and emotional curve.
- If role is 场景背景: preserve space type, lighting, mood, and core props.

Never assume the entire reference should be copied. Declare must-keep, can-change, and must-not-change before scripting.

### Planting / 种草

Goal: trust, desire, and low-pressure interest.

Use this structure:
1. Pain/desire: name a lived moment the audience recognizes.
2. Experience: show a natural use case, not a sales demo.
3. Detail proof: texture, hand feel, before/after, convenience, real scene.
4. Light CTA: save, try, ask, or “适合…的人”.

Tone: first-person, observational, restrained. Avoid price shouting, exaggerated claims, and hard-selling voice.

### Ecommerce / 带货

Goal: click or purchase.

Use this structure:
1. Strong hook: result, contrast, number, pain, or time-saving claim.
2. Core selling point: one main benefit only.
3. Demonstration: product in use, hand action, before/after, close-up evidence.
4. Proof or comparison: material, certification, visible result, old-vs-new.
5. Clear CTA: buy, claim offer, check product detail, limited bundle if true.

Tone: direct and concrete. Every abstract claim must become a visible shot.

### Lead Generation / 获客

Goal: consultation, private message, lead form, or trial.

Use this structure:
1. Audience callout: “如果你是…” / role or problem category.
2. Pain amplification: cost of inaction, wasted time, uncertainty.
3. Solution: show the process or outcome, not just a logo.
4. Trust: case, credential, workflow, visible professional proof.
5. Low-friction CTA: consult, get checklist, book diagnosis, receive plan.

Tone: expert but not pompous. Reduce brand slogans; increase specific problem-solving cues.

### Promotion / 推广

Goal: awareness, event memory, product launch, or brand association.

Use this structure:
1. Single memory point: one slogan, visual motif, product feature, or event benefit.
2. Scenario expression: show where/when the audience encounters the offer.
3. Emotional or practical reinforcement: atmosphere, social proof, result.
4. Brand exposure: clear but not intrusive final frame.

Tone: memorable and simple. Do not overload the video with every product feature.

## 15-Second Structure

Use this default timing:
- 0-3s: one hook. No more than one pain point, promise, or visual surprise.
- 3-10s: proof or process. Show how the subject/product/scene supports the hook.
- 10-13s: reinforcement. Result, comparison, social proof, or emotional payoff.
- 13-15s: CTA. Match the CTA strength to the purpose.

For 5s or 10s videos, compress the same logic instead of inventing a new structure.

## Shot Planning

Default 15s videos use 4-5 shots:
- Shot 1: hook image or motion.
- Shot 2: subject/product context.
- Shot 3: detail proof or demonstration.
- Shot 4: result or emotional payoff.
- Shot 5: CTA/brand/product final frame.

Each shot must include:
- Subject
- Action
- Scene
- Camera movement
- Visual focus
- Negative constraints

One shot means one main action. If a sentence contains “and” more than once, split or simplify it.
