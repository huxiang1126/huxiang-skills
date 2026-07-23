# HyperFrames story assembly

HyperFrames 负责把已经下载并标准化的镜头装成完整成片。它不是视频生成模型，也不替代 Story Agent。

## Audio policy

允许：

- `narration.wav`
- 对白
- 与动作或场景一致的非音乐音效
- 很轻的真实环境声

默认禁止背景音乐、旋律、节拍、歌曲或音乐循环，也不用持续的 tonal pad、drone 或节奏性音效伪装 BGM。用户明确要求配乐时，才可按主 skill 的音乐例外处理：核验许可和 Content ID 风险，保留无配乐母版、credit 文件、原始 stem 与 ducked stem。

始终导出并保留：

- `final/narration.wav`
- `final/sfx-mix.wav`
- `final/no-music-reference.wav`
- `final/captions.srt`
- `final/story-master.mp4`

When music is explicitly requested, also keep `final/bgm-original.*`, `final/bgm-ducked.wav`, `final/music-reference.wav`, a separate music master and `music-credit.md`.

## 1. Environment and scaffold

```bash
npx hyperframes doctor
npx hyperframes init <project>/hyperframes --non-interactive
```

把标准化镜头和图片复制到 composition 的本地媒体目录，使用相对路径，禁止 `file://`。

## 2. Narration

优先使用用户提供的旁白。如果没有，先遵循 `voice-direction.md` 试听中文母语音色。ListenHub OAuth CLI、用户已授权的火山声音复刻和本地 TTS 的路由都以 `voice-direction.md` 为准。只有这些路线不可用时，才回退本地 Kokoro：

```bash
npx hyperframes tts <project>/narrative-script.txt \
  --voice <a-visible-z-prefix-Mandarin-voice> \
  --output <project>/final/narration.wav
```

先运行 `npx hyperframes tts --list`，只使用实际列出的中文 voice id。TTS 失败时报告并让用户提供音频，不切换付费 TTS API。

## 3. Transcript and captions

```bash
npx hyperframes transcribe <project>/final/narration.wav
```

- 实际阅读 transcript，修正人名、地名、年代和专有名词。
- 词级时间来自最终旁白音频，不按文稿字数猜时间。
- 中文字幕按自然语义分组，避免单行过长；底部保留平台 UI 安全区。
- 每个字幕组退出后必须显式 hard kill，避免下一镜残留。
- 同步导出普通 `captions.srt`，供剪映/CapCut 后期继续使用。

### Caption direction before rendering

- 读取 `caption-style.json` 和 `ledgers/caption-beats.json`；不能把 SRT 直接套一个统一底板就当成字幕设计。
- `narration` 是安静的阅读层；`thesis` 是少量叙事铰链；`date_event` 是年代和事件锚点。
- 英雄字幕必须参与画面动作，但不能遮挡承诺的人物行动。需要时移动字幕、缩短词组或重排构图，不可缩成人眼难辨的小字。
- 所有进入动画都必须 seek-safe，退出后 hard kill。避免弹跳、抖动、逐字卡拉 OK 和每句同一种转场。
- 最终母版抽取英雄字幕开始、中点、结束帧，逐项检查层级、可读性、避让和语义动作。

## 4. SFX plan and mix

`sfx-cues.json` 每条至少包含 `scene_id`, `at`, `type`, `gain_db`, `reason`。只有说得出叙事作用的 cue 才保留。

本地合成短音效：

```bash
bash scripts/generate-sfx.sh whoosh <project>/sfx/whoosh-01.wav 0.45
bash scripts/generate-sfx.sh paper <project>/sfx/paper-01.wav 0.30
bash scripts/generate-sfx.sh impact <project>/sfx/impact-01.wav 0.35
```

把所有 cue 按分镜时间混为 `final/sfx-mix.wav`。再把旁白与 SFX 预混成 48 kHz stereo `final/no-music-reference.wav`，最终母版使用这个 reference mix，避免“声明的 stems”和真正进入成片的音轨分叉。旁白始终优先，音效不得遮住关键词。不要自动做响度“越大越好”；试听后调低。

若加入配乐，生成独立的 `final/music-reference.wav`，并把两套 reference mix、组成 tracks 与 SHA-256 写入 `ledgers/audio-manifest.json`。最终音频 QA 会把母版解码音频与 reference mix 做容差比对。

## 5. Composition

- 时间轴以最终旁白时长为真相。
- 每个场景都有确定的 start/end；边界后显式隐藏上一场景。
- 生成镜头承担主体动作；HyperFrames 承担字幕、档案文字、时间线、少量转场。
- 不在转场中发明新的故事信息。
- 最后一镜留出 0.4–1.0 秒呼吸，不自动追加音乐尾奏。

### Preserve visual beats

