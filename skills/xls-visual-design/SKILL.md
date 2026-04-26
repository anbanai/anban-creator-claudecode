---
name: xls-visual-design
description: Generates cover and content images for WeChat Xiaolvshu (小绿书/图片帖) image posts with 3:4 ratio. Use when creating visual content for WeChat newspic format.
---

# 小绿书图片生成

## MCP 工具

| MCP 工具 | 说明 |
|----------|------|
| `generate_image` (channel_id, prompt, image_type="cover", output_path) | 生成封面（单张） |
| `generate_images` (channel_id, prompt, count, output_dir) | 批量生成内容图 |
| `upload_image` (channel_id, file_path) | 上传图片到微信素材库 |

---

## 平台 Gotcha

小绿书（微信图片帖）最多 20 张图片，发布后图片顺序固定。封面是用户看到的第一张，内容图靠滑动浏览。与小红书相比：微信用户相对成熟，设计感可以更强，但仍需保持视觉一致性。

---

## 使用方式

通过 MCP 工具调用：

1. **生成封面（单张）**：调用 `generate_image`，image_type 设为 `"cover"`，prompt 中描述封面内容和风格
2. **批量生成内容图**：调用 `generate_images`，指定 count 和 prompt
3. **带参考图保持一致**：提供参考图路径，保持视觉风格统一
4. **带风格描述**：在 prompt 中加入风格描述（如"简约质感，米白色调"）

**关键规则**：内容图使用 `generate_images` 批量生成，不逐张调用。

---

## 视觉风格设计原则

根据内容类型和账号调性动态设计，不使用固定预设：

**常见小绿书内容风格参考**：
- 旅行图集：真实感照片风，自然色温，minimal 文字叠层
- 好物测评：产品感，纯净背景，数据对比清晰
- 知识干货：结构感强，信息图式，配色克制
- 日常打卡：生活感，暖色调，随拍质感

**封面与内容图一致性**：
- 无参考图：先生成封面 → 以封面作为参考图批量生成内容图
- 有配置参考图：统一使用配置参考图

---

## 设计规范

见 [references/design-norms.md](references/design-norms.md)

---

## 视频组装（可选）

当用户要求生成视频版本时，使用 FFmpeg 将图片组装为 MP4 幻灯片视频。

### 前提条件

- 需要安装 FFmpeg（Docker 容器中已预装，本地环境需自行安装）
- 使用 `ffmpeg -version` 验证是否可用

### 操作步骤

1. 收集所有图片路径，按顺序排列（封面 + 内容图 + 尾图）
2. 在 `$DIR` 下创建 `concat.txt` 文件，格式如下：
   ```
   file 'cover.png'
   duration 3
   file 'image_01.png'
   duration 3
   file 'image_02.png'
   duration 3
   file 'image_02.png'
   ```
   注意：最后一帧必须重复一行（不带 duration），否则最后一帧会闪黑。

3. 执行 FFmpeg 命令：
   ```bash
   ffmpeg -f concat -safe 0 -i $DIR/concat.txt \
     -vf "scale=1080:1440:force_original_aspect_ratio=decrease,pad=1080:1440:(ow-iw)/2:(oh-ih)/2:black" \
     -c:v libx264 -pix_fmt yuv420p -r 24 \
     -y $DIR/video.mp4
   ```

### 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `scale` | `1080:1440` | 输出分辨率，3:4 竖版 |
| `duration` | 3 秒/张 | 每张图片展示时长 |
| `-r` | 24 | 帧率 |
| `-pix_fmt yuv420p` | — | 兼容性编码，确保各播放器可播放 |

### 带淡入淡出效果

如需更平滑的过渡，使用 filter_complex 方式：

```bash
ffmpeg -loop 1 -t 3 -i cover.png \
  -loop 1 -t 3 -i image_01.png \
  -loop 1 -t 3 -i image_02.png \
  -filter_complex \
  "[0]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v0]; \
   [1]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v1]; \
   [2]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v2]; \
   [v0][v1][v2]concat=n=3:v=1:a=0[outv]" \
  -map "[outv]" -c:v libx264 -pix_fmt yuv420p -r 24 \
  -vf "scale=1080:1440:force_original_aspect_ratio=decrease,pad=1080:1440:(ow-iw)/2:(oh-ih)/2:black" \
  -y $DIR/video.mp4
```

淡入淡出时长为 0.5 秒，`st` 值为 `总时长 - 淡出时长`（如 3-0.5=2.5）。

### 完成后

- 验证文件存在：`ls -lh $DIR/video.mp4`
- 报告文件路径和大小给用户
- 清理临时文件 `concat.txt`
