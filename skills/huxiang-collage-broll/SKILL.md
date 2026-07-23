---
name: huxiang-collage-broll
description: Create complete 9:16 editorial paper-collage story videos or single B-roll shots from a topic, biography, story, spoken line, opinion, or abstract idea. Use for 故事视频, 人物一生, 传记短片, 从故事到分镜, 首尾帧视频, 首图驱动, 透明 PNG 图层剪辑, 完整视频, 字幕, 音效, 拼贴 B-roll, 纸拼贴视频, 半调拼贴, collage explainer, Vox-style collage, or 把一句话做成隐喻配画面. Orchestrates research, narration, lifecycle beats, generative-video routing, editable timeline collage, HyperFrames assembly, captions, sound, local export, and evidence-based final-master QA.
---

# huxiang-collage-broll

把“一个主题”做成有开头、转折和结尾的完整 9:16 故事视频，或把“一句口播”做成约 5 秒纸拼贴 B-roll。

## Two modes

### Story mode — default for practical video work

用户给人物、事件、主题、故事梗概，或要求完整视频、字幕、分镜时使用。必须依次完成：

`事实研究 → 故事主线 → 旁白稿 → 分镜 → 关键帧 → 视频镜头 → 字幕/旁白/音效 → 完整 MP4`

如果用户未指定，默认交付 60 秒、9:16、中文旁白、硬字幕、非音乐音效的完整视频。

### Shot mode — one short line

用户明确只要一句约 5 秒的隐喻 B-roll 时使用。执行原有的“隐喻确认 → 静帧确认 → 视频与 QA”流程。

## Production stack

- Story Agent：研究事实、选择叙事角度、写旁白，不直接生视频。
- Storyboard Director：把旁白拆成镜头，逐镜选择首尾帧、首图驱动、透明图层时间线拼贴或 HyperFrames 原生动效。
- Codex 原生 `image_gen`：风格板、人物参考、首帧和尾帧。
- Gemini / Google Flow / Grok：按当前界面真实可见的首尾帧、图像驱动和修复能力路由，不把能力永久绑定给某个品牌。
- Timeline collage：一张纸张底画布上放置透明 PNG 人物、器物和地图，以素材动态生命周期、关键帧、遮罩、姿势切换、场景特效和层级完成可编辑剪辑。
- HyperFrames：剪辑、字幕、旁白、非音乐音效、转场与最终 MP4。
- ListenHub CLI / 火山引擎声音复刻 2.0：经声音授权与费用确认后的中文旁白候选。
- 本地 `ffmpeg` / `ffprobe`：镜头标准化、倒放、混音、接触表和技术 QA。

## Hard boundaries

### Provider, credential and cost boundary

- 视频生成默认使用用户已经登录的 Codex、Chrome、Gemini/Flow、Grok 订阅界面或本地时间线拼贴，不静默切换付费视频 API。
- ListenHub 优先使用官方 CLI 的 OAuth 用户态。火山引擎声音复刻或 ListenHub API-key 自动化只有在用户明确选择、已配置账户并接受费用时才可使用。
- 不索取、读取、打印、创建或保存 API key、AccessKey、token、AppID secret。凭据由用户在控制台、系统钥匙串或环境中管理。
- 如果页面要求购买套餐、加购额度、绑定支付方式或产生订阅外费用，停在付款前。
- 登录、密码、验证码、CAPTCHA 和账户恢复由用户本人完成。
- 只能克隆用户自己的声音或有可证明授权的声音；不得克隆公众人物、演员、主播、已故人物或来源不明的声音。

### Background music is off by default

- 默认音频只有旁白、对白和非音乐音效，不主动提议或添加背景音乐。
- 用户明确要求配乐时，允许使用 `media-use` 解析现成音乐；必须核对来源、许可和 Content ID 风险，保存 `music-credit.md`。
- 配乐版另存为新版本，并保留已通过的无配乐母版，不得覆盖。
- 配乐必须在人声下动态避让；单独保留原始剪辑 stem 与 ducked stem。
- 不用“氛围声床”伪装音乐；未获明确授权时，持续性音频只能是真实环境声且必须服务场景。

## Required supporting skills and tools

- 生成静帧时使用 `image_gen`。
- 操作已登录的 Grok、Gemini 或 Google Flow 时，先加载并遵循 `chrome:control-chrome`。
- Chrome 无法完成原生 macOS 文件选择或应用动作时才使用 `computer-use:computer-use`。
- 完整故事装配优先使用已安装的 HyperFrames 插件和 `npx hyperframes`；若插件不可用，才回退本地 ffmpeg 装配。

