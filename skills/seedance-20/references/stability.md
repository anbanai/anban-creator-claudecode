# Stability

Common failure modes: 引用模糊, 镜头指令冲突, 短时长内容过载, 素材无归属, 忽视音频, 复杂度与时长不匹配. Keep each shot simple and bind every reference to `reference_role`.

Camera language must be singular per shot: 推镜头, 拉镜头, 摇镜, 跟拍, 环绕, 俯拍, 仰拍, 特写, 中景, 全景. Do not combine conflicting camera moves.

When generated anchors are needed, pass `ref_image_path` for derived anchors and require verification score >= 0.75 when numeric scoring exists. The 主锚定图 owns identity; derived anchors may show state, product, first frame, or tail frame but must not reinvent the subject.
