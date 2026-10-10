# 两周 AI 测试 Demo 计划

## Demo 名称

5G gNB KPI 异常解释助手。

## 一句话定位

基于现有 `kpi_generator` / `kpi_detector` / Jenkins artifact 链路，把 detector 的统计异常结果转成测试工程师能读懂的异常解释、证据摘要、排查建议和人工复核清单。

## 技术范围

第一版不直接处理公司敏感日志，不替代已有统计 detector，而是在 detector 输出之后做解释增强：

```text
kpi_detector summary
-> top anomalies / history context / workflow metadata
-> kpi_explainer_input.json
-> rule-based evidence grouping
-> AI explanation prompt
-> kpi_explainer_report.md
-> manual review result
```

## 两周拆解

### Day 1-2：定义样例数据和输出格式

- 准备 3 类脱敏模拟异常：吞吐下降、接入成功率波动、掉线或切换类指标异常。
- 定义 `kpi_explainer_input.json` 字段：build、testline、scenario、time window、detector summary、top anomalies、history context、workflow artifacts。
- 定义 `kpi_explainer_report.md` 输出结构：结论、证据、可能原因、下一步排查、人工确认项。

### Day 3-5：实现规则解释和摘要生成

- 从 detector summary 中提取异常 KPI、p-value、CV、relative change、severity、history group。
- 按 KPI 类型归类：throughput、accessibility、mobility、latency、stability。
- 先不用大模型，生成固定结构 Markdown 报告，确保证据链清楚。

### Day 6-8：接入 AI 解释层

- 用 prompt 模板让 AI 根据结构化 JSON 输出解释。
- 强制要求 AI 只基于输入证据，不输出确定 root cause。
- 输出必须包含“证据”“可能原因”“下一步排查”“需要人工确认”。

### Day 9-10：建立 AI 解释评测集

- 准备 10 条 KPI 异常解释用例。
- 每条记录 `expected_keywords`、`must_not_claim`、`expected_next_checks`。
- 人工评估 AI 输出是否准确、是否夸大、是否遗漏关键证据。

### Day 11-12：和现有平台叙事衔接

- 把它描述成 `kpi_detector` 的后处理增强能力。
- 说明输出可以挂到 portal 的 run detail / KPI summary 页面之后。
- 准备一张端到端链路图和一页 Demo 说明。

### Day 13-14：面试材料

- 写 3 分钟讲稿：为什么做、接在哪、解决什么问题。
- 写 8 分钟讲稿：统计 detector 与 AI explainer 如何分工。
- 准备 8 个追问：为什么不让 AI 直接判断异常、如何防止幻觉、如何评估解释质量、如何保护敏感日志。

## 评测集字段

```text
case_id
category
scenario
input_summary
expected_keywords
must_not_claim
expected_next_checks
risk_level
actual_explanation
actual_next_checks
pass_fail
manual_review_notes
```

## 面试讲法

这个 Demo 的重点不是“我做了一个 AI 聊天工具”，而是把 AI 放到真实测试链路里。现有 detector 负责统计异常判断，比如 CV、p-value、relative change 和历史对比；AI explainer 只负责把这些结构化证据解释成测试工程师能执行的排查建议。这样既能体现 AI 应用能力，也能体现测试视角：证据约束、幻觉控制、人工复核和评测集设计。

## 证据材料

- 主文档：`C:\TA\resume\career-knowledge-base\03-ai-testing\5g-kpi-anomaly-explainer.md`
- 合同文档：`C:\TA\resume\career-knowledge-base\03-ai-testing\kpi-explainer-contract.md`
- 评测样例：`C:\TA\resume\career-knowledge-base\03-ai-testing\kpi-explainer-eval-cases.md`
- 现有 detector：`C:\TA\jenkins_robotframework\test-workflow-runner\internal_tools\kpi_detector\detector.py`