## Story mode workflow

开始前完整阅读：

- `references/story-mode.md`
- `references/visual-language.md`
- `references/subscription-routing.md`
- `references/hyperframes-assembly.md`
- `references/visual-coverage-audit.md`
- `references/caption-direction.md`
- `references/voice-direction.md`
- `references/timeline-collage.md`
- `references/motion-choreography.md`

### Gate S1 — Story Agent

先只做故事，不生成画面。输出：

- 选题边界与目标时长
- 一句话主题判断
- 事实骨架与来源；争议事实单独标记，并写入 `ledgers/claims.json`
- 开头钩子、欲望/冲突、关键转折、结尾回响
- 完整旁白稿

人物传记、历史或现实事件必须先联网核实。区分已证实事实、合理推断和争议说法；`research-dossier.md` 保存可点击来源。不能为了戏剧性捏造心理、对白、时间线或因果。

明确停下，等待用户确认故事角度和旁白。用户说“直接做/发/继续”视为通过当前 Gate。

### Gate S2 — Storyboard Director

故事通过后创建 `storyboard.json`。每个镜头必须包含：

- `scene_id`, `start`, `duration`, `narration`
- `claim_ids`：本镜旁白实际使用的事实主张；纯转场可为空
- `narrative_job`, `visual_proposition`
- `continuity_anchors`
- `motion_method`: `first_last`, `first_image`, `timeline_collage`, `hyperframes_native`
- `beat_ids`：引用 `ledgers/beats.json` 中的唯一节拍 ID
- 路由所需资产：`first_frame`, `last_frame`, `motion_prompt`，或 `asset_collage` + `motion_plan`
- `subscription_route`, `sfx_cue`, `caption_group`, `transition`
- `ledgers/beats.json`：每个节拍的 `beat_id`, `scene_id`, `role`, `action`, `min_visible_seconds`, `state`, `assembly_route`

同时输出易读的分镜表。60 秒片常见 8–12 个叙事章节，但这是起始参考，不是配额；一个章节可以包含多个剪辑单元和多个图层节拍。

场景是叙事章节，不等于最终只有一个剪辑镜头。凡是承诺人物丰富度、社会横截面或“谁在执行/谁在承受”，必须先拆出人物行动节拍；一张含有很多人物的参考板不能替代这些节拍。

Gate S2 即创建 `ledgers/beats.json`，后续全部阶段更新同一 ID。不得在 storyboard、素材表和最终审计中另造三套不互通的节拍编号。分镜还要明确写出“本片决定不展示什么”，避免人物数量和英雄字幕数量变成机械配额。

明确停下，等待用户确认分镜与视觉方向。

### Gate S3 — Style bible and keyframes

1. 创建 `story-style.json`，锁定纸张、色板、半调、镜头语言、字幕安全区。
2. 涉及同一人物反复出现时，先做人物参考板；后续镜头使用同一参考。
3. 用 Codex `image_gen` 生成每镜必需的首帧/尾帧。
4. 实际打开 PNG，检查人物、年代、构图、伪文字和连续性。
5. 生成关键帧接触表，保留 v01、v02，不覆盖旧版本。
6. 更新 `ledgers/beats.json`。生成素材后只能升为 `asset_generated`；仅当人物和行动在标准化镜头中清楚可见，才升为 `visible_in_scene`。

展示整组关键帧并等待确认。通过后才批量生成视频镜头。

关键帧、人物参考板、提示词和素材库存只能证明“有素材”，不能证明“成片会出现”。Gate S3 不得使用“人物覆盖通过”之类措辞，除非明确限定为“关键帧素材覆盖通过”。

### Scene generation

逐镜自主路由，不把模型选择丢回给用户：

- `first_last`：画面必须落到明确结果，或人物/物件连续性重要；使用当前 Gemini、Flow 或 Grok 界面里真实可见的独立起止帧能力。
- `first_image`：从已确认构图出发，后续运动可开放；在 Grok 或 Gemini 当前订阅界面择优。
- `timeline_collage`：人物、器物或地图可拆成透明 PNG，并且动作可以由位移、缩放、旋转、遮罩、姿势切换或层级表达；必须创建 `motion-plan.json`，为重要素材设计入场、落稳、在场行为/环境生命、事件反应与离场/交接。优先 HyperFrames，也可在用户指定的关键帧剪辑工具中完成。
- `hyperframes_native`：时间线、地图、日期、标题、档案翻页、精确排版等图形镜头。

