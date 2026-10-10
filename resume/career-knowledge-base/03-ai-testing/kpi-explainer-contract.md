# KPI Explainer 输入与报告合同

## 目标

这份文档定义第一版 `KPI AI Explainer` 的输入 JSON 和输出 Markdown 报告格式，保证 AI 解释基于结构化证据，而不是自由发挥。

## 输入文件

建议文件名：

```text
kpi_explainer_input.json
```

## 输入结构

```json
{
  "run_context": {
    "run_id": "run-20260519-001",
    "build": "SBTS26R3.ENB.9999.260319.000005",
    "testline": "7_5_UTE5G402T813",
    "testline_alias": "T813",
    "scenario": "7UE_DL_Burst",
    "kpi_window": {
      "start": "2026-05-19 10:00:00",
      "end": "2026-05-19 10:15:00"
    }
  },
  "workflow_context": {
    "runner_status": "completed",
    "jenkins_build_url": "https://jenkins.example/jenkins/job/CIT/job/KPI_Testing/123/",
    "artifact_manifest": [
      {
        "kind": "workflow_result_json",
        "path": "artifacts/python-kpi-runner-result.json"
      },
      {
        "kind": "kpi_detector_html",
        "path": "artifacts/kpi/detector/report.html"
      }
    ]
  },
  "detector_summary": {
    "detection_methods": ["cv", "t_test", "iqr", "relative_change"],
    "total_kpis": 128,
    "anomaly_count": 3,
    "severity_distribution": {
      "critical": 1,
      "major": 1,
      "minor": 1
    }
  },
  "top_anomalies": [
    {
      "kpi_name": "DL User Throughput",
      "kpi_type": "throughput",
      "severity": "critical",
      "current_value": 420.5,
      "baseline_value": 610.2,
      "relative_change_percent": -31.1,
      "cv_percent": 8.7,
      "p_value": 0.012,
      "history_group": "T813::7UE_DL_Burst::Throughput",
      "evidence": [
        "relative_change_percent=-31.1 is beyond expected range",
        "p_value=0.012 indicates statistically significant difference",
        "scenario=7UE_DL_Burst is throughput-sensitive"
      ]
    }
  ],
  "known_constraints": [
    "Input is a detector summary generated from脱敏样例数据.",
    "AI must not claim a confirmed root cause without external log or trace evidence."
  ]
}
```

## 字段说明

| 字段 | 含义 | 面试表达 |
|---|---|---|
| `run_context` | 本次 KPI run 的业务上下文 | 让 AI 知道 build、testline、scenario 和时间窗 |
| `workflow_context` | Jenkins / runner / artifact 上下文 | 让 AI 能把解释挂回自动化执行链路 |
| `detector_summary` | detector 总体统计结果 | AI 不做原始统计判断，只解释 detector 输出 |
| `top_anomalies` | 重点异常 KPI 列表 | AI 解释必须围绕这些证据展开 |
| `known_constraints` | 输出约束 | 防止 AI 编造 root cause 或泄露敏感信息 |

## 输出报告

建议文件名：

```text
kpi_explainer_report.md
```

## 输出模板

```markdown
# KPI 异常解释报告

## Run Context

- Run ID:
- Build:
- Testline:
- Scenario:
- KPI Window:

## Executive Summary

用 3-5 句话说明本次是否存在关键 KPI 异常、影响范围和需要优先排查的方向。

## Top Anomalies

| KPI | Type | Severity | Current | Baseline | Change | Evidence |
|---|---|---|---|---|---|---|

## Evidence-Based Explanation

### KPI 1

- 观察到的异常：
- 证据：
- 可能影响：
- 可能原因：
- 下一步排查：
- 需要人工确认：

## Next Checks

- 检查同一 testline 最近历史记录。
- 检查本次 build 是否包含调度、射频、切换或吞吐相关变更。
- 检查 Jenkins stage、runner timeline 和 generator/detector artifact 是否完整。
- 如有脱敏日志摘要，检查异常时间窗内 UE attach、traffic、handover、detach 事件。

## AI Output Review

- 是否基于输入证据：
- 是否出现确定性 root cause 断言：
- 是否遗漏关键 KPI：
- 人工复核结论：
```

## Prompt 约束

AI prompt 应包含以下约束：

```text
You are assisting a 5G gNB test engineer.
Use only the provided JSON evidence.
Do not invent a confirmed root cause.
Use "possible cause" or "needs confirmation" when evidence is insufficient.
Every recommendation must reference one or more input fields.
Return a Markdown report following the required template.
```

## 常见失败模式

- AI 直接说“根因是调度算法问题”：失败，应改成“可能与调度相关，需要结合调度日志确认”。
- AI 忽略 `scenario`：失败，KPI 解释必须结合业务场景。
- AI 只给泛泛建议：失败，建议必须能落到 testline、build、artifact、history 或日志摘要。
- AI 使用输入中不存在的数据：失败，说明 prompt 或评测规则不足。
