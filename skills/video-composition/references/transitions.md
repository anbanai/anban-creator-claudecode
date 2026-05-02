# 转场效果

## 淡入淡出

使用 `filter_complex` 方式实现每张图片的淡入淡出过渡。

### 命令模板

```bash
ffmpeg -loop 1 -t 3 -i cover.png \
  -loop 1 -t 3 -i image_01.png \
  -loop 1 -t 3 -i tail.png \
  -filter_complex \
  "[0]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v0]; \
   [1]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v1]; \
   [2]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v2]; \
   [v0][v1][v2]concat=n=3:v=1:a=0[outv]" \
  -map "[outv]" -c:v libx264 -pix_fmt yuv420p -r 24 \
  -vf "scale=${RESOLUTION:-1080:1440}:force_original_aspect_ratio=decrease,pad=${RESOLUTION:-1080:1440}:(ow-iw)/2:(oh-ih)/2:black" \
  -y $DIR/video.mp4
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `fade=t=in:st=0:d=0.5` | 淡入：从第 0 秒开始，持续 0.5 秒 |
| `fade=t=out:st=2.5:d=0.5` | 淡出：从 `总时长 - 淡出时长` 开始，持续 0.5 秒 |
| `concat=n=3:v=1:a=0` | 拼接 3 段视频流，无音频 |

### st 值计算

`st`（start time）= 每张图片时长 - 淡出时长。如每张 3 秒、淡出 0.5 秒，则 `st=2.5`。

### 动态生成

图片数量不固定时，需要动态生成 filter_complex 字符串：

```bash
# 构建 fade filter 和 concat
inputs=()
filters=()
idx=0
for img in cover.png image_01.png image_02.png tail.png; do
  inputs+=(-loop 1 -t 3 -i "$img")
  filters+=("[${idx}]fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v${idx}]")
  idx=$((idx + 1))
done

concat_inputs=$(printf "[%dv]" $(seq 0 $((idx - 1))) | tr -d ' ')
filter_str=$(IFS='; '; echo "${filters[*]}; ${concat_inputs}concat=n=${idx}:v=1:a=0[outv]")

ffmpeg "${inputs[@]}" -filter_complex "$filter_str" \
  -map "[outv]" -c:v libx264 -pix_fmt yuv420p -r 24 \
  -vf "scale=${RESOLUTION:-1080:1440}:force_original_aspect_ratio=decrease,pad=${RESOLUTION:-1080:1440}:(ow-iw)/2:(oh-ih)/2:black" \
  -y $DIR/video.mp4
```
