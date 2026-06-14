# worldcup-prediction

2026 世界杯赛前盘口预测总控 Skill。

输入两支国家队，就先读取本地回溯账本，再自动检索赛程、近况、阵容、确认首发、盘口、天气、场地和市场热度。它不会直接顺着盘口写总结，而是先做无盘口独立模型，再和市场盘口对照，并把「90 分钟胜负倾向」和「投注主推」明确分开，最后输出：

1. 最终胜负倾向
2. 3 个比分方案
3. 盘口投注建议
4. 朋友圈文案
5. 两张图：预测海报 + 整场比赛分析思路长图

## 触发方式

在支持 Skills 的环境里输入 `/worldcup-prediction`，然后输入：

```text
Korea Republic vs Czechia
```

或：

```text
韩国 vs 捷克
```

## 设计重点

- 先检索，后结论；查不到就写「暂无可靠资料」
- 盘口必须有来源和检索时间，禁止编数字
- 先做无盘口独立模型，再做盘口对照
- 单独加入「庄家意图 / 反诱导核查」
- 单独加入「非正路 / 爆冷可行性」校准
- 单独加入「首发可信度」：已确认首发优先，未确认时标注预测首发
- 单独加入「天气影响」：不只列天气数据，必须说明对进球数、体能、节奏、射门和门将处理球的影响
- 内部回溯标签不能直接展示给球迷，必须翻译成「赛前证据校准」「风险提醒」这类人话表达
- 如果最终顺盘，必须通过「正路说服力门槛」
- 强制区分「90 分钟胜负倾向」和「主推盘口类型」
- 海报禁止只写「看好某队」；必须写「90分钟倾向」和「主推：让球盘/大小球」
- 投注建议必须写清赢盘条件，例如「全场 3 球及以上赢盘」或「加拿大 90 分钟赢球才赢盘」
- 如果主推让球盘，必须把 `-0.25`、`-0.5`、`+0.75` 这类亚洲盘翻译成人话：让平/半、让半球、受让半/一，以及赢盘、走水、赢半/输半条件
- 每次预测前读取 `~/Documents/worldcup-prediction/ledger.jsonl`，用最近错因校准本场判断
- 支持 `-review` 赛后回溯评分，把实际赛果、盘口命中、比分命中和错因标签写回账本
- 支持 `-ledger` 查看最近预测账本、命中率和高频错因
- 让球盘和大小球分别判断，但最终只给一个综合主推
- 如果盘口价格已坏或疑似诱盘无法解释，正式输出「本场不建议投注」
- 图 A 是朋友圈预测海报，主推盘口要非常明显，并使用毛笔字/手写冲击字、英文功能小字和强对抗构图
- 图 B 是分析思路长图，参考 `huxiang-travel` 的研究卡片方式，使用 `huxiang-card`，保留底部 logo、头像和署名「虎小象」
- 图 B 生成前必须读取已验证母版，优先继承 `worldcup-qatar-switzerland-v24-analysis.html` 这类字体和排版正确的分析图；中文字体路径必须保留 `KingHwa_OldSong`（京華老宋体），不能临时改成系统 UI 字体或普通 dashboard 风格

## v2.5.1 的关键变化

这版专门修正「分析思路长图字体和母版被后续优化漏掉」的问题。

图 B 生成前必须执行：

```text
读取已验证 WC26 分析图 HTML 母版
-> 继承 --sans / --serif 中的 KingHwa_OldSong 字体路径
-> 继承 huxiang-card footer：logo + 虎小象
-> 只替换球队、盘口、比分、天气、首发和配色
-> 截图前 rg 检查 KingHwa_OldSong / colophon / 虎小象
-> 截图后实际查看 PNG
```

优先母版示例：

```text
~/Downloads/worldcup-qatar-switzerland-v24-analysis.html
```

## v2.1 的关键变化

这版专门修正「顺着盘口总结」的问题。

流程改为：

```text
无盘口独立模型
-> 盘口市场对照
-> 庄家意图 / 反诱导核查
-> 非正路 / 爆冷路径建模
-> 正路说服力门槛
-> 最终主推：顺盘 / 逆盘 / 大小球 / 不碰
```

