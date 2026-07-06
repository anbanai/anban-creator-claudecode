# Business Playbooks

Use these playbooks when the user asks for Anban business video output. They are adapted from community-observed Seedance 2.0 patterns, but every generation still follows Anban MCP, project policy, registered references, and final task-file delivery.

## Business Routing

Map user intent into `creative_type` and `purpose`:

| User need | creative_type | purpose | Core output |
| --- | --- | --- | --- |
| 个人 IP 种草 | personal_ip | planting or lead_gen | trust-building lived proof |
| 高效段子 / office meme | high_efficiency_joke | promotion or planting | setup, pressure, reversal, payoff |
| 产品展示 / 功能证明 | product_demo | ecommerce or planting | problem, visible proof, result, CTA |
| 品牌宣传 / 活动记忆 | brand_promo | promotion | one memory point and brand frame |
| Custom campaign | custom | choose from goal | explicit one audience, one message |

## 九大商用玩法

### 追热点
- Use owned or transformed materials; avoid copying protected people/scenes.
- Extract the structure, camera role, or key visual metaphor from a trend, then replace with original subject/product.
- Good for promotion; keep CTA light unless a product proof exists.

### 商业广告
- Lock product identity with product appearance references or generated visual anchors.
- Use product_demo + ecommerce when conversion matters; brand_promo + promotion when memory matters.
- Prompt around one primary selling point, one product action, and one camera endpoint.

### 品牌宣传
- Use one brand memory point, one scene where the audience meets the brand, and a final brand/product frame.
- Avoid stuffing every brand value into one clip.
- Do not rely on model-generated slogan text; add text in post unless the task explicitly accepts generated text risk.

### 穿搭变装
- Treat each outfit image as product appearance / costume identity.
- Use rhythm or BGM references as timing only.
- Alternate half-body movement and full-body reveal; if too many outfits, split into segments.

### 直播带货
- Purpose defaults to ecommerce.
- Structure: strong hook, one core selling point, hand/use demo, close-up proof, clear CTA.
- Keep claims observable and compliant; do not invent ingredients, certifications, or prices.

### 动态海报
- Use fixed camera when the poster layout must stay stable.
- If a storyboard/grid reference exists, describe reveal order explicitly.
- Generate textless or low-text versions when text fidelity matters; typography belongs in post.

### 广告复刻
- Map `@视频` / video reference to camera movement, pacing, cut rhythm, or motion only.
- Map product image to product identity.
- State what must not transfer: original people, logos, room, voice, protected music, or brand marks.
- If a shot fails repeatedly, create or request a clearer first/last frame or product anchor for that shot.

### 真人短剧
- Keep roles, wardrobe, location, and power relationship stable.
- Use short dialogue lines. Mark dialogue as audio/口型 intent, but do not depend on generated subtitles for delivery.
- Strong 15s shape: conflict setup, pressure/reveal, reversal, payoff/CTA or cliffhanger.

### AI漫剧
- Use style/motion reference for medium grammar, not protected IP copying.
- For martial arts or fantasy effects, keep one action per shot and one effect carrier.
- If a long fight is requested, sequence it into scenes/clips with project-state tracking.

## Commercial Prompt Patterns

Product 360:
- Keep product silhouette, color, material, logo/mark if allowed, and key part stable.
- Use one controlled rotation or orbit, then one proof close-up.

Product breakdown:
- Separate into visible layers/components only when the structure is true or intentionally illustrative.
- Reassemble into original product before CTA.

Short-drama planting:
- Use a lived frustration, one natural use action, visible result, and soft CTA.

Music beat promotion:
- Audio controls tempo/energy only.
- Each beat reveals one proof or brand memory point; no more than one message per beat.

Personal IP:
- Lock age impression, hairstyle, outfit family, posture, speaking energy, values, catchphrase style, and environment.
- Use 黄金三秒 hook, practical proof, reinforcement, and soft CTA.

## Reference Role Reminders

- Images: identity, product, costume, environment, first frame, last frame.
- Videos: motion, camera, pacing, blocking, timing, style grammar.
- Audio: rhythm, tempo, mood, ambience, voice tone, BGM.
- Text: action, genre, constraints, CTA, compliance notes.

Every playbook must end in registered final video delivery, not just a prompt.
## Anban Business Playbooks

Modes include 追热点, 商业广告, 品牌宣传, 穿搭变装, 直播带货, 动态海报, 广告复刻, 真人短剧, AI漫剧, product_demo, brand_promo, ecommerce, and lead_gen. Choose one mode before prompting and align proof, CTA, rhythm, and visual anchors to that mode.
