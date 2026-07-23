# Timeline collage editing

`timeline_collage` 把一张稳定的纸张底画布作为舞台，把人物、器物、建筑、地图、纸条、路径和纹理做成独立透明图层，再由 HyperFrames、剪映/CapCut 或其他支持关键帧的剪辑工具完成运动。

它不是生成视频失败后的降级方案，而是与 `first_last`、`first_image` 并列的正式镜头方法。纸拼贴本来就是“分层、摆放、移动、遮挡”的媒介；当镜头动作可以由位置、缩放、旋转、透明度、遮罩或层级变化表达时，时间线拼贴通常比生成式视频更稳定、更可编辑。

## When to choose it

优先 `timeline_collage`：

- 同一底画布上需要依次加入多个人物或社会角色。
- 人物、物件和字幕必须精确避让。
- 需要保证某个行动节拍在母版中稳定停留。
- 动作可以通过图层移动、两到三个姿势切换、遮罩或路径表达。
- 需要频繁调整节奏、构图、层级、角色数量或字幕位置。
- 生成式视频容易出现人物漂移、器物变形、年代错误或画面新增无关对象。

优先生成式视频：

- 真实身体动作、布料、烟火、水面、复杂透视或连续镜头运动是叙事核心。
- 静态图层移动会把关键动作变成“纸片滑动”，无法让角色身份和行为成立。
- 需要自然表演、复杂物理互动或从一个真实状态连续变为另一个状态。

同一场景允许混合：底画布和大多数人物用 `timeline_collage`，局部窗口嵌入一段短生成视频；或用生成视频作背景，把关键人物与字幕作为可控图层叠加。

## Required assets

每个时间线拼贴场景至少包含：

```text
scenes/S06/collage/
├── canvas.png
├── layers/
│   ├── porter-body-v01.png
│   ├── porcelain-crate-v01.png
│   ├── merchant-v01.png
│   ├── ship-v01.png
│   └── route-thread-v01.png
├── asset-collage.json
├── motion-plan.json
└── alpha-qa/
```

- `canvas.png`：1080×1920 或项目最终分辨率；可以跨场景共享，但必须锁定颜色、纹理和安全区。
- `layers/*.png`：真实 RGBA 透明 PNG；主体边缘干净，没有白框、棋盘格、伪透明背景和残余文字。
- 复杂行动允许 2–3 个姿势图层，例如 `scribe-sort-01.png`、`scribe-sort-02.png`，但不能把姿势切换伪装成完整表演。
- 可以把主体和手持物拆开，让箱子、文书、旗帜、册页和人物拥有独立路径。

如果 `image_gen` 没有生成真实 alpha，先在单色背景上得到干净主体，再使用已安装的背景移除能力生成透明 PNG。必须打开 PNG 检查 alpha；文件扩展名是 `.png` 不代表真的透明。

## Asset-collage contract

`asset-collage.json` 推荐字段：

```json
{
  "version": "1.1.0",
  "scene_id": "S06",
  "canvas": "canvas.png",
  "beat_ids": ["S06-B01", "S06-B02"],
  "layers": [
    {
      "id": "porter",
      "file": "layers/porter-body-v01.png",
      "role": "hero",
      "beat_ids": ["S06-B01"],
      "z": 30,
      "anchor": {"x": 0.5, "y": 1.0},
      "initial": {"x": -260, "y": 1180, "scale": 0.78, "rotation": -2, "opacity": 0},
      "keyframes": [
        {"at": 0.2, "x": -260, "opacity": 0},
        {"at": 0.8, "x": 130, "opacity": 1},
        {"at": 2.6, "x": 410, "opacity": 1}
      ]
    }
  ]
}
```

每个图层必须能追溯到 `beat_ids`。没有叙事职责的装饰图层数量要克制；不能为了“画面饱满”堆一圈没有行动的缩小人物。

`asset-collage.json` 只说明图层与几何；`motion-plan.json` 说明动态因果、生命周期和场景特效。二者缺一不可。完整字段、事件系统和动画层级见 `motion-choreography.md`。

## Motion language

HyperFrames 中使用 seek-safe 的 GSAP paused timeline。空间运动只用 `x`, `y`, `scale`, `rotation`，配合 `opacity`；不要在 tween 中改变 `top`, `left`, `width`, `height`。图层几何在 composition 初始化时预先计算，不能在 tween 时读取 DOM 尺寸。

常用动作：

- 纸片滑入后轻微压住背景，形成明确层级。
- 人物与手持物以略不同速度移动，产生可读的携带关系。
- 前景、中景、背景使用小幅速度差，而不是全画面统一推拉。
- 用遮罩让人物从门、船舷、城墙或纸张裂口后出现。
- 同一行动的姿势切换在明确帧点 hard kill，不能两个姿势同时残留。
- 图层进入后至少保留一个稳定可读窗口；不能持续移动到退出。
- 入场落稳后继续设计在场行为、环境生命或事件反应；不能把一段平移当作完整编舞。

避免：

- 所有元素从四周同时飞入。
- 每层都使用相同弹跳或同一 easing。
- 全片不断缓慢漂浮。
- 把静态角色平移称为“整理文书”“织布”“交谈”等实际上没有发生的动作。
- 用几十个小图层制造“丰富”，却让身份和行为不可辨。

## Action truth

时间线拼贴可以准确控制行动的停留，但不能自动证明行动成立。

- “脚夫搬箱子”：人物和箱子保持明确接触关系并沿同一路径移动，可以成立。
- “驿卒送文书”：信使、文书和接收者之间有可见的递送结果，可以成立。
- “书吏整理册页”：只让书吏头像滑入不成立；至少需要册页分组、手部/姿势变化或短视频局部动作。
- “织工织布”：静态织工站在织机旁不成立；应使用姿势切换、局部短视频或删掉该行动承诺。

脚本只能验证图层时间和证据窗口，最终 `visible_in_master` 仍需人工观看最终 MP4 后判断。自动系统允许把节拍降级为 `missing/unclear`，不得仅凭时间线存在把它晋升为可见。

## QA

1. 检查每个 PNG 的尺寸、alpha 通道、裁切边缘和残余伪文字。
2. `asset-collage.json` 中每个 required beat 至少有一个关联图层。
3. `motion-plan.json` 中每个非装饰图层都有完整动态生命周期，scene event 均有原因和收束。
4. 运行 HyperFrames `check` 与 animation map，再在场景入口、中点、出口和每个人物行动窗口截图。
5. 在最终母版中为每个 beat 生成 4 fps 证据条带。
6. 人工确认角色身份、动作、停留、字幕避让和图层残留。
7. 如果画面像 PPT，先改层级、遮罩、节奏和动作关系，不要直接加入更多装饰。
