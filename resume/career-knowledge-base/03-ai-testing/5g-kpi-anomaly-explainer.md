# 5G gNB KPI 异常解释助手

## 一句话定位

`5G gNB KPI 异常解释助手` 是现有 KPI 自动化回归平台的后处理增强能力：统计 detector 负责发现异常，AI explainer 负责基于证据解释异常、归纳影响范围、给出排查建议，并形成可面试展示的一页报告。

## 为什么这个方向更适合

相比通用 RAG 知识库，这个 Demo 更贴近真实工作：

- 输入来自 5G gNB KPI 回归链路，而不是网上随便找的文本。
- 输出服务于测试工程师日常排障，而不是泛泛问答。
- 能复用已有 `kpi_generator`、`kpi_detector`、Jenkins artifact、runner result JSON。
- 面试时可以讲清楚“AI 如何进入现有测试流程”，而不是只说做了一个 AI Demo。

## 系统位置

```text
automation-portal
-> platform-api
-> Jenkins KPI Runner
-> Python runner
-> kpi_generator
-> kpi_detector
-> KPI AI Explainer
-> run detail / KPI summary / interview report
```

## 和现有 detector 的分工

| 层级 | 负责什么 | 不负责什么 |
|---|---|---|
| `kpi_detector` | CV、t-test、IQR、Poisson、relative change、历史对比、异常标记 | 不负责自然语言解释和测试排查建议 |
| 规则归纳层 | 按 KPI 类型、严重度、场景、历史趋势整理证据 | 不做未经证据支持的根因判断 |
| AI explainer | 把结构化证据转成可读报告和排查建议 | 不替代统计 detector，不直接给确定 root cause |
| 人工复核层 | 判断 AI 解释是否准确、是否夸大、是否遗漏 | 不把 AI 输出当最终结论 |

## 输入材料

第一版输入来自脱敏样例数据：

- `kpi_detector summary`。
- detector 生成的 HTML / Excel 报告摘要。
- workflow result JSON。
- Jenkins stage 和 artifact metadata。
- testline、build、scenario、KPI time window。

## 输出材料

第一版输出 Markdown 报告：

- 总体结论。
- Top anomalies。
- 每个异常 KPI 的证据。
- 可能影响范围。
- 可能原因，但必须标记为待确认。
- 下一步排查建议。
- 需要人工确认的问题。
- AI 输出质量复核结果。

## 第一版限制

- 不接入真实公司敏感日志。
- 不上传原始 trace、账号、IP、真实设备信息。
- 不让 AI 直接生成确定根因。
- 不把 AI 解释写回生产平台，只作为辅助报告。

## 面试 3 分钟讲法

我把 AI 测试方向和自己现有的 5G gNB KPI 自动化回归平台结合起来，设计了一个 KPI 异常解释助手。平台原来已经有 `kpi_generator` 生成 KPI 数据，也有 `kpi_detector` 用 CV、t-test、IQR、relative change 等方法判断异常。我的 AI 层不替代 detector，而是站在 detector 后面，读取异常 KPI、历史对比、build、testline、scenario 和 artifact metadata，把结构化结果解释成测试工程师能执行的排查建议。这样可以帮助测试人员更快理解异常影响范围，同时通过评测集和人工复核控制 AI 幻觉。

## 面试追问准备

- 为什么不让 AI 直接判断 KPI 异常？
- 如何防止 AI 编造 root cause？
- 如果 detector 结果本身不准确，AI 层怎么办？
- 如何评估 AI 解释质量？
- 如何处理真实日志和敏感信息？
- 如何把这个能力挂到现有 portal？
- 如果 KPI 异常很多，如何排序？
- 这个 Demo 和传统测试经验有什么结合点？

## 后续演进

第一版先生成离线 Markdown 报告。后续可以演进为：

- run detail 页面中的 AI explanation 区块。
- 根据 RUN_ID 自动收集 detector summary 和 artifact metadata。
- 与失败样例库结合，给出相似历史问题。
- 加入日志摘要，但只处理脱敏后的关键片段。
