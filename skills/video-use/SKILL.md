---
name: video-use
description: "Use when editing source footage into finished videos by conversation: 多素材成片剪辑, talking-head cleanup, 去口癖, retake selection, subtitles, color grade, animation overlays, social-ready exports, or transcript-backed video editing with Aliyun FunASR HTTP MCP tools."
---

# Video Use

## 案例库

遇到场景分支、产物格式或质量边界不确定时，先读 [references/examples.md](references/examples.md)。

## 图片比例固定规则

本 Skill 只要涉及生成、选择、裁切、校验或引用图片，必须按以下优先级决定画面比例：

1. 用户/任务明确指定的 `image_ratio`、`size` 或平台规格优先。
2. 项目/频道默认比例次之。
3. 业务默认比例只作兜底：微信文章封面/正文图默认 `16:9`；Seednote/XLS/移动信息流默认 `3:4`；电商、广告投放、视频封面按具体平台素材位要求执行。
4. 不得从模型路由、供应商默认 `size` 或模型能力反推业务比例；模型只决定能力和成本，比例属于创作场景约束。


Use this skill to edit local footage into a polished video. The agent reasons from local word-level transcript files, compact manifests, and on-demand visual drill-downs, then renders through `anban video` local media commands.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `prepare_file_upload` | Prepare a policy-controlled OSS direct upload. Use `purpose="video_audio"`, then upload the local wav to `upload_url` with HTTP PUT. |
| `create_video_asr_task` | Transcribe an OSS-backed `audio_key` or HTTPS `audio_url` through server-side Aliyun FunASR HTTP and return a compact transcript receipt. |
| `prepare_video_transcript_download` | Return a signed download URL for the normalized transcript JSON; save it locally with `anban video save-asr-result`. |
| `query_video_asr_task` | Optional compatibility lookup for an already completed ASR result by `task_id`; returns a compact receipt. |
| `pack_video_transcripts` | Legacy inline packer only; prefer file-based transcript packing through `anban video pack-transcripts`. |

Never call ASR provider HTTP APIs directly and never handle provider API keys. Do not use SRT-only or phrase-only transcription as the editing source; cuts need word boundaries.

## Core Rules

1. Confirm the strategy in plain language before rendering the edit.
2. Cache transcripts under `<videos_dir>/edit/transcripts/`; do not re-transcribe unchanged sources.
3. Audio drives cut candidates; use visual checks only at decision points.
4. Never cut inside a word. Snap cut edges to transcript word boundaries and pad by 30-200ms.
5. Extract each segment first, normalize it to `output_width/output_height`, add short audio fades where needed, then concat.
6. Shift overlays with `setpts=PTS-STARTPTS+T/TB`.
7. Apply subtitles last in the final filter chain so overlays never hide captions; subtitles are applied LAST.
8. Store all session outputs under `<videos_dir>/edit/`, not inside the skill directory.
9. Use absolute paths for source files, transcript files, EDL, overlays, previews, and final output.

## Local CLI Resolution

Before the first `anban video` command, resolve the plugin-local binary once and reuse it for all media commands:

```bash
ANBAN_BIN="${ANBAN_BIN:-}"
ANBAN_DATA="${ANBAN_PLUGIN_DATA:-${CLAUDE_PLUGIN_DATA:-${PLUGIN_DATA:-}}}"
if [ -z "$ANBAN_BIN" ] || ! command -v "$ANBAN_BIN" >/dev/null 2>&1; then
  for root in "$ANBAN_DATA"; do
    [ -z "$root" ] && continue
    if [ -x "$root/bin/anban" ]; then
      ANBAN_BIN="$root/bin/anban"
      break
    fi
    if [ -x "$root/bin/anban.exe" ]; then
      ANBAN_BIN="$root/bin/anban.exe"
      break
    fi
  done
fi
if [ -z "$ANBAN_BIN" ] || ! command -v "$ANBAN_BIN" >/dev/null 2>&1; then
  for root in "${ANBAN_PLUGIN_ROOT:-}" "${CLAUDE_PLUGIN_ROOT:-}" "${PLUGIN_ROOT:-}"; do
    [ -z "$root" ] && continue
    if [ -x "$root/scripts/bootstrap.sh" ]; then
      ANBAN_PLUGIN_ROOT="$root" CLAUDE_PLUGIN_DATA="$ANBAN_DATA" PLUGIN_DATA="$ANBAN_DATA" "$root/scripts/bootstrap.sh" >/dev/null 2>&1 || true
    fi
    for bin_root in "$ANBAN_DATA" "$root"; do
      [ -z "$bin_root" ] && continue
      if [ -x "$bin_root/bin/anban" ]; then
        ANBAN_BIN="$bin_root/bin/anban"
        break 2
      fi
      if [ -x "$bin_root/bin/anban.exe" ]; then
        ANBAN_BIN="$bin_root/bin/anban.exe"
        break 2
      fi
    done
  done
fi
ANBAN_BIN="${ANBAN_BIN:-anban}"
```

Use `$ANBAN_BIN video ...` for every command below. If it still fails, report that plugin bootstrap did not install `bin/anban` and ask the user to rerun the plugin install/bootstrap step.

## Directory Layout

