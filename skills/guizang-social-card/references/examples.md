# guizang-social-card Examples

## Source Patterns

- Anthropic official: [anthropics/skills](https://github.com/anthropics/skills) and [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) use lightweight `SKILL.md` entrypoints with one-level `references/`, `examples/`, and `templates/` resources for progressive disclosure.
- GitHub high-star: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) keeps reusable scenarios in `references/examples.md` across multiple agent distributions; [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) show compact trigger guidance plus concrete cases.
- Upstream inspiration: [op7418/guizang-social-card-skill](https://github.com/op7418/guizang-social-card-skill) informs the social-card direction. It is AGPL-3.0; Anban uses original adapter guidance and does not vendor upstream templates/scripts/assets by default.

## How To Use These Cases

Read the closest case before executing the skill when deciding whether to use rendered social cards instead of provider-generated images. Preserve image-mode switches, register every PNG through `register_rendered_image`, and record dimensions plus returned upload fields in `image-review.md`.

### Case 1: 图文笔记 Swiss 组图

- Input: `visual_style="归藏社交卡，Swiss editorial，小红书组图"` and `seednote_image_mode=cover_content`.
- Recommended path: create original HTML/CSS cards at `1080x1440`; render `cover.png`, `image_01.png`... according to `image-plan.md`; skip `tail.png`.
- Registration: call `register_rendered_image` for each PNG with `role="cover"` for `cover.png`, `role="image"` for content pages, `upload_to_cdn=false`.
- Review: verify no overflow, all text is simplified Chinese, and each card maps to one content point group.

### Case 2: 微信公众号封面双规格

- Input: article visual style contains `Guizang social card` or `editorial card`; `article_image_mode` includes cover.
- Recommended path: render `wechat-21x9-cover.png` at `2100x900`, `wechat-1x1-cover.png` at `1080x1080`, and `wechat-cover-pair-preview.png` for review. Copy or map the 21:9 image to `cover.png`.
- Registration: call `register_rendered_image(..., name="wechat-21x9-cover.png", role="cover", upload_to_cdn=true)` and use the returned `media_id` as `thumb_media_id`.
- Guardrail: the square cover is an artifact for share-preview review only unless the publishing API later exposes a separate field.

### Case 3: 微信正文卡片

- Input: article body cards are explicitly requested by prompt or project `visual_style`, and `article_image_mode` includes content images.
- Recommended path: render one card per approved visual slot, then write `images.json` with slot id, section index, filename, and returned `wechat_url`.
- Registration: each body card uses `role="image"` and `upload_to_cdn=true`; never reuse `wechat-21x9-cover.png`, `cover.png`, or `$COVER_CDN_URL` as a body image.
- Review: fail the card if it contains QR code, contact details, external URL, scan prompt, 加群, or 加微信.

### Case 4: License-Safe Adaptation

- Input: user asks to use the upstream Guizang skill directly.
- Recommended path: explain that the upstream repository is AGPL-3.0 with commercial licensing. Use Anban-native layouts and attribution by default; do not copy `validate-social-deck.mjs`, HTML templates, WebGL assets, or copied CSS.
- Escalation: if direct vendoring is required, stop and request legal/commercial approval before changing plugin assets.
