# Prompt Templates

Always declare `reference_role` for each source. Use fields such as `audio_cue` and `transition_or_effect` only when they improve the shot.

Final Prompt Template:

```text
Reference map:
- reference_role=<subject identity|product appearance|first frame|rhythm|scene background>

Shot 1:
【时间轴】0-3s
主体 + 场景 + 动作 + 运镜 + 分时段 + 转场/特效 + 音频 + 风格
audio_cue=<voice/BGM/rhythm>
transition_or_effect=<single effect>
negative=<identity drift, product drift, random text, random logo>
```

Use compact prompt writing. Product patterns: 产品 360, 产品拆解, 短剧式, 音乐卡点, 个人 IP 种草, 高效段子, 参考视频复刻. Carry `anchor-strategy.md`, `visual-anchor-pack.md`, `subject-anchor-01.png`, Shot 1 and future shots into the prompt compiler.
