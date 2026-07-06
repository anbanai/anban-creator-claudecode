# Delivery And QC

Use this before `submit_agent_feedback` and whenever output is for a client, campaign, business account, or platform upload. Summarize results in `quality-review.md`.

## Delivery Preflight

| Area | Check |
| --- | --- |
| Picture | frame rate if known, resolution, aspect ratio, crop, safe area, stabilization, flicker, banding, black frames |
| Color | product/brand color, look notes, HDR/SDR assumption, illegal color casts, lighting mismatch |
| Audio | sync, loudness impression, true-peak risk, dialogue clarity, ambience/SFX/music intent, silence where intended |
| Text | captions, subtitles, forced narrative, on-screen copy, title-safe placement, generated text risk |
| Continuity | wardrobe, props, screen direction, product orientation, scene geography, light direction, last-frame handoff |
| Rights | references, music, voice, likeness, product/brand authorization, stock/source license notes |
| Metadata | task ID, video_generation_id, model key from server response, prompt version, seed/settings if available, source URLs |
| Versioning | hero, cutdown, vertical, square, textless, localized, archival, review version |
| Human QC | watch all outputs at normal speed; pause on fragile face, hand, product, and transition frames |

## quality-review.md Template

```markdown
# Quality Review

workflow: seedance-20
video_generation_id:
final_video_task_file:
target_duration_fit:

## Scores
| Dimension | Score | Evidence |
| --- | --- | --- |
| Subject consistency | 1-5 | |
| Product fidelity | 1-5 | |
| Scene / camera continuity | 1-5 | |
| Motion clarity | 1-5 | |
| Business goal fit | 1-5 | |
| CTA fit | 1-5 | |
| Delivery And QC | 1-5 | |

## Delivery Preflight
- Picture:
- Color:
- Audio:
- Text:
- Continuity:
- Rights:
- Metadata:
- Versioning:
- Human QC:

## Retake Decision
verdict: Keep | Fix in post | Edit, don't regenerate | Re-roll | Rewrite
changed_variable_if_any:
risk_notes:
```

## QC Failure Routing

| Failure | Route |
| --- | --- |
| face/product/text drift | stronger I2V/product anchor, edit pass, post composite, or regenerate from stable frame |
| continuity mismatch | update project-state/take-log and regenerate only affected clip |
| color mismatch | grade/conform first; regenerate only when lighting intent is wrong |
| caption/text issue | remove generated text and add typography in post |
| loudness/sync issue | fix mix or timing in post; do not rely on prompt repair only |
| unsafe or rights issue | rewrite to original/authorized material and document rights |

## Done Definition

A professional Seedance asset is done only when the creative owner accepts the generated video, rights notes are clean, continuity is tracked, post handoff is explicit, delivery target passed human QC, and `validate_video_delivery` confirms a registered `final_video` task file.
## Anban Delivery And QC

Write `quality-review.md` and check Picture, Color, Audio, Text, Continuity, Rights, Metadata, Versioning, and Human QC. Confirm delivery-manifest, task file IDs, final_video, credits, and provider status before completion.
