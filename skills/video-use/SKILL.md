---
name: video-use
description: "Use when editing source footage into finished videos by conversation: 多素材成片剪辑, talking-head cleanup, 去口癖, retake selection, subtitles, color grade, animation overlays, social-ready exports, or transcript-backed video editing with OpenAI-compatible FunASR MCP tools."
---

# Video Use

Use this skill to edit local footage into a polished video. The agent reasons from word-level transcript JSON plus on-demand visual drill-downs, then renders with ffmpeg helpers.

## Required MCP Tools

| Tool | Use |
| --- | --- |
| `prepare_file_upload` | Prepare a policy-controlled OSS direct upload. Use `purpose="video_audio"`, then upload the local wav to `upload_url` with HTTP PUT. |
| `create_video_asr_task` | Transcribe an OSS-backed `audio_key` or HTTPS `audio_url` through server-side OpenAI-compatible FunASR and return normalized word-level JSON. |
| `query_video_asr_task` | Optional compatibility lookup for an already completed ASR result by `task_id`. |
| `pack_video_transcripts` | Convert normalized transcripts into `takes_packed.md` markdown. |

Never call ASR provider HTTP APIs directly and never handle provider API keys. Do not use SRT-only or phrase-only transcription as the editing source; cuts need word boundaries.

## Core Rules

1. Confirm the strategy in plain language before rendering the edit.
2. Cache transcripts under `<videos_dir>/edit/transcripts/`; do not re-transcribe unchanged sources.
3. Audio drives cut candidates; use visual checks only at decision points.
4. Never cut inside a word. Snap cut edges to transcript word boundaries and pad by 30-200ms.
5. Extract each segment first, add 30ms audio fades, then concat losslessly.
6. Shift overlays with `setpts=PTS-STARTPTS+T/TB`.
7. Apply subtitles last in the final filter chain so overlays never hide captions; subtitles are applied LAST.
8. Store all session outputs under `<videos_dir>/edit/`, not inside the skill directory.

## Directory Layout

```text
<videos_dir>/
  <source footage>
  edit/
    project.md
    transcripts/<source>.json
    takes_packed.md
    edl.json
    animations/slot_<id>/
    clips_graded/
    master.srt
    verify/
    preview.mp4
    final.mp4
```

## Workflow

1. Inventory sources with `ffprobe`; create `<videos_dir>/edit/`.
2. For each source, extract audio:
   `ffmpeg -y -i "$VIDEO" -vn -ac 1 -ar 16000 -codec:a pcm_s16le "$DIR/<stem>.wav"`.
3. Call `prepare_file_upload` with `purpose="video_audio"`, `filename="<stem>.wav"`, and `content_type="audio/wav"`; upload `$DIR/<stem>.wav` to the returned `upload_url` with `curl --fail -X PUT -H "Content-Type: audio/wav" --upload-file "$DIR/<stem>.wav" "$UPLOAD_URL"`; then call `create_video_asr_task` with the returned `audio_key` and save the returned normalized transcript JSON to `edit/transcripts/<stem>.json`. Do not call provider HTTP APIs directly.
4. Call `pack_video_transcripts` with the transcript map and save the returned markdown to `takes_packed.md`.
5. Read `takes_packed.md`, note verbal slips, retakes, strong beats, and likely cuts.
6. Ask for or infer target length, aspect, pacing, subtitle style, grade, and overlay needs; write a short strategy and wait for confirmation.
7. Write `edl.json` using transcript word boundaries. Include sources, ranges, optional grade, optional overlays, and subtitle settings.
8. Use helper scripts from `scripts/`:
   - `timeline_view.py <video> <start> <end>` for filmstrip/waveform checks.
   - `grade.py <in> -o <out>` for grade experiments.
   - `render.py <edl.json> -o preview.mp4 --preview --build-subtitles` for preview, then final render.
9. Self-evaluate rendered output around every cut boundary and at start/middle/end. Check visual jumps, audio pops, subtitle readability, overlay timing, and duration.
10. Iterate from user feedback without re-transcribing. Append decisions and final paths to `project.md`.

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
  "ranges": [
    {"source": "take-a", "start": 1.23, "end": 6.78, "beat": "HOOK"}
  ],
  "grade": "neutral_punch",
  "subtitles": {"enabled": true, "style": "source-han-bold"},
  "overlays": [
    {"file": "animations/slot_01/render.webm", "start": 2.0, "end": 5.0, "x": 0, "y": 0}
  ]
}
```

## Animation Overlays

Create each overlay under `edit/animations/slot_<id>/` and hand off to the most specific overlay skill:

- Use official `music-to-video` or `slideshow` skills when the brief matches their HyperFrames workflows, then use `hyperframes-video-overlays` skill for the Anban `edl.json` handoff.
- Use official `remotion-best-practices` skill for Remotion implementation guidance, then use `remotion-video-overlays` skill when React composition, props, or reusable branded templates are useful.
- Use `manim-video-overlays` skill for diagrams, formulas, charts, arrows, timelines, and precise educational motion.
- Use `pil-video-overlays` skill for simple deterministic cards, counters, progress bars, badges, and fallback PNG sequences.

Overlay skills must return `edit/animations/slot_<id>/render.webm` with alpha when possible and an `overlays[]` item for `edl.json` containing `file`, `start`, `end`, `x`, and `y`. For example: `{"file":"animations/slot_01/render.webm","start":2.0,"end":5.0,"x":0,"y":0}`.

Render overlays before final composition. Verify duration, dimensions, alpha channel, safe zones, and timing against narration. Keep subtitles applied LAST; subtitles are applied LAST so overlays never hide captions.
