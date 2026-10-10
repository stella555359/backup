# 03 AI Testing

这个目录用于把 AI 测试方向和现有 5G gNB 自动化测试经历结合起来，重点不做泛化 Demo，而是做能嵌入 KPI 自动化回归链路的辅助能力。

## 当前主线

首选 Demo：`5G gNB KPI 异常解释助手`。

它复用现有 `kpi_generator` / `kpi_detector` / Jenkins artifact / runner result JSON 链路，让 AI 站在统计检测结果之后，帮助测试工程师解释异常、总结证据、生成排查建议和面试作品材料。

## 输出目标

- `5g-kpi-anomaly-explainer.md`：Demo 主文档，说明定位、输入输出、链路和面试讲法。
- `two-week-ai-testing-demo-plan.md`：两周落地计划。
- `kpi-explainer-contract.md`：`kpi_explainer_input.json` 与 Markdown 报告格式。
- `kpi-explainer-eval-cases.md`：10 条评测样例和人工复核标准。
- `ai-testing-learning-map.md`：AI 测试学习地图。

## 推荐理解

```text
Jenkins KPI Runner
-> Python runner
-> kpi_generator
-> kpi_detector
-> KPI AI Explainer
-> 异常解释 / 排查建议 / 面试作品
```

## 取舍原则

- 不让 AI 直接替代统计 detector。
- 不让 AI 编造确定 root cause。
- AI 输出必须基于输入证据，使用“可能原因 + 下一步确认”的表达。
- 第一版使用脱敏样例数据，不接入真实公司敏感日志。