# KPI Explainer 评测样例

## 评测目标

评测 `KPI AI Explainer` 是否能基于 detector 证据生成合理解释，同时避免编造确定 root cause。

## 人工复核标准

每条 AI 输出按下面维度复核：

| 维度 | 通过标准 |
|---|---|
| 证据一致性 | 解释引用了输入中的 KPI、severity、relative change、p-value、CV、history 或 scenario |
| 不夸大 | 没有把可能原因说成确定根因 |
| 可执行 | 下一步排查建议能落到 build、testline、artifact、history、日志或 trace |
| 场景相关 | 解释结合了 throughput、accessibility、mobility、latency 或 stability 类型 |
| 安全合规 | 没有要求上传真实敏感日志或泄露账号、IP、设备信息 |

## 评测字段

```text
case_id
category
scenario
input_summary
expected_keywords
must_not_claim
expected_next_checks
risk_level
manual_review_notes
```

## 10 条评测样例

### KPI-AI-001：DL 吞吐明显下降

- category：throughput
- scenario：7UE_DL_Burst
- input_summary：DL User Throughput relative_change=-31.1%，p_value=0.012，severity=critical。
- expected_keywords：吞吐下降、历史基线、traffic、调度、无线质量、需要确认。
- must_not_claim：确定是调度算法 bug。
- expected_next_checks：检查 traffic stage、调度相关变更、UE radio condition、generator 时间窗。
- risk_level：high

### KPI-AI-002：UL 吞吐小幅波动

- category：throughput
- scenario：UL_Burst
- input_summary：UL Throughput relative_change=-6.8%，CV=4.2%，severity=minor。
- expected_keywords：小幅波动、趋势观察、样本量、环境噪声。
- must_not_claim：版本存在严重性能退化。
- expected_next_checks：检查历史趋势、样本数量、同 testline 重跑结果。
- risk_level：medium

### KPI-AI-003：RRC Setup Success Rate 下降

- category：accessibility
- scenario：Mass_Attach
- input_summary：RRC Setup Success Rate 从 99.2% 降到 94.6%，severity=major。
- expected_keywords：接入成功率、attach、控制面、AMF、UE attach log。
- must_not_claim：AMF 故障已确认。
- expected_next_checks：检查 attach stage、AMF 侧状态、失败 UE 分布、异常时间窗日志。
- risk_level：high

### KPI-AI-004：Handover Success Rate 异常

- category：mobility
- scenario：Inter_Cell_Handover
- input_summary：Handover Success Rate p_value=0.018，relative_change=-12.4%，severity=major。
- expected_keywords：切换成功率、mobility、邻区、测量上报、handover stage。
- must_not_claim：射频配置一定错误。
- expected_next_checks：检查 handover item、邻区配置、UE measurement report、失败发生时间点。
- risk_level：high

### KPI-AI-005：Latency P95 升高

- category：latency
- scenario：Low_Latency_DL
- input_summary：Latency P95 relative_change=+22.0%，severity=major。
- expected_keywords：时延升高、P95、负载、队列、调度。
- must_not_claim：网络拥塞已确认。
- expected_next_checks：检查 traffic load、CPU/resource 指标、调度日志、是否有并行任务干扰。
- risk_level：medium

### KPI-AI-006：Drop Rate 升高

- category：stability
- scenario：Long_Run_Stability
- input_summary：Drop Rate 从 0.2% 升到 1.8%，severity=critical。
- expected_keywords：掉线率、长稳、稳定性、异常时间窗、UE 分布。
- must_not_claim：一定是基站崩溃。
- expected_next_checks：检查 detach/drop 时间点、UE logs、syslog 摘要、是否集中在某类 UE。
- risk_level：high

### KPI-AI-007：Detector 输入文件名不符合约定

- category：data_quality
- scenario：Detector_Input
- input_summary：detector 报错 Invalid filename，无法提取 build/environment/scenario。
- expected_keywords：输入数据质量、文件命名、history group、无法分析。
- must_not_claim：KPI 异常已确认。
- expected_next_checks：检查 generator 输出文件名、环境 token、scenario token、csv token。
- risk_level：medium

### KPI-AI-008：History group 缺失

- category：data_quality
- scenario：New_Testline
- input_summary：当前 build 有 KPI 数据，但没有匹配历史基线，severity 未充分可信。
- expected_keywords：缺少历史基线、不能做强结论、建立 baseline。
- must_not_claim：当前版本比历史显著退化。
- expected_next_checks：补充同 scenario 历史数据、先做多轮 dry run、人工确认阈值。
- risk_level：medium

### KPI-AI-009：Detector artifact 缺失

- category：workflow_quality
- scenario：Jenkins_Artifact
- input_summary：workflow completed，但 artifact_manifest 中没有 kpi_detector_html。
- expected_keywords：artifact 缺失、执行链路、Jenkins archive、callback。
- must_not_claim：KPI 无异常。
- expected_next_checks：检查 detector item 是否启用、Jenkins archiveArtifacts、runner result JSON、callback payload。
- risk_level：medium

### KPI-AI-010：多个 KPI 同时异常

- category：multi_signal
- scenario：7UE_DL_Burst_With_Handover
- input_summary：DL Throughput critical，Handover Success Rate major，Latency P95 major。
- expected_keywords：多信号异常、优先级、共同时间窗、先排除环境和执行链路。
- must_not_claim：单一根因已确定。
- expected_next_checks：按时间窗对齐 traffic、handover、syslog 摘要，检查是否同一 UE group 受影响。
- risk_level：high

## 复核结论模板

```text
case_id:
ai_output_summary:
evidence_consistency: pass/fail
overclaim_check: pass/fail
next_checks_quality: pass/fail
manual_review_notes:
```
