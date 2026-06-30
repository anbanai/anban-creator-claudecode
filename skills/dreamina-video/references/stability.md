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