同一场景可以混合 `timeline_collage` 与短生成视频。真实身体表演、复杂物理和连续镜头运动交给视频模型；可控人物、器物、字幕和行动停留交给图层时间线。静态人物滑入不能被描述成实际上没有发生的复杂行动。

画面饱满来自有层级的动态因果，不来自所有素材持续抖动。每个非装饰图层必须有入场、至少一个在场阶段，以及退出或明确 `hold_to_cut/handoff`；爆破、闪光、烟尘、粒子、天气和音乐响应写成有 `cause`、作用对象、强度、声音策略与结束时点的 scene event。具体契约见 `references/motion-choreography.md`。

网页模型名称只记录当前可见标签，不凭记忆猜版本。每个生成镜头必须下载到本地、记录 SHA-256 并写入 `ledgers/generation-log.json`。程序粘贴后若生成按钮仍灰，清空并改用真实键盘输入，再验证页面状态。

每个场景生成后，按 0.5–1.0 秒间隔抽帧检查 `ledgers/beats.json`。主行动人物默认连续清楚可见至少 1.5 秒；次要人物环境默认至少 1.0 秒。被字幕遮住、只剩极小轮廓、身份不可辨或一闪而过，都不算通过。缺失节拍必须补镜头、延长停留或改用 HyperFrames 拆层，不得因为“素材已经生成”而跳过。

标准化可变时长镜头：

```bash
bash scripts/finalize-video.sh \
  <raw.mp4> <scene>/final-noaudio.mp4 <direct|reverse> <target-seconds>

bash scripts/qa-video.sh \
  <scene>/final-noaudio.mp4 <approved-end-frame.png> <scene>/qa <target-seconds>
```

### Narration, captions, SFX and assembly

- 用户提供旁白时优先使用；否则先按 `references/voice-direction.md` 试听并选择中文母语音色。允许 ListenHub OAuth CLI；允许经授权与费用确认的火山引擎声音复刻 2.0。其他路线不可用时才回退本地中文 TTS。
- 先确认实际旁白时长，再锁定总片长和镜头边界。
- 转录旁白得到词级时间，人工校正后生成硬字幕；同时导出 `captions.srt`。
- 字幕是编辑层，不是自动转录的皮肤。先创建 `caption-style.json` 和 `ledgers/caption-beats.json`，把字幕分为 `narration`、`thesis`、`date_event` 三类；关键判断必须与构图、线条、印章、裂纹或纸张运动发生关系。详见 `references/caption-direction.md`。
- 默认模式下，普通字幕负责可读性并保持安静，英雄字幕常用于约 5–8 个叙事铰链。若用户明确要求“字幕是主要视觉系统”或“字幕主导”，可扩展为约 10–16 个不同叙事功能和构图语法的英雄字幕，并保留安静观看窗口。所有数字都是起始参考，不得倒过来支配内容。
- 每个音效必须对应分镜中的可见动作或叙事转折。
- 常见纸张、划动、按键、相机、轻撞击音可由 `scripts/generate-sfx.sh` 本地合成；不得合成旋律。
- 用 HyperFrames 装配镜头、字幕、旁白、SFX 和转场。详细步骤见 `references/hyperframes-assembly.md`。
- 装配前读取每个拼贴场景的 `motion-plan.json`。先编排主运动焦点，再添加 support/background 微动；同一时刻的强运动数量不得超过 motion budget。
- 装配时逐项维护 `ledgers/beats.json`；重定时、裁切或压缩章节后必须重新检查人物行动是否仍然存活。自动系统可以因时长不足把节拍降级，但不能仅凭时间线存在把它晋升为 `visible_in_master`。
- 运行 `scripts/lint-ledgers.mjs`，确保 storyboard、claims、beats、captions、safe zones、generation log 和 audio manifest 互相引用一致。

### Story delivery

交付前必须验证：

