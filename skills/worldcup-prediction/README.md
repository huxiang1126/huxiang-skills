# worldcup-prediction

2026 世界杯赛前盘口预测总控 Skill。

输入两支国家队，就自动检索赛程、近况、阵容、盘口、天气、场地和市场热度，最后输出：

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
- 单独加入「庄家意图 / 反诱导核查」
- 让球盘和大小球分别判断，但最终只给一个综合主推
- 如果盘口价格已坏或疑似诱盘无法解释，正式输出「本场不建议投注」
- 图 A 是朋友圈预测海报，主推盘口要非常明显
- 图 B 是分析思路长图，参考 `huxiang-travel` 的研究卡片方式，使用 `huxiang-card`，保留底部 logo、头像和署名「虎小象」

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
