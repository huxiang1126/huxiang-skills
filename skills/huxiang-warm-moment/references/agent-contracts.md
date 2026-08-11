# Agent 编排契约

## 总则

必须使用独立 Agent 形成“理解—搜索—反证—导演”的分工。并发槽不足时分轮运行或复用已完成的 Agent，但不要让同一 Agent 同时担任引语发现者和最终审计者。

## 第一轮：Meaning Agent

只提供用户原话，不提供预设答案。要求输出：

```json
{
  "surface_input": "用户原话",
  "core_feeling": "主要感受，不做诊断",
  "inner_tension": "同时存在的两股力量",
  "unspoken_need": "未被满足的需要",
  "needed_value": "最终应给读者的许可或支点",
  "themes": ["3-5 个检索主题"],
  "avoid": ["不可强加的解释"],
  "visual_metaphors": ["2-4 个生活隐喻"]
}
```

主 Agent 审核 brief。若它把猜测写成事实，要求重写；不要追问用户来补齐本可合理保留的含混。

## 第二轮：两个 Quote Scouts + Visual Director

把用户原话和已审核 brief 同时发给三名 Agent。

### Quote Scout A

优先检索中文古典与哲学文本，先查《道德经》《庄子》《论语》《孟子》《诗经》《周易》《金刚经》等可靠校勘来源，再扩展公共领域诗文。必须浏览来源并输出 3–5 条完整候选，不得只给“句子 + 作者”。

### Quote Scout B

独立从世界哲学、文学、演讲、作者档案、图书馆、大学或可信校勘文本检索。不得查看 Scout A 的候选。输出 3–5 条同结构候选。

候选结构：

```json
{
  "quote_original": "",
  "author": "",
  "work": "",
  "edition_or_date": "",
  "locator": "页码、章节、笔记编号或时间码",
  "primary_url": "",
  "corroborating_url": "",
  "context_summary": "",
  "semantic_relation": "direct / adjacent / image-only",
  "relationship_label": "DIRECT_QUOTE / THOUGHT_ECHO / REJECT",
  "provenance_status": "verified / probable / unverified / disputed",
  "rights_status": "public-domain / licensed / in-copyright / unclear",
  "translation_status": "self-translated / not-needed"
}
```

### Visual Director

不要画排版稿。输出三个场景，每个包含：主体、动作、环境、光线、距离关系、画面里的空白、它如何表达内在张力、必须避免的俗套。必须有一个不使用人物或萌宠的方案。另输出 2–4 个可被马克笔强调的短词、一个 `sun/cloud/cat/bird/sprout/none` 图标建议及其颜色。

## 第三轮：Quote Auditor

将原始候选交给未参与发现的 Agent。不要告知主 Agent 偏好哪条。要求它：

1. 打开原始来源并定位原句。
2. 搜索 `misattributed`、`apocryphal`、`fake quote`、`误引`、`伪名言`、`出处存疑`。
3. 检查删节、反讽、人物台词、上下文反转和译义偷换。
4. 按 `quote-verification.md` 给出 `DIRECT_QUOTE`、`THOUGHT_ECHO` 或 `REJECT`。
5. 对自译进行回译检查，特别核对否定词、程度词、限定语和概念边界。

## 主 Agent 的裁决

主 Agent 先选 `DIRECT_QUOTE`；没有时从 `THOUGHT_ECHO` 中选择最能照亮用户感受、又不偷换语义的一条。若首轮没有 P4 合格项，扩大哲学概念再检索一轮，不得直接交付无署名版本。只有网络/工具不可用时才停止，且不得编造。

最终保存协作摘要到 `.source.md`：Agent 角色、采用或淘汰的候选、淘汰原因、最终画面隐喻。不要把冗长的内部思考写进文件。

使用以下紧凑结构：

```markdown
# 来源记录

- 用户原话：
- 语义命题：
- 文字关系：DIRECT_QUOTE / THOUGHT_ECHO
- 最终标题：
- 最终引语或原创短句：
- 英文层：原文 / 自译 / 英文意译
- 作者、作品、日期、定位：
- 原始来源：
- 独立佐证：
- 审计结论：
- 淘汰候选与原因：
- 画面隐喻：
- 马克笔重点与颜色：
- 线稿图标与颜色：
- 无字场景提示词：
- Agent 分工：
```
