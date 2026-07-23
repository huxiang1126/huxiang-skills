# Chinese narration direction

中文历史短片的旁白先选“适合文本的母语音色”，再选模型。不能用一个外语音色强行说中文，也不能只凭官网 demo 判断长篇稳定性。

## Routing order

1. 用户提供或指定的声音。
2. 已安装并已登录的 ListenHub 官方 CLI；优先 OAuth 用户态和现成中文 speaker。
3. 用户明确授权、已开通且费用可控的火山引擎豆包声音复刻 2.0。
4. 用户已订阅的网页工具中，试听中文母语音色；优先能正确处理姓名、年号、地名和数字停顿的声音。
5. 本地开源中文 TTS，如已安装的 CosyVoice 类工作流。
6. HyperFrames/Kokoro 本地 voice 作为离线兜底。

不要克隆公众人物、演员、主播、已故人物或用户无权使用的声音。克隆前记录声音所有者、授权范围和参考音频来源。用户自己的声音也要获得本次项目的明确授权。

## ListenHub CLI

官方 CLI 是 `@marswave/listenhub-cli`，需要 Node.js 20 或更高。优先使用 OAuth，不把 API key 写进项目：

```bash
command -v listenhub
listenhub --version
listenhub auth login
listenhub tts create \
  --text "<audition text>" \
  --mode direct \
  --lang zh \
  --speaker-id "<visible speaker id>" \
  --json
```

- `auth login` 打开浏览器时由用户完成登录。
- 先列出或试听当前账户实际可见的中文 speaker，不凭文档猜 voice ID。
- `--json` 的真实返回决定下载字段；不能假定每个版本都返回同名 `audioUrl`。
- 已注册的克隆 speaker 可以和普通 speaker 一样被选择；创建新克隆音色时使用当前官方 ListenHub Voice/账户流程，先确认声音授权和可能的 credit 消耗。
- API-key namespace 只在用户明确要求自动化、已经自行配置凭据并接受费用时使用。Skill 不读取、不打印、不保存 key。

官方参考：

- https://listenhub.ai/docs/en/tools/cli
- https://listenhub.ai/docs/en/tools/cli/commands

## Volcengine voice cloning 2.0

火山引擎是付费、带账户权限的可选路线，不是默认兜底。只有以下条件全部满足才启用：

- 用户明确选择火山引擎并确认账户已开通相应能力。
- 参考声音属于用户本人或已有可证明授权。
- 费用、音色存储和调用范围已确认。
- AppID、token、AccessKey 等凭据由用户在控制台或环境中管理；项目文件、日志和 Skill 不保存它们。

当前官方 2.0 最佳实践建议使用约 14–30 秒、单人、低噪、清晰的 WAV 参考音频。长旁白不要一次硬合成：按语义拆成短段，通常控制在 300 个汉字以内或生成音频少于约 60 秒；逐段检查吞字、截断、音色突变和专名，再拼接。

官方参考：

- https://www.volcengine.com/docs/6561/2298705
- https://www.volcengine.com/docs/6561/1204182

模型、版本、价格和限制可能变化；实际调用前重新读取当前控制台和官方文档。

## Audition before full synthesis

先用 15–25 秒测试段，必须包含：

- 一个四位年份和一个跨度数字；
- 两个人名或地名；
- 一句结构判断；
- 一处破折号或短停顿；
- 一句收尾追问。

按 1–5 分记录：发音、年代断句、权威感、克制度、长句稳定、呼吸自然、连续听 90 秒的疲劳度。任何姓名或年份读错都不能直接生成整片。

试听结果写入 `voice-audition.json`，记录 provider、当前可见模型/voice ID、测试文本、参考音频授权、各项评分和选择理由。

## Documentary direction

- 声音：中文母语、成年、克制、干燥、可信，不做播音腔和预告片腔。
- 节奏：历史事实略快，结构判断放慢；年代前后留短停顿。
- 强调：每句只重读一个逻辑词，不逐字用力。
- 情绪：不模仿悲壮，不替史实制造情绪；靠停顿和句法形成重量。
- 生成后必须重新转录并重建词级时间，旧字幕时间不得沿用。
- 克隆声音不能因为相似度高就忽略伦理和授权；对外发布时保留必要的合成语音披露和提供方水印/元数据。

## Acceptance

交付前人工完整听一遍，逐项检查专名、数字、爆音、吞字、异常换气、句尾上扬和音色漂移。最终旁白时长是时间线真相；换声音后必须重新锁定镜头、字幕和音乐避让。

旁白文件必须写入 `ledgers/audio-manifest.json`，包含 provider、voice ID、文件 SHA-256 和 `voice_authorization`。后者只允许 `user_owned`、`authorized_clone`、`stock_voice`、`local_synthetic`。最终运行 `scripts/qa-audio.sh`；脚本只能验证文件、来源台账和音轨分离，完整听审仍是必须的人工作业。
