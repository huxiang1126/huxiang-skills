# Material motion choreography

时间线拼贴不能停留在“PNG 从左边移进来”。画面是否饱满，不取决于图层数量，而取决于每个重要元素是否拥有一条有因果、有层级、有收束的动态生命线。

## The motion lifecycle

每个 hero / support 素材必须回答五个阶段：

1. **Enter**：它为何在此刻出现，以何种空间或材质逻辑进入。
2. **Settle**：它怎样落稳，让观众确认主体、层级和位置。
3. **Perform / Hold**：它在场时做什么；可以是可读行动、道具联动、姿势切换、环境微动或明确静止。
4. **React**：爆破、撞击、光线、旁白重音、音乐节拍或另一素材到来时，它如何响应。
5. **Exit / Handoff**：主动离场、被下一元素带走、由遮罩收起，或明确保持到切镜。

并非每个素材都必须经历五种动画，但每条非装饰性图层都必须有 `enter`，至少一个 `settle/hold/action/reaction`，以及 `exit` 或明确的 `hold_to_cut/handoff`。单纯从画外平移到静止，只完成了第一阶段。

## Describe function, not a closed preset list

不要试图穷举所有剪辑软件特效。每个动作通过以下六个维度定义：

- `phase`：enter / settle / hold / action / reaction / exit
- `driver`：旁白、SFX、BGM、场景事件、环境、转场或人工编排
- `family`：transform、mask、pose_swap、light、texture、deformation、particle、composite、camera、video_overlay、simulation
- `runtime`：GSAP、SVG、Canvas 2D、CSS、Lottie、Three.js、视频叠层或剪辑器原生效果
- `intention`：揭示、建立身份、证明行动、制造冲击、转换注意力、提示危险、释放压力等
- `intensity`：1–5，决定幅度、速度、粒子量、光强和声音重量

`rule` 是可扩展的自由名称，例如 `paper-slide-settle`、`mask-tear-reveal`、`impact-shake-decay`、`flash-smoke-debris`。新题材可以增加规则，不需要修改分类系统。

## A practical vocabulary

这些只是候选，不是配额：

### Entrance and settle

- 遮罩撕开、纸边掀开、印章压入、墨迹显影
- 快速滑入并带方向性残影，落点清晰后完全锐化
- 缩放进入并平滑减速；严肃题材默认无弹跳
- 从建筑、门洞、船舷或纸张裂口后被遮罩揭示
- 多个同类元素以短 stagger 形成一次组装波，而不是各自表演

### In-clip life

- 人物与所持道具保持接触并同路移动
- 2–3 个姿势 hard swap，表达有限但真实的行动
- 路线、箭头、裂纹、烟迹用 SVG path draw 或 mask progression
- 前中后景小幅速度差；背景纹理慢于人物，人物慢于前景纸边
- 仅在确有需要时加入低幅、有限的 jitter；不要给所有人物套呼吸缩放
- 光扫、阴影位移、局部半调噪声或纸张纤维变化可以给静止主体“环境生命”

### Event reactions and scene effects

- 撞击：目标短促位移/旋转、随后衰减归零，关联 impact SFX
- 爆破：白闪或暖闪 → 主体冲击位移 → 灰尘/碎屑/烟雾叠层 → 清晰余波；不能只放一个火球贴纸
- 光效：光源必须有方向和照射对象；glow 在主体之后，峰值克制，事件后回到稳定状态
- 破坏：裂纹、碎片、遮罩破口和主体位移共享同一个事件时点
- 气氛：烟、雾、雨、灰尘、火星作为独立可控层，持续时间有限
- 音乐响应：只有用户明确授权 BGM 时才可用；先提取节拍/强度数据，再驱动少量主体或背景，不使用全画面无差别弹跳
- 旁白响应：没有音乐时，也可以把重读词、停顿和 SFX 作为事件驱动

### Exit and handoff

- 被下一素材撞走或覆盖，两个动作共享一个因果驱动
- 由纸边、门、地图窗口或相邻画面遮罩收起
- 粒子/墨迹/纸屑化解，但必须在下一阅读窗口前清干净
- 保持到切镜时写 `hold_to_cut`，不要为了满足形式硬加退出动画
- 镜间转场负责离场时，不再给同一素材叠加第二套退出效果

## Motion hierarchy

饱满不等于所有东西同时动：

