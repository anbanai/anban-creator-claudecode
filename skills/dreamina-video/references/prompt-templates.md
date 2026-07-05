# Prompt and Artifact Templates

## reference-anchors.md

```markdown
# Reference Anchors

## Person References
- source:
- reference_role: 主体身份 | 首帧 | 尾帧 | 动作 | 运镜 | 节奏 | 音色
- must_keep:
- can_change:
- must_not_change:

## Object References
- source:
- reference_role: 产品外观 | 首帧 | 尾帧 | 动作 | 字体/文字风格
- must_keep:
- can_change:
- must_not_change:

## Scene References
- source:
- reference_role: 场景背景 | 首帧 | 尾帧 | 运镜 | 节奏 | BGM
- must_keep:
- can_change:
- must_not_change:
```

## creative-brief.md

```markdown
# Creative Brief

creative_type: personal_ip | high_efficiency_joke | product_demo | brand_promo | custom
purpose: planting | ecommerce | lead_gen | promotion
audience:
subject_profile:
single_message:
proof:
cta:
tone:
must_not_change:
source_video_understanding: video-understanding.json
```

## video-understanding.json

Produced by `analyze_video_reference`. Use it as evidence, not decoration.

```json
{
  "analysis_mode": "native_video",
  "visual_summary": "",
  "timeline": [
    {
      "time_range": "0-3s",
      "visual": "",
      "action": "",
      "expression": "",
      "camera": "",
      "rhythm": "",
      "creative_function": ""
    }
  ],
  "subjects": [],
  "people": [],
  "expressions": [],
  "actions": [],
  "scenes": [],
  "camera_motion": [],
  "rhythm": [],
  "must_keep": [],
  "can_change": [],
  "must_not_change": [],
  "planning_hints": []
}
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
- reference_role:
- transition_or_effect:
- audio_cue:
- business_role:
- negative_constraints:

## Shot 2 (3-6s)
...
```

## Final Prompt Template

Formula: 主体 + 场景 + 动作 + 运镜 + 分时段 + 转场/特效 + 音频 + 风格.

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

Transitions/effects:
{transition_or_effect per shot; keep only one main effect when possible}

Audio:
{audio_cue, BGM mood, voice tone, sound effects, beat cuts}

Style:
{platform tone, realism, lighting, pacing}

Negative constraints:
{must_not_change anchors}; no random text; no product shape/color change; no unplanned scene jumps; no exaggerated claims.
```

## Commercial Prompt Patterns

### 产品 360 展示

Use when product shape and material are the core proof.

```text
Create a {duration}s product showcase. Keep product silhouette, color, material, and logo consistent from {product_reference}. The product rotates 360 degrees once on a clean surface, then pauses for a close-up of {main_selling_point}. Camera: static or slow push-in only. Audio cue: subtle mechanical sweep and clean brand sting. Negative constraints: no shape change, no extra parts, no unreadable random text.
```

### 产品拆解展示

Use when the selling point is structure, ingredients, components, or craft.

```text
Create a {duration}s product breakdown demo. The product from {product_reference} separates into {component_count} visible layers or parts, each staying proportional and recognizable, then reassembles into the original product. Use one controlled camera movement. Audio cue: soft clicks or material sounds matched to each separation. Negative constraints: no melting, no invented components, no product color drift.
```

### 短剧式种草/带货

Use when a lived conflict can make the offer feel concrete.

```text
Create a {duration}s short-drama commercial. 0-3s: show a recognizable frustration from {audience}. 3-10s: the subject uses {product_or_solution} in one natural action. 10-13s: show the visible result or contrast. 13-15s: end with a CTA matching {purpose}. Audio cue: emotional reaction, one line of dialogue or narration, restrained sound design. Keep claims observable.
```

### 音乐卡点推广

Use when rhythm and memorability matter more than detailed explanation.

```text
Create a {duration}s beat-cut promotion. Use {reference_role:节奏 or BGM} as pacing guidance. Each beat reveals one visual proof: product close-up, use moment, result, brand frame. Camera movement changes only on beat boundaries. Audio cue: cuts must match the BGM energy curve. Negative constraints: no off-beat scene jumps, no more than one message per beat.
```

### 个人 IP 种草

Use when a recognizable person is the trust asset.

```text
Create a {duration}s vertical personal-IP planting video.
Subject identity: {subject_profile}. Keep age impression, hairstyle, clothing color family, speaking energy, expression range, and expertise role consistent in every shot.
Audience: {audience}.
Single message: {single_message}.
0-3s: direct lived pain or contrarian hook.
3-10s: one practical method or experience proof, shown visually.
10-13s: visible result, checklist, or short insight.
13-15s: soft CTA matching trust-building, not hard selling.
Reference video understanding: use {video-understanding.json rhythm/camera/expression anchors}.
Negative constraints: no identity drift, no outfit color drift, no random scene jumps, no exaggerated ad tone.
```

### 高效段子

Use when retention comes from recognition and reversal.

```text
Create a {duration}s fast joke-style short video.
Audience: {audience}.
Setup: {recognizable situation}.
Pressure: {social pain or absurd escalation}.
Reversal: {unexpected method, product, or insight}.
Payoff line: {short memorable punchline}.
CTA: {one light in-tone action}.
Shot rhythm: quick setup, faster escalation, clean pause before payoff, one proof frame after the laugh.
Negative constraints: no long explanation before the joke lands, no unrelated gag, no hard-sell unless purpose=ecommerce.
```

### 参考视频复刻

Use when the user says to follow a reference video.

```text
Create a {duration}s vertical video that follows the reference video's {reference_role} only.
Use video-understanding.json:
- rhythm: {rhythm anchors}
- camera: {camera_motion anchors}
- scene: {scene anchors}
- action: {action anchors}
Replace or preserve the subject according to user instructions:
- preserve subject only when reference_role includes subject identity
- otherwise preserve timing/camera/action while using the user's subject_profile
Negative constraints: do not copy unspecified people, brands, text, or products; do not change the user's subject identity.
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
