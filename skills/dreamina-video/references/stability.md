# Stability and Consistency

Video generation fails most often through drift: subject drift, product drift, scene drift, motion chaos, or business-goal drift. Stabilize by narrowing degrees of freedom before generation.

## Three-Layer Prompt

Layer 1: Global anchors
- Who/what/where must remain consistent across the whole video.
- Include person, object, and scene anchors from `reference-anchors.md`.
- Include model/ratio/resolution/duration/seed when known.

Layer 2: Shot instructions
- One shot at a time.
- Each shot has one subject, one action, one camera movement, one visual focus.
- Repeat important product/person anchors in every shot where they appear.

Layer 3: Negative constraints
- No identity change.
- No product shape/color change.
- No extra limbs/fingers when hands are important.
- No random logo/text unless supplied.
- No sudden scene change unless planned.
- No exaggerated advertising tone for planting videos.

## Parameter Discipline

For a batch or retry series, keep these fixed unless the quality review explicitly says to change them:
- model
- ratio
- resolution
- duration
- seed
- camera_fixed
- watermark
- reference URLs

Changing many parameters at once destroys diagnosis. Change one class of variable per retry.

## Visual Anchor Discipline

Generated visual anchors are a stabilizer, not a substitute for user-provided real references. If the user supplies a `subject identity`, `product appearance`, or `first frame` reference, do not generate another anchor for the same role.

- Main anchor: generate at most two attempts. Accept only `verification.passed=true`; when a score exists, require `score >= 0.75`.
- Derived anchors: use the approved main anchor as `ref_image_path` so the identity is carried forward. Never independently regenerate the same character/product for the second or third anchor.
- Count cap: auto-generate at most 3 anchors. More references usually fight each other and increase drift.
- Failure rule: if the 主锚定图 fails twice and the task is high-consistency, stop and ask for user reference media. For ordinary single-segment work, fall back to text-only anchors and record the risk.

## Failure Diagnosis

Subject drift:
- Strengthen must-keep identity anchors.
- Reduce shot count.
- Avoid changing wardrobe, lighting, or angle too often.
- Prefer medium shots over extreme motion.

Product drift:
- Repeat product silhouette, material, color, and use method in each product shot.
- Remove metaphorical wording like “像云一样” if it changes shape/material.
- Use close-ups for material proof, not wide scenes.

Scene drift:
- Repeat space type, lighting, and time of day.
- Use camera movement inside one environment instead of teleporting between locations.
- Set `camera_fixed` when the scene should behave like a product table shot.

Motion chaos:
- Replace compound actions with one verb.
- Avoid “快速切换、旋转、飞入、多人互动” in the same shot.
- Prefer push-in, pan, tilt, handheld follow, or static close-up.

Commercial mismatch:
- Planting too hard-sell: remove price urgency, use lived experience, soften CTA.
- Ecommerce too soft: add visible benefit, demonstration, and clear CTA.
- Lead gen too vague: name audience and problem, show process proof.
- Promotion too crowded: return to one memory point.

## Lens Vocabulary

Choose one primary camera move per shot:
- 推镜头: move closer to product, face, proof, or result.
- 拉镜头: reveal scene, scale, before/after, or context.
- 摇镜: pan or tilt across one stable environment.
- 跟拍: follow one subject or hand action.
- 环绕: rotate around one product or subject when shape matters.
- 俯拍: show layout, components, workflow, or table-top use.
- 仰拍: add scale, confidence, launch energy, or hero feeling.

Choose one primary shot scale per shot:
- 特写: material, texture, face, hand, button, label, or result detail.
- 中景: person using product, service process, or demonstration.
- 全景: scene identity, before/after context, event atmosphere.

Do not combine conflicting camera instructions in one shot. For example, avoid asking for fixed camera and 环绕 in the same shot unless one is clearly the start or end state.

## Prompt Pitfalls

Check these before submission:
- 引用模糊: every reference needs a `reference_role`; never say only "use the reference".
- 镜头指令冲突: one shot should not mix fixed camera, fast pan, and orbit.
- 短时长内容过载: 4-5s supports one action; 15s supports 4-5 shots, not a full story world.
- 素材无归属: every uploaded image/audio/video must control a named subject, product, scene, motion, rhythm, or sound.
- 忽视音频: add `audio_cue` for BGM mood, sound effects, voice tone, or beat timing when it affects the result.
- 复杂度与时长不匹配: reduce roles, shots, and effects before increasing prompt length.

## Quality Review

Write `quality-review.md` after every terminal result:

| Dimension | Score | Check |
| --- | --- | --- |
| Subject consistency | 1-5 | Person/object/scene matches anchors |
| Product fidelity | 1-5 | Shape, color, material, use method |
| Motion clarity | 1-5 | Actions are understandable |
| Business goal fit | 1-5 | Matches planting/ecommerce/lead/promotion |
| CTA fit | 1-5 | CTA strength matches purpose |

Retry only when a concrete failure dimension scores 3 or lower. In `iteration-log.md`, record the failure, the one change made, and the new result.

## Experience-Based Stabilizers

- Subject consistency starts before generation. If `subject_profile` is vague, convert it into visible anchors: age impression, hairstyle, clothing color family, posture, expression range, role identity, and environment.
- Reference videos must become facts. Read `video-understanding.json` and quote its must_keep/camera/rhythm facts in the prompt; do not say "参考这个视频" without naming what to preserve.
- Personal IP needs fewer scene changes than product ads. Stable background, recognizable wardrobe, and repeated gesture language often matter more than cinematic variety.
- High-efficiency jokes need a clean pause before payoff. If every shot moves fast, the reversal gets lost; plan one micro-beat where expression or camera holds.
- Product demos need visible proof. Replace abstract claims with hand action, close-up, comparison, or result state.
- Reference-video remixes should preserve one axis at a time: identity, action, camera, rhythm, or scene. Copying all axes while changing the user's subject causes drift.

## Example Diagnosis

| Failure | Likely Cause | Fix |
| --- | --- | --- |
| 个人 IP 不像同一个人 | subject_profile was not repeated in every shot | Add identity anchors to each shot and reduce scene/wardrobe changes |
| 高效段子不好笑 | setup and reversal are both vague | Make setup a familiar workplace moment and make payoff one short line |
| 参考视频没被参考 | video-understanding.json was not used in prompt | Copy rhythm/camera/action anchors explicitly |
| 产品变形 | product anchor appears only once | Repeat shape, material, color, and use method in each product shot |
