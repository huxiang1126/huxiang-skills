# Story mode

## Story Agent contract

Story Agent 的工作不是把资料按年份排列，而是从事实中找出一个可以被观看的变化。

### Input normalization

从用户输入推导并写入 `story-brief.md`：

- subject：人物、事件或主题
- audience：默认中文大众观众
- duration：默认 60 秒
- aspect_ratio：默认 9:16
- tone：默认克制、清楚、有情绪但不煽情
- factuality：`factual`, `mixed`, `fictional`
- final_question：观众看完应带走什么判断

### Research for factual stories

1. 优先传主本人/机构档案、正式采访、权威传记、主流媒体和原始记录。
2. 为每个关键事实保存来源、日期和一句证据摘要。
3. 标记 `verified`, `contested`, `inference`, `omit`。
4. 争议人物不使用未经证实的指控制造钩子。
5. 不能确认的细节删掉或在旁白中明确限定。

保留易读的 `research-dossier.md`，同时把会进入旁白、年份字幕或结论的事实写入 `ledgers/claims.json`，使用 `schemas/claims.schema.json`。日期字幕通过 `claim_ids` 引用它，避免研究和最终文案断线。

`research-dossier.md` 推荐表格：

| Claim | Status | Source | Story use |
| --- | --- | --- | --- |
| 可验证事实 | verified | URL | 建立时间线 |
| 多方说法不一 | contested | URLs | 明确争议或删除 |

### Narrative spine

先写一句主题判断，再选择能证明它的最少事件。推荐结构：

1. Hook：结果、矛盾或反常识，不是空泛提问。
2. Origin：人物/问题从哪里开始。
3. Want：他想改变什么。
4. Escalation：成功、代价或阻力如何扩大。
5. Turn：哪一个选择或事件改变轨迹。
6. Aftermath：结果与代价。
7. Echo：回到主题，留下判断而非口号。

传记片不是“出生—成长—成功—去世”的流水账。60 秒通常只保留 5–8 个决定性事实。

### Narration rules

- 每句只承担一个事实或一个转折。
- 用具体动词和可见名词，不堆抽象评价。
- 不写镜头无法承载的大段并列信息。
- 不替真实人物编造内心独白或对白。
- 旁白完成后朗读计时；以实际音频为最终时长真相。
- 结尾让开头获得新含义，不写“让我们永远记住”。

## Storyboard Director contract

每个镜头必须改变观众所知道、所感受或所期待的东西。相邻镜头若承担同一任务，合并。

### Motion method selection

| Method | Use when | Required assets |
| --- | --- | --- |
| `first_last` | 有明确状态变化、必须落到指定构图、人物连续性重要 | approved first + last frame |
| `first_image` | 起始构图要锁定，运动过程可开放 | approved first image |
| `timeline_collage` | 一张底画布上需要精确摆放、移动、遮罩和保留多个人物/物件 | background canvas + transparent PNG layers + `asset-collage.json` + `motion-plan.json` |
| `hyperframes_native` | 时间线、标题、地图、档案、日期、精确图形/文字 | local assets + HTML composition |

不要为了“高级”强用首尾帧。生成模型并不天然高于剪辑：人物和器物只需要进入、移动、交接、排列、遮挡或停留时，优先用可编辑的透明图层时间线拼贴。真实步态、布料、复杂表演和物理互动更适合首图驱动；明确起终状态更适合首尾帧。

### Continuity bible

跨镜头记录：

- character identity and age range
- costume / silhouette
- dominant colors and paper stock
- halftone scale and outline thickness
- recurring symbolic object
- screen direction
- factual era markers

真实人物跨年代出现时，每个年龄段建立单独参考，不用一张脸强行覆盖一生。

### Storyboard JSON example

```json
{
  "scene_id": "S03",
  "start": 12.4,
  "duration": 5.8,
  "narration": "……",
  "narrative_job": "第一次重大转折",
  "visual_proposition": "狭小舞台在纸层展开后变成体育馆",
  "continuity_anchors": ["young-era-reference", "red-paper-accent"],
  "motion_method": "first_last",
  "beat_ids": ["S03-B01", "S03-B02"],
  "first_frame": "scenes/S03/frames/first-v01.png",
  "last_frame": "scenes/S03/frames/last-v01.png",
  "motion_prompt": "locked camera...",
  "subscription_route": "visible UI label recorded at generation time",
  "sfx_cue": [{"at": 0.0, "type": "paper"}, {"at": 4.7, "type": "impact"}],
  "caption_group": "C03",
  "transition": "paper-wipe"
}
```

## Lifecycle beats and human-action contract

A scene is a narrative chapter, not proof that one visual can carry its entire duration. Create the single lifecycle ledger at `ledgers/beats.json` during storyboard design. Storyboard scenes contain only `beat_ids`; do not duplicate editable beat objects inside both files.

```json
{
  "version": "2.3.0",
  "coverage_required": true,
  "beats": [
    {
      "beat_id": "S06-B03",
      "scene_id": "S06",
      "required": true,
      "role": "dock porter",
      "action": "carries a porcelain crate from ship to merchant",
      "story_function": "shows who physically moves late-Ming trade",
      "min_visible_seconds": 1.5,
      "state": "planned",
      "asset": "scenes/S06/assets/dock-porters-v01.png",
      "assembly_route": "timeline_collage"
    }
  ]
}
```

Rules:

- Use a role plus a visible verb. `scribe` is incomplete; `scribe sorts registers and hands one sheet to a courier` is usable.
- Every scene must reference at least one lifecycle beat; a beat may be human, object, map, date or system change.
- A cast sheet or reference board is not a visual beat.
- One collage containing six occupations does not prove six occupations will be readable in the edit.
- Every abstract system beat should be paired with who executes it, benefits from it, or bears its cost when that is central to the story.
- Required beats start at `planned`; later production stages update the same record but may not silently delete or rename it.
- A deliberate narrative cut uses `state: intentionally_removed`, `required: false` and a written `removal_reason`. It also removes the corresponding user-facing promise.
- Numeric scene counts and minimum durations are defaults, not quotas. The storyboard must also state what the film deliberately will not show.

## Example: a life story

“做一个关于迈克尔·杰克逊一生的故事”触发 factual biography：

1. 先研究并限定片长，不能直接生成童年、舞台、争议、去世的随机蒙太奇。
2. Story Agent 提出一个可论证的主线，例如“一个把舞台控制到极致的人，也越来越难控制舞台之外的叙事”。这只是待证叙事，不是自动事实。
3. 用权威来源筛选能支撑主线的事件，争议内容标注来源与限制。
4. 用户确认旁白后再分镜；每个年龄段有独立人物参考。
5. 演出规模变化可用首尾帧；舞步或舞台移动可用首图驱动；唱片数字、时间线和字幕用 HyperFrames。

故事主线必须来自研究结果和用户选择，示例不能被当作固定模板。