- 完整 MP4 已实际渲染到本地，不是预览页面。
- 画幅、时长、音频流可由 `ffprobe` 读取。
- 开头、转折、结尾和所有场景边界已目视检查。
- 字幕与旁白同步，无截断、溢出、错字和残留字幕。
- 字幕层级、关键词强调和画面避让已目视检查；至少检查全部英雄字幕的进入、停留、退出与其对应的叙事动作。
- 为全部英雄字幕维护 `ledgers/caption-safe-zones.json`：用时间关键帧标注人物、行动、脸、手、工具或关键物件保护区。渲染前运行 `scripts/qa-caption-occlusion.mjs`，默认每 0.3 秒或更密采样；持续相交必须阻断渲染。最终 MP4 仍需打开进入、中点、退出证据帧，因为保护区遗漏不会被程序发现。
- 音频符合用户当前要求；若用户未明确要求配乐，则项目中不存在 BGM 轨道。
- `narration.wav`、`sfx-mix.wav`、`captions.srt` 可供后期使用。
- 最终 MP4 生成 1 fps 导航接触表；每个 required beat 还必须生成 4 fps 证据条带和进入/中点/退出帧。1 fps 接触表不能证明短促行动、黑帧或字幕残留不存在。
- 交付描述只允许引用 `visible_in_master` 项目；不能从分镜、提示词、关键帧或素材目录推断成片内容。
- `scripts/qa-story.sh`、`scripts/qa-audio.sh` 与人工完整观看/听审均已完成。脚本验证证据与技术条件，人工负责判断动作是否真实可读。

交付状态只有：

- `passed`：技术、字幕、音频、事实和 required beats 全部通过。
- `degraded_delivery`：技术可播放但有非技术 FAIL；必须向用户列出缺陷并获得明确接受。
- `blocked`：技术失败、授权不清或用户未接受降级。

未通过门禁但供内部审看的文件叫 `draft_render`，不得称为完成或交付。

## Story project directory

v2.3 的 `motion-plan.json` 与 asset-collage v1.1 是新项目和新修订的必需契约。已经通过并归档的 v2.2 项目不原地改写；若要重剪，先复制为新版本，再迁移台账与动态计划。

```text
~/huxiang-collage-broll-projects/YYYY-MM-DD-<title>/
├── story-brief.md
├── research-dossier.md
├── narrative-script.md
├── story-style.json
├── storyboard.json
├── ledgers/
│   ├── claims.json
│   ├── beats.json
│   ├── caption-beats.json
│   ├── caption-safe-zones.json
│   ├── generation-log.json
│   └── audio-manifest.json
├── caption-style.json
├── edit-decisions.md
├── sfx-cues.json
├── references/
├── scenes/01-.../
│   ├── frames/
│   ├── collage/
│   │   ├── canvas.png
│   │   ├── layers/
│   │   ├── asset-collage.json
│   │   └── motion-plan.json
│   ├── raw/
│   ├── final-noaudio.mp4
│   └── qa/
├── hyperframes/
└── final/
    ├── story-master.mp4
    ├── narration.wav
    ├── sfx-mix.wav
    ├── no-music-reference.wav
    ├── music-reference.wav      # only when explicitly requested
    ├── captions.srt
    ├── story-master-music.mp4   # only when explicitly requested
    ├── bgm-original.*           # only when explicitly requested
    ├── bgm-ducked.wav           # only when explicitly requested
    ├── music-credit.md        # only when explicitly requested
    └── qa-vNN/
        ├── beats.snapshot.json
        ├── contact-sheet-1fps.jpg
        ├── coverage-evidence/
        ├── caption-evidence/
        ├── qa-report.json
        └── qa-report.md
```

## Story manifest contract

```json
{
  "skill": "huxiang-collage-broll",
  "version": "2.3.0",
  "mode": "story",
  "video_generation_mode": "subscription_or_local",
  "credentialed_voice_provider": "",
  "background_music": false,
  "status": "story|storyboard|keyframes|scenes|assembly|qa",
  "delivery_grade": "draft_render|passed|degraded_delivery|blocked",
  "known_defects": [],
  "visible_provider_labels": [],
  "scenes": [],
  "beat_ledger": "ledgers/beats.json",
  "visual_coverage": {"required": 0, "visible_in_master": 0, "missing": 0, "verdict": "not_audited"},
  "final_video": "",
  "qa_verdict": ""
}
```

## Shot mode workflow

### Gate 1 — Metaphor

收到短句后先输出：核心含义、情绪、一句话视觉命题、3–6 个关键对象、背景/强调色、组装顺序。停下确认。

### Gate 2 — Still

