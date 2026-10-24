---
name: hx-poster-reel
description: Make a fast editorial poster-reel fashion film from SKU or street photos and a music track, the way ON FOOT was made - dozens of designed poster layouts (giant condensed headlines with a cut-out figure in front, colour-split panels, serif italics, mirrored headlines, moulded-glass texture, item lists) cut on the beat, typeset as HTML and rendered with headless Chrome. Use for 海报快闪, 版式快闪, 作品集快翻, poster reel, grid layout typography reel, editorial poster film, ON FOOT 的做法. Default 4:5, about 30 s.
---

# hx-poster-reel

先说清楚这份 skill 是什么：**它是 ON FOOT 那一次的做法和代码，记下的是上一次的答案。**
换了素材、换了参考、换了歌，第一件事都是重新量，然后再决定哪些照搬、哪些推翻。
到了 Opus 5.5 这一代，没有这份 skill 也做得出来，它只是省掉几次弯路。

成片例子：34.3 秒，121 张海报，4:5，1080×1350，30 fps，配一首 140 BPM 的 hip-hop。

## 方法：六步

1. **先量参考，不要猜。**
   用 `scripts/measure_ref.py` 拆出每一帧、每一刀、每个镜头的时长。
   ON FOOT 的参考看上去像一段 20 秒的视频，量出来其实是 19 张海报、每张 0.2 秒的 GIF。
   要抄的是它的语法：
   - 每张停多久；
   - 版式有哪几类；
   - 字是怎么排的。

   不要抄它的内容。

2. **先定节拍，再排海报。**
   用 `scripts/beatmap.py` 得出 BPM、拍长、drop 的位置，以及每一拍上 hi-hat 有多密、有没有重低音。
   拿半拍的时长去对参考的单张时长：140 BPM 的半拍是 0.21 秒，正好对上 0.2 秒。
   重拍上海报停住，拍和拍之间每半拍换一张，换一套衣服之前用十六分音符快闪。
   一套衣服占一个 16 拍的乐句。

3. **素材按套分。**
   - 每套 SKU 一个图池。
   - 太小的图放大一倍，用 recraft crisp-upscale。
   - 每套抠 2–3 个全身人像，用 recraft remove-background，只用全身的，半身的切边会露馅。
   - 露齿大笑的不用。

4. **版式写成网页。**
   这类片子的主角是字。大标题字距差一点，整张就廉价，而 PIL 这类图像库做不了字距调整。
   所以每张海报都是 `scripts/poster.html` 里的一个模板，交给浏览器排版，由 `scripts/shoot.mjs` 截图。
   - 约 20 种模板，见 `references/layouts.md`。
   - 配色从素材自己的世界里取：香港街拍就用电车绿、的士红、斑马线黄、电光蓝，一套衣服一组。
   - 文案只用真实的单品名，不编材质，不放价格。

5. **出完先看小样，再拼片。**
   用 `scripts/sheet.py` 把全部海报拼成小样，看三件事：
   - 字有没有互相吃掉；
   - 人有没有挡住整个词；
   - 字有没有出框。

   ON FOOT 第一轮改过的问题，记在 `references/method.md`。

6. **按帧拼片。**
   `scripts/plan.py` 是唯一真相源：时间线、文案、配色、图池都在这里，它输出 `build/shots.json` 和 `build/edl.json`。
   `scripts/assemble.py` 按帧拼成 MP4：
   - 停住的海报只让照片层慢推 3%，字不动；
   - 每套第一张大字海报和每次玻璃转清晰时，配一声真实快门；
   - 响度做到 -16 到 -14 LUFS。

## 硬规则

- 第一帧就要有人、有衣服。不要黑底，不要只有标题。
- 不放价格；材质说法不能编。
- 人像不用露齿大笑。
- 文案写成编辑标题加具体的生活画面，不喊口号。
- 落款放在最后：默认 `huxiang` / `@虎小象`，给别人用时换成对方的。

## 跑起来

一个工程的目录：`tools/`（放 scripts 里的文件）、`img/`（素材）、`fonts/`（Noto Sans SC）、`assets/song.wav`、`build/`、`renders/`。

```bash
npm i                         # 在 tools/ 里装 puppeteer-core
python tools/beatmap.py assets/song.wav
python tools/prep.py NAME:0.5:0.08:1.7     # 玻璃效果：图名:x:y:放大倍数
python tools/plan.py                       # 写出 shots.json 和 edl.json
FIRST=1 node tools/shoot.mjs               # 每张海报先只出一帧
python tools/sheet.py 0 40 build/sheet1.jpg
node tools/shoot.mjs                       # 出全部帧，没改过的海报会跳过
python tools/assemble.py                   # 拼出 renders/OnFoot_master.mp4
```

需要的环境：
- macOS 上的 Chrome，路径不同就设 `CHROME=...`；
- Python 包：numpy、opencv-python、pillow、librosa、soundfile、scipy；
- 字体：New York 和 SF Mono 是 macOS 系统字体，Noto Sans SC 要放进 `fonts/`。

快门声默认取 macOS 系统音效，商用成片要换成授权音效。
