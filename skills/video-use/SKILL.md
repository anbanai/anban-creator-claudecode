---
name: video-use
description: "Use when editing source footage into finished videos by conversation: 多素材成片剪辑, talking-head cleanup, 去口癖, retake selection, subtitles, color grade, animation overlays, social-ready exports, or transcript-backed video editing with Aliyun FunASR HTTP MCP tools."
---

# Video Use

Use this skill to edit local footage into a polished video. The agent reasons from local word-level transcript files, compact manifests, and on-demand visual drill-downs, then renders through `anban-creator-agent video` local media commands.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `prepare_file_upload` | Prepare a policy-controlled OSS direct upload. Use `purpose="video_audio"`, then upload the local wav to `upload_url` with HTTP PUT. |
| `create_video_asr_task` | Transcribe an OSS-backed `audio_key` or HTTPS `audio_url` through server-side Aliyun FunASR HTTP and return a compact transcript receipt. |
| `prepare_video_transcript_download` | Return a signed download URL for the normalized transcript JSON; save it locally with `anban-creator-agent video save-asr-result`. |
| `query_video_asr_task` | Optional compatibility lookup for an already completed ASR result by `task_id`; returns a compact receipt. |
| `pack_video_transcripts` | Legacy inline packer only; prefer file-based transcript packing through `anban-creator-agent video pack-transcripts`. |

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

1. Create `<videos_dir>/edit/` and run `anban-creator-agent video probe --source "$VIDEO" --out "$DIR/edit/media-manifest.json"` before any orientation, overlay, or render decision. The manifest is display rotation aware; use `display_width` and `display_height`, not encoded width/height.
2. For each source, run `anban-creator-agent video extract-audio --source "$VIDEO" --out "$DIR/edit/audio/<stem>.wav"`.
3. Call `prepare_file_upload` with `purpose="video_audio"`, `filename="<stem>.wav"`, and `content_type="audio/wav"`; upload the WAV to `upload_url`; call `create_video_asr_task(audio_key=<returned key>)`; then call `prepare_video_transcript_download` if a fresh signed URL is needed.
4. Save transcript JSON locally with `anban-creator-agent video save-asr-result --transcript-url "$DOWNLOAD_URL" --out "$DIR/edit/transcripts/<stem>.json"`. This is the file-based transcript flow; do not pass large transcript JSON through tool arguments.
5. Run `anban-creator-agent video pack-transcripts --transcripts-dir "$DIR/edit/transcripts" --out "$DIR/edit/takes_packed.md"`.
6. If the user provided a script/copy, run `anban-creator-agent video match-script --script "$SCRIPT" --transcripts-dir "$DIR/edit/transcripts" --out "$DIR/edit/edit-candidates.json"` and use matched word ranges; flag unmatched lines instead of inventing source.
7. Read `takes_packed.md` and `edit-candidates.json`, note verbal slips, retakes, strong beats, invalid content, and likely cuts.
8. Ask for or infer target length, aspect, pacing, subtitle style, grade, and overlay needs; write a short strategy and wait for confirmation. If a creative or corrective grade is needed, pre-grade sources with `grade.py` and point the EDL at the graded files; Go render currently rejects non-`none` `grade` values rather than silently ignoring them.
9. Write `edl.json` using transcript word boundaries. Include `output_width`, `output_height`, sources, ranges, optional overlays, and subtitle settings. Run `anban-creator-agent video verify --edl "$DIR/edit/edl.json"` before rendering; it must reject overlay dimensions that do not match the EDL output size.
10. Render in stages: `anban-creator-agent video render --edl "$DIR/edit/edl.json" --mode draft --out "$DIR/edit/draft.mp4"` for fast fixed-frame cut checks; `--mode preview` for evaluable review with overlays/subtitle file when present; `--mode final` for delivery with final loudness normalization.
11. Self-evaluate rendered output around every cut boundary and at start/middle/end. Check visual jumps, audio pops, subtitle readability, overlay timing, display rotation, and duration.
12. Iterate from user feedback without re-transcribing. Append decisions and final paths to `project.md`.

Compatibility helpers in `scripts/` (`timeline_view.py`, `grade.py`, `render.py`) remain available for visual drill-downs and migration reference, but the primary media IO path is `anban-creator-agent video`.

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
