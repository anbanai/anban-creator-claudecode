---
name: video-composition
description: Composes images into MP4 slideshow videos (视频合成) using FFmpeg. Supports transitions and extensible for future video features. Use when assembling images into video. Also use when user mentions '合成视频', '视频', 'MP4', 'slideshow', '图片转视频', '幻灯片视频', or when any pipeline calls for video composition.
---

# 图片视频合成

使用 FFmpeg 将一组图片组装为 MP4 幻灯片视频。

## 前提条件

- 需要安装 FFmpeg（Docker 容器中已预装，本地环境需自行安装）
- 使用 `ffmpeg -version` 验证是否可用

## 输入要求

将工作目录下的图片按顺序组装为视频：

| 文件 | 说明 |
|------|------|
| `cover.png` | 封面图（第一帧） |
| `image_01.png` ... `image_0{N-2}.png` | 内容图（按序号排列） |
| `tail.png` | 尾图（最后一帧） |

所有图片统一输出到 `$DIR/video.mp4`。

## 操作步骤

1. 收集所有图片路径，按顺序排列（封面 + 内容图 + 尾图）
2. 在 `$DIR` 下创建 `concat.txt` 文件，格式如下：
   ```
   file 'cover.png'
   duration 3
   file 'image_01.png'
   duration 3
   file 'tail.png'
   file 'tail.png'
   ```
   注意：最后一帧必须重复一行（不带 duration），否则最后一帧会闪黑。

3. 执行 FFmpeg 命令：
   ```bash
   ffmpeg -f concat -safe 0 -i $DIR/concat.txt \
     -vf "scale=${RESOLUTION:-1080:1440}:force_original_aspect_ratio=decrease,pad=${RESOLUTION:-1080:1440}:(ow-iw)/2:(oh-ih)/2:black" \
     -c:v libx264 -pix_fmt yuv420p -r 24 \
     -y $DIR/video.mp4
   ```

## 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `$RESOLUTION` | `1080:1440` | 输出分辨率，可通过环境变量覆盖 |
| `duration` | 3 秒/张 | 每张图片展示时长 |
| `-r` | 24 | 帧率 |
| `-pix_fmt yuv420p` | — | 兼容性编码，确保各播放器可播放 |

## 高级效果

带淡入淡出等转场效果，见 [transitions.md](references/transitions.md)。

## 完成后

- 验证文件存在：`ls -lh $DIR/video.mp4`
- 报告文件路径和大小给用户
- 清理临时文件 `concat.txt`

## 常见错误

| 错误 | 原因 | 修复 |
|------|------|------|
| `ffmpeg: command not found` | FFmpeg 未安装 | Docker 容器中已预装；本地环境需 `brew install ffmpeg` |
| 输出视频最后一帧闪黑 | concat.txt 最后一帧未重复 | 确保最后一帧在 concat.txt 中出现两次（第二次不带 duration） |
| 输出视频有黑边 | 图片比例与 RESOLUTION 不匹配 | 使用 `force_original_aspect_ratio=decrease` + `pad` 自动填充，或调整 RESOLUTION |
| 输出文件过大 | 图片分辨率高或时长过长 | 降低 RESOLUTION 或减少 duration |

## 与流水线的集成

本 skill 由 rednote 和 xls 流水线在图片生成完成后调用。输入为流水线产出的图片序列（cover.png + image_01...N + tail.png），输出为 `$DIR/video.mp4`。
