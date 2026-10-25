---
name: huxiang-warm-moment
description: Turn a word, sentence, fragment, or incomplete feeling into a warm 4:5 editorial photo-card with Agent interpretation, a verified classical or philosophical thought echo, an English emotional line, quoted headline, restrained sage-green and terracotta marker accents, a small line-art doodle when appropriate, and an inspected 1080x1350 PNG. Use for 暖心配图、温暖时刻卡、一句话配图、情绪价值配图、感受做成图. Do not use for generic text cards, sketchnotes, line-art systems, or long-form infographics.
---

# 虎小象·温暖一刻

把未说完整的情绪，变成一张有思想出处、有英文回声、有一点手作温度的 4:5 图片。继承参考图的情绪语法，不复制猫、蓝天、车顶或固定模板。

## 必须交付

- 交付实际的 `1080x1350` PNG，不只交付提示词。
- 每张图必须包含：带中文双引号的标题、无字场景、经核验的经典原句或思想回声、英文层、作者/典籍署名、原创小注。关系标签只写进来源记录，默认不显示在海报上。
- 使用鼠尾草绿与陶土橙做 1–2 处马克笔强调；不得增加第三种强调色。
- 使用固定海报字体层级：宋体展示标题与经典，黑体承载标签、小注和署名，Baskerville Italic 承载英文。
- 根据文字真实高度动态分配照片与文字区；照片保持全宽，不允许留下无意义的大块底部留白。
- 按情绪选择 0–1 个克制的线稿小图标。若图标会轻佻化创伤、疾病或严肃损失，宁可不用。
- 交付同名 `.source.md`，记录原话、文字关系、出处、翻译、图像提示词、标记词与图标选择。
- 实际打开并检查最终 PNG；不得只凭渲染成功推断质量。

## 开始前

依次读取：

1. `references/agent-contracts.md`：Agent 编排和结构化输出。
2. `references/quote-verification.md`：直接引语、思想回声、翻译和署名规则。
3. `references/editorial-system.md`：英文层、双色马克笔、线稿点缀和 4:5 版式。

除非缺少生成目标或必要附件，否则不要追问。单词、半句话和含混感受本来就是合法输入。

## 工作流

### 1. 接住输入

保留用户原话。区分表面主题、核心感受、两股冲突力量、未被满足的需要、希望获得的情绪价值与不可擅自推断的内容。

不要诊断人格、关系或心理状态。不要默认“失去=该放下”“疲惫=还要坚持”“孤独=不合群”。若内容涉及迫在眉睫的自伤、暴力或医疗危机，先按安全要求回应，不要把危机美化成卡片。

### 2. 强制运行 Agent 链路

按 `references/agent-contracts.md` 执行：

1. 派 `meaning-agent` 生成语义 brief。
2. 用 brief 并行派两名独立 `quote-scout` 和一名 `visual-director`。
3. 将候选交给未参与检索的 `quote-auditor` 核验出处、上下文、文字关系与翻译。
4. 由主 Agent 决定采用 `DIRECT_QUOTE` 或 `THOUGHT_ECHO`，不让 Scout 直接定稿。

Agent 工具不可用时，不得声称已派 Agent；如实说明降级。

### 3. 保证一段有署名的思想回声

不要以“没有完全同义名言”为由交付无署名卡片。按以下次序搜索：

1. 与核心命题直接一致、可定位的经典原句，在 `.source.md` 记录 `DIRECT_QUOTE`。
2. 与核心命题相邻、但不冲突的哲学或经典表达，在 `.source.md` 记录 `THOUGHT_ECHO`。
3. 优先扩展到《道德经》《庄子》《论语》《诗经》《金刚经》等可靠校勘文本，以及世界范围内可核验、公共领域或权利清楚的哲人文字。

允许“接近”，但必须把关系说清楚。不得把相邻思想伪装成作者对用户处境的直接解释；不得把原创小注署给名人。若古籍作者归属有争议，署典籍与篇章，不硬署具体人物。

正常具备联网检索能力时，继续扩大哲学概念而不是直接放弃署名。只有网络/工具确实不可用或安全要求不允许时，才可停止，并明确报告阻塞；绝不编造。

### 4. 建立六层文字

- `标题`：6–16 个汉字；脚本自动添加中文双引号。
- `中文引语`：1–3 行，和署名绑定。
- `English echo`：8–28 个英文词；使用原文或忠实自译，承担情绪节奏，不写生硬逐字翻译。
- `署名`：作者或典籍、作品/篇章、年代或定位的简洁版。
- `原创小注`：35–80 个汉字，不冒充作者的话；可挑一个 2–8 字短语加粗。

在 `.source.md` 明确英文是原文、自译还是独立英文意译。

### 5. 发明场景与点缀

从 `visual-director` 的方案中选择一个低防御、日常、具体的隐喻。使用一位主体、一个动作、一个场所、一种主要情绪，让姿态、距离、方向和空间表达张力。

温暖来自容纳和空间，不来自机械添加夕阳、咖啡、拥抱、萌宠、眼泪或奶油滤镜。

让 Visual Director 额外给出：

- 2–4 个适合马克笔强调的短词；最终只选 1–2 处。
- 一个可选线稿点缀：`sun`、`cloud`、`cat`、`bird`、`sprout` 或 `none`。
- 点缀使用 `sage` 或 `terracotta` 中的一种。

### 6. 先生成无字场景

使用内置图像生成工具，生成不含任何文字、标识、水印、边框的高质量场景图。提示词必须包含自然光、可信材质、克制配色、裁切安全和 `no text, no letters, no captions, no watermark, no logo`。

把最终场景保存到工作目录。不要让图像模型直接书写中英文。

### 7. 精确排版

使用 `scripts/render_card.py`：

```bash
python scripts/render_card.py \
  --image <scene.png> \
  --out <final.png> \
  --title "<标题，不必手写引号>" \
  --title-mark "<2–4字重点>" \
  --quote "<中文经典表达>" \
  --quote-mark "<可选重点>" \
  --english "<英文原文或英文回声>" \
  --credit "——<作者/典籍 · 作品/篇章>" \
  --reflection "<原创小注>" \
  --reflection-bold "<可选的2–8字重点>" \
  --doodle <sun|cloud|cat|bird|sprout|none> \
  --doodle-color <sage|terracotta>
```

最多传入两个 `--*-mark`。标题标记默认鼠尾草绿，中文引语标记默认陶土橙，英文标记默认鼠尾草绿。不要把 URL 放进图片。

### 8. 检查并迭代

打开最终 PNG，检查：

- 标题是否有中文双引号；英文是否存在且有可读的情绪节奏。
- 画面、文字和经典表达各自成立，合在一起产生第三层含义。
- `.source.md` 中的 `经典原句` / `思想回声` 关系是否正确；海报上不需要模板式关系标题。
- 马克笔只有 1–2 处、只用鼠尾草绿和陶土橙、没有盖住文字。
- 小图标是否克制、不幼稚、不与摄影主体竞争。
- 中英文无错字、无溢出，来源与 `.source.md` 一致。

若失败，只做一次针对性修改后重新检查。

## 文案底线

- 给许可感，不下命令；少用“你必须”“你应该”。
- 不承诺“一切都会好起来”，不替关系下结论。
- 不制造“真正爱你的人一定会……”之类道德绑架。
- 不用 AI 腔、成功学和空洞漂亮话。
- 经典必须承载方法或思想，不做装饰性名人贴纸。