```text
<videos_dir>/
  <source footage>
  edit/
    project.md
    media-manifest.json
    audio/<source>.wav
    transcripts/<source>.json
    takes_packed.md
    edit-candidates.json
    edl.json
    animations/slot_<id>/
    clips_graded/
    master.srt
    verify/
    preview.mp4
    final.mp4
```

## Workflow

1. Create `<videos_dir>/edit/` and run `$ANBAN_BIN video probe --source "$VIDEO" --out "$DIR/edit/media-manifest.json"` before any orientation, overlay, or render decision. The manifest is display rotation aware; use `display_width` and `display_height`, not encoded width/height.
2. For each source, run `$ANBAN_BIN video extract-audio --source "$VIDEO" --out "$DIR/edit/audio/<stem>.wav"`.
3. Call `prepare_file_upload` with `purpose="video_audio"`, `filename="<stem>.wav"`, and `content_type="audio/wav"`; upload the WAV to `upload_url`; call `create_video_asr_task(audio_key=<returned key>)`; then call `prepare_video_transcript_download` if a fresh signed URL is needed.
4. Save transcript JSON locally with `$ANBAN_BIN video save-asr-result --transcript-url "$DOWNLOAD_URL" --out "$DIR/edit/transcripts/<stem>.json"`. This is the file-based transcript flow; do not pass large transcript JSON through tool arguments.
5. Run `$ANBAN_BIN video pack-transcripts --transcripts-dir "$DIR/edit/transcripts" --out "$DIR/edit/takes_packed.md"`.
6. If the user provided a script/copy, run `$ANBAN_BIN video match-script --script "$SCRIPT" --transcripts-dir "$DIR/edit/transcripts" --out "$DIR/edit/edit-candidates.json"` and use matched word ranges; flag unmatched lines instead of inventing source.
7. Read `takes_packed.md` and `edit-candidates.json`, note verbal slips, retakes, strong beats, invalid content, and likely cuts.
8. Ask for or infer target length, aspect, pacing, subtitle style, grade, and overlay needs; write a short strategy and wait for confirmation. If a creative or corrective grade is needed, pre-grade sources with `grade.py` and point the EDL at the graded files; Go render currently rejects non-`none` `grade` values rather than silently ignoring them.
9. Write `edl.json` using transcript word boundaries. Include `output_width`, `output_height`, sources, ranges, optional overlays, and subtitle settings. Run `$ANBAN_BIN video verify --edl "$DIR/edit/edl.json"` before rendering; it must reject overlay dimensions that do not match the EDL output size.
10. Render in stages: `$ANBAN_BIN video render --edl "$DIR/edit/edl.json" --mode draft --out "$DIR/edit/draft.mp4"` for fast fixed-frame cut checks; `--mode preview` for evaluable review with overlays/subtitle file when present; `--mode final` for delivery with final loudness normalization.
11. Self-evaluate rendered output around every cut boundary and at start/middle/end. Check visual jumps, audio pops, subtitle readability, overlay timing, display rotation, and duration.
12. Iterate from user feedback without re-transcribing. Append decisions and final paths to `project.md`.

Compatibility helpers in `scripts/` (`timeline_view.py`, `grade.py`, `render.py`) remain available for visual drill-downs and migration reference, but the primary media IO path is `anban video`.

## Subtitle Defaults

Use Source Han Sans / 思源黑体 for burned subtitles. Prefer these font names or paths in `force_style` and helper patches:

- `Source Han Sans SC`
- `Noto Sans CJK SC`
- `/System/Library/Fonts/PingFang.ttc` only as a local fallback

Default style: white bold text with black outline, lower third but above platform UI safe zones. Keep subtitles applied LAST. For fast social edits, use short chunks; for narrative or education, use natural sentence chunks.

## EDL Shape

Use this minimal shape unless the edit needs more:

```json
{
  "sources": {"take-a": "/abs/path/take-a.mp4"},
  "output_width": 1080,
  "output_height": 1920,
  "ranges": [
    {"source": "take-a", "start": 1.23, "end": 6.78, "beat": "HOOK"}
  ],
  "subtitles": {"enabled": true, "file": "master.srt", "style": "source-han-bold"},
  "overlays": [
    {"file": "animations/slot_01/render.webm", "start": 2.0, "end": 5.0, "x": 0, "y": 0, "width": 1080, "height": 1920}
  ]
}
```

## Animation Overlays

Create each overlay under `edit/animations/slot_<id>/` and hand off to the most specific overlay skill:

- Use official `music-to-video` or `slideshow` skills when the brief matches their HyperFrames workflows, then use `hyperframes-video-overlays` skill for the Anban `edl.json` handoff.
- Use official `remotion-best-practices` skill for Remotion implementation guidance, then use `remotion-video-overlays` skill when React composition, props, or reusable branded templates are useful.
- Use `manim-video-overlays` skill for diagrams, formulas, charts, arrows, timelines, and precise educational motion.
- Use `pil-video-overlays` skill for simple deterministic cards, counters, progress bars, badges, and fallback PNG sequences.

Overlay skills must return `edit/animations/slot_<id>/render.webm` with alpha when possible and an `overlays[]` item for `edl.json` containing `file`, `start`, `end`, `x`, `y`, `width`, and `height`. For example: `{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0,"width":1080,"height":1920}`.

Render overlays before final composition. Verify duration, dimensions, alpha channel, safe zones, and timing against narration. Keep subtitles applied LAST; subtitles are applied LAST so overlays never hide captions.
