# 自动化测试技能地图

## 核心能力结构

```text
测试策略
-> 用例设计
-> 自动化可行性分析
-> 关键字 / 框架封装
-> CI 回归执行
-> 报告与失败分析
-> 维护和持续优化
```

## Robot Framework + Python

掌握重点：

- `.robot` 用例结构。
- 关键字封装和复用。
- Python library 扩展。
- 参数化、setup/teardown、tag 和 suite 管理。
- 与 Jenkins 回归集成。

项目证据：5G gNB 系统测试与自动化回归建设。

面试表达：我使用 Robot Framework 不只是写单个 case，而是围绕团队复用做公共关键字规划，把环境控制、UE 操作、基站配置、日志采集等动作封装出来，支持多个 feature 和 release 复用。

## Pytest + Allure

掌握重点：

- 接口测试。
- 正常路径、异常路径和数据一致性验证。
- fixture、参数化和测试报告。
- 与 API contract 和数据库记录联动验证。

项目证据：自动化测试平台 `platform-api` 的接口验证和回调链路测试。

## Jenkins 自动回归

掌握重点：

- 定时触发和参数化 Job。
- Pipeline stage 拆分。
- Agent 执行环境。
- artifact 归档。
- 失败归因和日志分析。

项目证据：CIT / CRT / CDRT 回归任务和 KPI runner job。

## 接口测试与数据一致性

掌握重点：

- RESTful API 入参、响应和状态码。
- callback payload 验证。
- run 状态流转。
- API 返回、数据库记录、Jenkins build 和 artifact 的交叉验证。

## 差距清单

| 能力 | 当前状态 | 补强动作 |
|---|---|---|
| Pytest 高级 fixture | 有基础项目实践 | 用 platform-api 整理 5 个典型测试案例 |
| Mock / Test Double | 需要补强表达 | 准备 Jenkins callback mock 场景 |
| API 性能测试 | 有系统性能经验，接口性能表达不足 | 准备轻量压测思路和指标说明 |
| 测试报告可视化 | 有 Allure 和 Jenkins 报告概念 | 结合 Dashboard Demo 补图表表达 |