- 每个时刻只有 1 个主运动焦点，必要时最多 2 个。
- hero 可以使用强动作；support 使用中低强度的因果响应；background 只提供空间或环境生命。
- 同时发生的 intensity 4–5 动作不得超过 `motion_budget.max_simultaneous_high_intensity`。
- 必须安排 quiet windows，让观众有时间读人物、物件和字幕。
- 同类入场不要连续复用；同一镜头的动作可以共享材质逻辑，但要在轴向、速度、遮罩或因果关系上形成差异。

## HyperFrames implementation

- 使用单一 paused、seek-safe GSAP timeline。
- 空间运动只用 `x`, `y`, `scale`, `rotation`；不要 tween `top`, `left`, `width`, `height`。
- 所有重复、抖动、粒子和环境效果必须有限、可 seek、可在明确时点归零；禁止 `repeat: -1` 和未播种的随机数。
- 优先从 HyperFrames Animation 的原子规则组合 2–4 种：平滑 entrance、motion-blur settle、bounded jitter、ambient glow、reactive displacement、particle burst 等。
- 特效复杂到需要真实火焰、流体、人体表演或持续三维破坏时，使用短生成视频、Lottie/Three.js 或视频叠层；不要强迫静态 PNG 假装完成。
- 运行 `npx hyperframes check` 后，再运行 animation map，检查死区、过度重叠、生命周期残留和不确定运动：

```bash
node <hyperframes-animation-skill>/scripts/animation-map.mjs <composition-dir> \
  --out <composition-dir>/.hyperframes/anim-map
```

## Motion-plan contract

每个 `timeline_collage` 场景必须同时拥有：

- `asset-collage.json`：有什么图层、初始几何和基础关键帧
- `motion-plan.json`：为什么动、何时动、由什么触发、使用什么效果、强度多少、怎样结束

示例：

```json
{
  "version": "1.0.0",
  "scene_id": "S06",
  "duration": 6,
  "strategy": "脚夫把瓷箱送上船，船舷灯光在撞击时闪动",
  "motion_budget": {
    "dominant_track_ids": ["porter-motion"],
    "max_simultaneous_high_intensity": 1,
    "quiet_windows": [{"start": 3.4, "end": 4.5, "reason": "看清交货结果"}]
  },
  "tracks": [
    {
      "track_id": "porter-motion",
      "layer_id": "porter",
      "importance": "hero",
      "end_behavior": "hold_to_cut",
      "phases": [
        {
          "phase_id": "porter-enter",
          "phase": "enter",
          "start": 0.2,
          "end": 0.9,
          "driver": "narration",
          "family": "transform",
          "runtime": "gsap",
          "rule": "paper-slide-settle",
          "intention": "建立脚夫身份与运动方向",
          "intensity": 3,
          "finite": true
        },
        {
          "phase_id": "porter-carry",
          "phase": "action",
          "start": 0.9,
          "end": 3.2,
          "driver": "manual",
          "family": "pose_swap",
          "runtime": "gsap",
          "rule": "two-pose-carry-with-prop-lock",
          "intention": "证明脚夫正在搬运而不是站在箱子旁",
          "intensity": 2,
          "finite": true
        }
      ]
    }
  ],
  "events": [
    {
      "event_id": "crate-impact",
      "category": "impact",
      "effect": "箱子落地时短震、灰尘和船灯闪动",
      "cause": "箱子接触甲板",
      "start": 3.2,
      "end": 3.8,
      "targets": ["porter", "porcelain-crate", "ship-light"],
      "runtime": "gsap",
      "intensity": 4,
      "audio_source": "sfx",
      "sound_policy": "sfx",
      "sfx_cue": "wood-crate-impact"
    }
  ]
}
```

## QA

1. 每个非装饰图层都有 motion track。
2. 每条 track 有 enter、在场阶段和明确 end behavior。
3. phase / event 时间均在 scene duration 内。
4. intensity 4–5 的重动作没有超过同时运动预算。
5. effect 必须有 `cause`；爆破、闪光、粒子不能无缘无故出现。
6. `sound_policy: sfx` 必须有 cue；`music_sync` 只有获授权 BGM 时可用。
7. 打开最终母版检查：运动是否帮助理解、是否遮挡字幕、是否在切镜前干净归零。
8. 如果关闭所有装饰特效后，人物行动仍不成立，说明问题在素材/姿势/剪辑，不在特效数量。
