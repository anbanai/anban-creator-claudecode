# Sequence Workflow

Use this reference when a Seedance 2.0 request becomes a long story, connected clips, continuation, extension, repair-tail, re-anchor, campaign sequence, dense storyboard, or multi-generation commercial.

## Sequence Gate

Classify the request before prompt writing:
- `standalone_clip`: one generation can carry the idea.
- `sequence_project`: the idea needs connected clips, a story spine, campaign variants, long duration, or continuity across generations.
- `seamless_continuation`: the next generation continues accepted footage inside the same scene.
- `intentional_next_shot`: editorial cut; open from canonical references and reset continuity chain.
- `repair_tail`: only the final seconds or one layer failed.
- `reanchor_after_drift`: extension_depth or visible drift makes source-output chaining fragile.

Do not write the next prompt until the accepted clip, accepted final frame, or exact observed end state is known.

## Project State Files

Keep machine truth in `project-state.json` and append review lines to `take-log.md`. Regenerate the readable Project State Capsule from JSON; do not hand-maintain facts twice.

Minimum `project-state.json` fields:
- `schema_version`, `state_revision`, `project_id`, `surface`, `target_duration_sec`, `current_clip_id`
- `story`: logline, objective, final outcome, tone, medium
- `reference_registry`: canonical identity/product/scene/audio references and their exact role
- `scenes`: location, time envelope, arc position, anchor source, max chain depth, audio plan
- `beats`: planned/current/completed/omitted/replaced
- `clips`: lineage, parent, scene, narrative job, planned and observed start/end state, continuity locks, allowed changes, extension_depth
- `take_history`: verdict, changed variable, seed, evidence, accepted deviations

## Project State Capsule

The capsule is the cross-session handoff and should stay under roughly 40 lines:

```markdown
PROJECT ID:
STORY GOAL:
FINAL OUTCOME:
SURFACE:
REFERENCE TAGS:
CANONICAL REFERENCES:
ACCEPTED CLIPS:
SCENE MAP:
CURRENT SCENE:
CURRENT ACTUAL STATE:
OPEN MOTION:
COMPLETED BEATS:
NEXT CLIP JOB:
NEXT CLIP INTENT:
CONTINUITY LOCKS:
ALLOWED CHANGES:
RESERVED FUTURE BEATS:
EXTENSION DEPTH:
UNRESOLVED UNCERTAINTIES:
```

Accepted observed state overrides planned state. Rejected footage never becomes canon.

## prompt compiler

Compile only the current clip or segment:
1. Source role and exact reference tags.
2. Actual opening state; use observed footage/final frame when continuing.
3. Current clip action and endpoint.
4. Felt intent converted into concrete camera, light, performance, and sound choices.
5. Continuity locks and allowed changes.
6. Completed beats that must not replay.
7. Reserved future beats that must not appear early.

Do not paste future clips into the current prompt. Do not describe a planned ending as if it happened. If an accepted source is attached, the source carries state and prose carries the delta.

## Continuation Handoff

For continuations, record observed start/end state, open motion vector, camera phase, screen direction, character pose/gaze, prop position/condition, environment arrangement, lighting phase, ambience/dialogue/SFX/music phase, confidence, and uncertainties.

If a full clip is available, infer motion and camera phase from it. If only a final frame is available, infer visible state and ask for or record frame-blind details such as open motion and audio phase. If nothing is available, stop and request source media or an exact visible-end description.

## Retake Protocol

Set an attempt budget and a "good enough" definition before retrying. Use one-variable changes.

Verdicts:
- `Keep`: primary spend delivered; secondary flaws are not fatal.
- `Fix in post`: color, trim, text, audio mix, and small end-frame issues belong in post.
- `Edit, don't regenerate`: composition/timing are right and one supported layer is wrong.
- `Re-roll`: prompt is right but sampling was unlucky; use same prompt with new seed.
- `Rewrite`: same flaw appears twice; diagnose root cause and change prompt.

Log format:

```text
Take N · changed: one-variable · seed: same/new · verdict: Keep/Fix in post/Edit/Re-roll/Rewrite · evidence: one sentence
```

Failure routing:
- action restarts -> mark completed beats
- future event appears early -> remove reserved future beats from current prompt
- identity drifts -> re-anchor from canonical references
- open motion stops -> carry subject/camera speed and direction
- reference roles contaminate -> split roles and write exclusions