- Do not map one narrative chapter to one video element merely because the storyboard has 8–12 scenes. A chapter may require several clips or overlays.
- Import `ledgers/beats.json` before retiming. Keep every required beat on the timeline until a deliberate content decision marks it `intentionally_removed`, explains why, and removes the user-facing promise.
- After speed changes, trims, or duration compression, measure each human-action beat again. A beat that falls below its minimum visible duration becomes `missing`, even if its source asset still exists.
- Use overlays only when they remain large enough to read. Tiny occupational cut-outs around a central icon do not satisfy coverage.

### Timeline collage composition

For `timeline_collage`, read `timeline-collage.md`.

- Use a full-bleed paper canvas child as the stable background.
- Import transparent PNG people, props and structures as independently timed layers.
- Each layer references one or more lifecycle `beat_ids`.
- Use a paused, seek-safe GSAP timeline; animate spatial motion with `x`, `y`, `scale`, `rotation` and `opacity`.
- Precompute geometry at setup. Do not measure layout during tweens.
- Separate held props when their relationship proves the action.
- A timeline duration can automatically disprove a beat that is too short, but it cannot prove that the action is visually understandable. Human review controls promotion to `visible_in_master`.

### Material motion choreography

Also read `motion-choreography.md` and import the scene's `motion-plan.json`.

- Build each non-decorative layer as a finite lifecycle: enter → settle/perform/react → exit or explicit handoff.
- Use 2–4 compatible atomic HyperFrames Animation rules per scene; do not apply one entrance and one idle preset to every layer.
- Keep one dominant motion focus. Support layers react causally at lower intensity; backgrounds provide restrained environmental life.
- Scene events such as explosion, flash, dust, debris, weather or audio response share one event time and one cause. Couple visual impact and SFX instead of nudging them by eye.
- BGM-driven motion is legal only when the user explicitly authorized music and the audio manifest contains the BGM track.
- All loops, jitter, particles and light pulses are bounded and seek-safe. They must resolve to a clean state before the next reading beat or transition.
- After `npx hyperframes check`, run the HyperFrames Animation `animation-map.mjs` audit and inspect dead zones, simultaneous high-intensity motion and lifecycle residue.

## 6. Validation and preview

在 HyperFrames 项目目录运行：

```bash
node <skill>/scripts/lint-ledgers.mjs \
  --storyboard storyboard.json \
  --beats ledgers/beats.json \
  --claims ledgers/claims.json \
  --captions ledgers/caption-beats.json \
  --safe-zones ledgers/caption-safe-zones.json \
  --generation-log ledgers/generation-log.json \
  --audio-manifest ledgers/audio-manifest.json

npx hyperframes check
node <skill>/scripts/qa-caption-occlusion.mjs \
  hyperframes ledgers/caption-safe-zones.json hyperframes/qa-caption-occlusion.json
npx hyperframes preview
```

必须检查：开头、所有场景中点、所有场景边界、最后一帧，以及 `ledgers/beats.json` 中每个承诺节拍的证据时间。字幕相交检查 FAIL 时不得渲染；修完 overflow、字幕残留、媒体缺失和人物节拍缺失后，再打开最终预览。

## 7. Render and truth check

用户要求完整视频即授权最终渲染：

```bash
npx hyperframes render --output <project>/final/story-master.mp4
```

渲染后用 `ffprobe` 检查实际文件，并生成至少 1 fps 的整片密集接触表。打开 MP4 从头到尾试听和观看。每个承诺节拍必须在最终母版中记录时间戳证据；预览、进度条到 100%、导出窗口、素材接触表都不等于最终文件已验证。

运行最终证据检查：

```bash
bash <skill>/scripts/qa-story.sh \
  final/story-master.mp4 final/captions.srt final/narration.wav final/sfx-mix.wav \
  ledgers/beats.json ledgers/caption-beats.json final/qa-vNN <expected-seconds>

bash <skill>/scripts/qa-audio.sh \
  final/story-master.mp4 ledgers/audio-manifest.json final/qa-vNN/audio
```

若用户要求配乐，把配乐母版、BGM stem 和 credit 文件作为 `qa-audio.sh` 后三个参数。脚本会验证两版视频流一致、音频流不同、BGM 未进入无配乐 mix。

最终 `qa-report.md` 记录：

- dimensions, fps, duration, codecs
- narration present
- SFX present
- captions checked, including every hero-caption entry/hold/exit
- BGM absent by default, or explicit-request music exception verified
- scene-boundary visual check
- known limitations
- promised/visible/missing visual-beat counts and evidence ledger path

交付总状态只有：

- `passed`：技术、字幕、音频、事实与 required beats 全部通过。
- `degraded_delivery`：技术可播放但存在非技术 FAIL；必须先向用户列明缺陷并获得接受，manifest 保存缺陷列表。
- `blocked`：技术失败、来源/授权不清或用户未接受降级。

用于内部审看但没有通过门禁的文件标为 `draft_render`，它不是交付等级。