1. 创建项目与 `visual-spec.json`。
2. 读取 `references/visual-language.md`。
3. 用 `image_gen` 生成 9:16 最终静帧并实际目视检查。
4. 展示静帧，等待确认；拒绝版本不得覆盖。

### Gate 3 — Video and QA

1. `prepare-frames.sh` 创建空白首帧和已确认尾帧。
2. 按 `subscription-routing.md` 选择首尾帧直出或倒放拆散路线。
3. 实际生成、下载并保存网页可见模型标签。
4. `finalize-video.sh` 输出 720×1280、30fps、精确 5 秒、无音轨 MP4。
5. `qa-video.sh` 输出接触表、真实首尾帧和技术报告，并实际打开检查。

```bash
bash scripts/prepare-frames.sh <approved-still.png> <RRGGBB> <item>/frames
bash scripts/finalize-video.sh <raw.mp4> <item>/final-5s-noaudio.mp4 direct 5
bash scripts/qa-video.sh <item>/final-5s-noaudio.mp4 <approved-still.png> <item>/qa 5
```

Shot mode 通过标准：真实首帧为空；中段逐件组装；无切镜、缩放、3D 化、伪文字或水印；尾帧与确认静帧一致；720×1280、约 5 秒、零音频流。

## Repair ladder

1. 故事散：回到 S1，删掉支线，重写主题与转折。
2. 镜头只是旁白插图：回到 S2，让每镜承担动作、证据或变化。
3. 人物漂移：补人物参考板，改用首尾帧或更少的正脸特写。
4. 尾帧漂移：切回当前界面真实支持独立起止帧的 Gemini、Flow 或 Grok 路线；单图路线可用反向拆散。
5. 组装感弱：减少对象，写清逐件滑入/扣合时序。
6. 字幕不同步：以旁白实际音频重新转录，修 transcript 后重建字幕。
7. 音效太满：删到只保留动作点和转折点，不用持续音效填空。
8. 当前订阅额度不足：换另一个已订阅表面；都不可用则报告，不切 API。
9. 人物素材有但成片看不见：这不是素材缺口，而是剪辑/重定时失败；恢复对应节拍、延长可读停留、提高人物景别，再从最终 MP4 重做存活审计。
10. 人物很多但只是站着：回到 S2，把身份名词改成可见动作；例如“书吏”必须在整理册页或递送公文，而不是作为背景头像出现。
11. 时间线拼贴像 PPT：不要继续堆图层；改用前中后景速度差、遮罩、道具与人物联动、姿势切换和稳定观看窗口。复杂动作改用短生成视频，而不是让静态纸片假装表演。
12. 素材只会飞入后停住：为 hero/support 补完整 motion lifecycle；优先加入行动关系、环境生命和有因果的 reaction，不给所有图层复制同一抖动或呼吸预设。
13. 台账互相对不上：停止生成，运行 `lint-ledgers.mjs`；不得靠手工改最终 QA 报告绕过 schema 或 ID 漂移。
14. 网页粘贴后按钮灰色：清空输入框，使用真实键盘输入并验证按钮状态；在 `generation-log.json` 记录 input method 和失败原因。

## Completion truth

故事、分镜、静帧、生成、下载、装配、预览、渲染、导出和分享是不同状态。人物“被计划、被生成、进入镜头、存活于母版”也是不同状态。只报告已经在对应文件、网页或最终播放器中验证过的状态。

完整故事视频只有在本地 MP4、字幕、音频 stems、事实台账、字幕门禁和最终视觉覆盖审计均存在并通过时才叫 `passed`。技术成片存在但覆盖等非技术门失败，只能是 `draft_render`；用户在看到具体缺陷后明确接受，才可成为 `degraded_delivery`。任何报告的总 verdict 必须由分项结果生成，不能手写一个与正文冲突的 `passed`。

## When not to use

- 用户只要提示词，不要真实素材或成片。
- 需要逐层可编辑的专业 NLE 工程、复杂对白表演或真人口播广告。
- 只需要独立音乐创作、选曲或版权处理，而不涉及本技能的故事成片。

## Credits

纸拼贴视觉语言、确认流程和 QA 思路来自 `collage-broll-explainers` 及其上游 `gbro-collage-broll`。本技能在此基础上增加 Story Agent、统一节拍台账、生成视频与透明图层混合路由、HyperFrames 完整装配和取证型 QA，并坚持视频订阅优先、背景音乐默认关闭。