如果市场热门方向看起来成立，但缺少 3 条以上非盘口证据，Skill 不能硬推正路，必须改为逆路、大小球或「本场不建议投注」。

## v2.2 的关键变化

这版专门修正「看好某队」语义模糊的问题。

必须拆开：

```text
90分钟胜负倾向：加拿大胜
主推盘口类型：大小球
主推盘口：大 2.5
赢盘条件：全场 3 球及以上赢盘
```

如果主推是大小球，球队胜负只能作为辅助信息，不能被写成投注建议。
如果主推是让球盘，必须写明让球方向和赢盘条件。

## v2.3 的关键变化

这版专门强化让球盘解释。

示例：

```text
主推盘口类型：让球盘
主推盘口：加拿大 -0.5
投注方向：加拿大让胜
让球盘中文解释：加拿大 -0.5 = 加拿大让半球
赢盘条件：加拿大 90 分钟赢球才赢盘
走水/半赢半输条件：打平或输球都输盘，没有走水
```

如果是 `-0.25`、`-0.75`、`+0.25`、`+0.75` 这类盘口，必须写出赢半/输半条件，不能只给符号。

## v2.4 的关键变化

这版加入赛后回溯评分模块。

本地账本：

```text
~/Documents/worldcup-prediction/ledger.jsonl
```

Skill 包内置种子记录：

```text
skills/worldcup-prediction/data/retrospective-ledger.seed.jsonl
```

预测前会检查最近记录，重点看：

- 赛果倾向命中率
- 主推盘口命中率
- 主比分与比分池命中率
- 高频错因标签
- 最近 5 场是否触发连续错因熔断

常见错因标签：

```text
small_ball_overuse
big_ball_overreach
home_conversion_overrate
set_piece_risk_underweight
favorite_handicap_overtrust
score_too_conservative
market_summary_bias
injury_impact_underweight
draw_path_underweight
```

用法：

```text
/worldcup-prediction 美国 vs 巴拉圭 -review
/worldcup-prediction -ledger
```

`-review` 会联网核对实际比分，并把 `result_lean_hit`、`main_pick_result`、`main_score_hit`、`score_pool_hit`、`failure_tags` 写回账本。

## v2.5 的关键变化

这版专门修正「球迷看不懂内部校准」和「天气/首发没有真正进入判断」的问题。

新增要求：

- 最终输出和图片里不再出现 `score_too_conservative`、`set_piece_risk_underweight` 这类内部标签
- 内部回溯会被翻译成球迷能理解的「赛前证据校准」
- 查得到确认首发时，必须输出关键首发和它们对盘口的影响
- 天气必须转成比赛影响：进球数、节奏、体能、射门质量、门将处理球、定位球
- 图 A 海报强化视觉冲击：毛笔字/手写冲击字、英文功能字、队服/国旗强对抗色

示例表达：

```text
首发阵容锚点：土耳其 Güler、Çalhanoğlu 先发，前场创造力增强；澳洲 Souttar 先发，定位球抗压路径更硬。
天气对进球/体能影响：温暖偏闷，后段体能下降会增加定位球和二点球波动，不适合机械压小球。
赛前证据校准：近期复盘提醒，这类比赛不能只看强队名气，弱方定位球和受让保护必须纳入判断。
```

## 输出结构

固定五部分：

1. 最终预测结果
2. 3 个比分方案
3. 盘口投注建议
4. 朋友圈文案
5. 朋友圈海报图 / 分析思路图

## 安装

放入任一 Skills 目录即可：

```bash
~/.codex/skills/worldcup-prediction/
~/.claude/skills/worldcup-prediction/
```

GitHub 仓库结构：

```text
skills/worldcup-prediction/SKILL.md
skills/worldcup-prediction/README.md
```

## 免责声明

本 Skill 输出为赛前个人分析，仅供娱乐参考，预测无法保证赛果。请遵守所在地法律法规，理性看待，不构成任何投注邀约。
