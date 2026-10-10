# AI 测试技能地图与差距清单

## AI 测试定位

AI 测试不是只会调用大模型，而是验证 AI 能力在真实测试流程中的可靠性、可解释性、边界行为和可追踪性。对当前求职方向来说，最有说服力的切入点是把 AI 放进 5G gNB KPI 自动化回归链路，而不是做一个脱离业务的通用问答 Demo。

## 当前主线

```text
5G gNB KPI 回归
-> kpi_generator 生成 KPI 数据
-> kpi_detector 做统计异常检测
-> KPI AI Explainer 解释异常和证据
-> 人工复核 AI 输出
-> 面试作品和质量闭环
```

## 能力地图

```text
LLM 基础
-> 结构化输入设计
-> Prompt 输出约束
-> KPI 异常解释
-> 幻觉和过度结论检查
-> 人工复核标准
-> 自动化评测样例
-> 敏感数据脱敏和边界控制
```

## KPI AI Explainer 测试重点

需要掌握：

- 输入 JSON 是否包含 build、testline、scenario、time window、detector summary 和 top anomalies。
- AI 是否只基于输入证据解释，不引入输入中不存在的日志或 root cause。
- AI 是否把“可能原因”和“已确认原因”区分清楚。
- AI 是否结合 KPI 类型，例如 throughput、accessibility、mobility、latency、stability。
- AI 是否给出可执行的下一步排查建议，例如检查 Jenkins artifact、runner timeline、history group、traffic stage、UE log 摘要。
- AI 输出是否经过人工复核和评测样例检查。

Demo 证据：`C:\TA\resume\career-knowledge-base\03-ai-testing\5g-kpi-anomaly-explainer.md`。

## LLM 输出评估

评估维度：

- 证据一致性：是否引用输入中的 KPI、severity、relative change、p-value、CV、history 或 scenario。
- 不夸大：是否避免把可能原因说成确定 root cause。
- 可执行性：下一步排查建议是否能落到 build、testline、artifact、history、日志或 trace。
- 场景相关性：是否结合当前 KPI 类型和测试场景。
- 安全性：是否避免要求上传真实敏感日志、账号、IP 或设备信息。

## Prompt 测试

测试点：

- 单个吞吐异常。
- 多个 KPI 同时异常。
- 历史基线缺失。
- detector artifact 缺失。
- 输入文件名不符合约定。
- AI 被诱导输出确定 root cause。
- 输入证据不足时是否提示需要人工确认。

## 自动化评测集

第一版评测集字段：

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

## 差距清单

| 能力 | 当前状态 | 两个月补强动作 |
|---|---|---|
| LLM/RAG 理论 | 有初步方向 | 保留基础学习，但不作为主作品 |
| KPI AI Explainer | 已确定主线 | 完成输入合同、报告模板和 10 条评测样例 |
| 自动化评测 | 需要形成作品 | 用 `kpi-explainer-eval-cases.md` 做人工复核表 |
| AI 安全测试 | 需要基础表达 | 准备敏感日志脱敏、越权输入、幻觉和过度结论案例 |
| AI Agent 测试 | 后续拓展 | 先不做重 Agent，后续再考虑 RUN_ID 自动收集 artifact |

## 面试表达

我理解 AI 测试的重点不是证明模型“聪明”，而是证明 AI 能力在真实测试链路里是否可靠。比如我的 5G gNB KPI 异常解释助手，统计异常仍然由 `kpi_detector` 完成，AI 只解释 detector 输出的结构化证据，并且必须通过评测样例检查它有没有编造 root cause、有没有引用证据、有没有给出可执行的下一步排查建议。