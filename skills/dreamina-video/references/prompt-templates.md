# Prompt and Artifact Templates

## reference-anchors.md

```markdown
# Reference Anchors

## Person References
- source:
- must_keep:
- can_change:
- must_not_change:

## Object References
- source:
- must_keep:
- can_change:
- must_not_change:

## Scene References
- source:
- must_keep:
- can_change:
- must_not_change:
```

## script.md

```markdown
# Script

purpose: planting | ecommerce | lead_gen | promotion
duration: 15s
audience:
single_message:

## 0-3s Hook

## 3-10s Proof / Experience / Demonstration

## 10-13s Reinforcement

## 13-15s CTA
```

## shot-plan.md

```markdown
# Shot Plan

## Shot 1 (0-3s)
- subject:
- action:
- scene:
- camera:
- visual_focus:
- business_role:
- negative_constraints:

## Shot 2 (3-6s)
...
```

## Final Prompt Template

```text
Generate a {duration}s vertical commercial short video.

Business purpose: {purpose}.
Audience: {audience}.
Single message: {single_message}.

Global consistency anchors:
{must_keep anchors}

Shot sequence:
1. 0-3s: {shot_1_subject}; {shot_1_action}; scene {shot_1_scene}; camera {shot_1_camera}; focus {shot_1_focus}.
2. 3-6s: ...
3. ...

Style:
{platform tone, realism, lighting, pacing}

Negative constraints:
{must_not_change anchors}; no random text; no product shape/color change; no unplanned scene jumps; no exaggerated claims.
```

## quality-review.md

```markdown
# Quality Review

- video_task_id:
- model:
- ratio:
- resolution:
- duration:
- seed:
- result_url:

| Dimension | Score | Notes |
| --- | --- | --- |
| Subject consistency |  |  |
| Product fidelity |  |  |
| Motion clarity |  |  |
| Business goal fit |  |  |
| CTA fit |  |  |

## Decision
- accept / retry:
- reason:
- next_change:
```

## iteration-log.md

```markdown
# Iteration Log

## Attempt 1
- task:
- parameters:
- issue:
- changed:
- result:
```
