# 5G gNB E2E KPI 自动化回归测试平台

## 一句话定位

基于 FastAPI、React、Jenkins、Python Runner、Robot Framework 和 SQLite 构建端到端 KPI 自动化回归测试平台，实现从测试配置、任务触发、执行编排、KPI 后处理到结果回传的闭环。

## 背景与痛点

原有 KPI 回归流程分散在人工配置、Jenkins Job、Robot 用例、脚本和结果文件中，任务触发、参数传递、执行状态和结果分析缺少统一入口。随着测试线、版本和 KPI 后处理需求增加，手工执行容易出现参数不一致、结果回收不及时、失败定位成本高的问题。

## 我的职责

- 主导平台整体架构拆分，明确 `automation-portal`、`platform-api`、Jenkins、Python runner 和 KPI 后处理的职责边界。
- 设计 FastAPI 后端运行契约，支持 run 创建、状态查询、Jenkins trigger、callback 回写和 KPI metadata 聚合。
- 规划 Jenkins Pipeline 调度链路，复用 Jenkins 的长任务、日志、artifact、credential 和 agent 能力。
- 设计 Python workflow runner，用于处理 stage/item 编排、串并行执行、时间戳和结果 JSON。
- 规划 KPI AI Explainer 后处理增强能力，将 detector 异常结果转成证据摘要、影响解释和排查建议。
- 使用 AI assisted 方式辅助需求拆解、接口设计、代码实现和测试设计，并进行人工复核。

## 技术架构

```text
automation-portal
-> platform-api
-> Jenkins Pipeline
-> UTE common bootstrap
-> Robot or Python runner
-> KPI generator / anomaly detector
-> KPI AI Explainer
-> result JSON / artifact
-> Jenkins callback
-> platform-api run store
-> portal result view
```

## 关键设计点

### 为什么保留 Jenkins

Jenkins 适合承担长任务调度、agent 派发、日志保存、超时控制、artifact 归档、credential 管理和失败定位。平台不直接在 FastAPI Web 进程里执行长任务，避免阻塞 API 服务，也更接近真实自动化执行环境。

### 为什么引入 Python runner

传统 `.robot` 用例适合稳定串行流程，但新的 KPI workflow 需要 stage/item 组合、串并行混合、syslog 观察、KPI 生成和异常检测等后处理能力。Python runner 更适合做执行编排，旧 Robot 用例继续保留，新能力走 runner。

### 如何保证状态一致性

通过 run id、Jenkins build number、workflow spec、artifact 路径和 callback payload 建立跨系统追踪关系。验证时同时看 API 返回、数据库记录、Jenkins build、artifact 和 callback 日志。

### AI Explainer 如何接入

KPI 异常判断仍然由 `kpi_detector` 完成，AI Explainer 只读取 detector summary、top anomalies、history context、workflow result JSON 和 artifact metadata，生成 Markdown 解释报告。AI 输出必须基于输入证据，不能直接给出确定 root cause，而是给出可能原因、下一步排查和人工确认项。

## 难点与取舍

- 难点 1：前端、后端、Jenkins 和 runner 的边界容易混淆。
  - 取舍：FastAPI 只负责记录和调度，不直接跑测试；Jenkins 负责执行环境；runner 负责业务编排。
- 难点 2：Robot 旧链路和 Python runner 新链路需要共存。
  - 取舍：Jenkins 公共 bootstrap 层复用 checkout、venv、TAF install/reuse 等前置能力。
- 难点 3：异步执行结果需要稳定回传。
  - 取舍：通过 callback 和 artifact 建立闭环，平台以 run 状态和结果摘要作为统一展示入口。
- 难点 4：AI 解释容易脱离证据或过度推断。
  - 取舍：统计判断由 detector 完成，AI 只做证据解释；通过输入合同、prompt 约束和评测样例控制幻觉。

## 结果与价值

- 将分散的执行流程收口为可追踪的平台链路。
- 降低参数手填和结果遗漏风险。
- 让 Jenkins 日志、artifact、callback 和平台 run detail 能互相印证。
- 形成面向测试开发、平台工程、AI assisted 工程实践和 AI 测试解释能力的代表性项目。

## 面试表达

### 3 分钟版本

这个项目是我最近主导推进的自动化测试平台。背景是 5G 基站 KPI 回归流程比较分散，人工配置、Jenkins 执行、脚本后处理和结果回收没有统一入口。我把系统拆成 React 门户、FastAPI 后端、Jenkins 调度层、Python runner 执行层和 KPI 后处理层。前端提交 workflow，后端创建 run 并触发 Jenkins，Jenkins 在执行机上准备环境并调用 Robot 或 runner，执行后生成 result JSON 和 artifact，再 callback 回写平台。AI 测试方向上，我规划了 KPI AI Explainer，让它站在 `kpi_detector` 后面解释异常和证据，而不是替代统计判断。这个项目体现了我的自动化测试、接口设计、CI/CD、异步任务、结果一致性校验和 AI 辅助测试能力。

### 可追问问题

- 为什么不用 FastAPI 直接执行测试？
- 为什么不是全部继续写 Robot case？
- callback 失败怎么办？
- Jenkins build 和平台 run 如何关联？
- 如果新增 testline 或 KPI detector，怎么扩展？
- 为什么不让 AI 直接判断 KPI 异常？
- 如何防止 AI Explainer 编造 root cause？

## 证据材料

- 工程目录：`C:\TA\jenkins_robotframework`
- 架构文档：`C:\TA\jenkins_robotframework\docs\overview\gnb-kpi-regression-architecture.md`
- 运行时文档：`C:\TA\jenkins_robotframework\docs\overview\gnb-kpi-system-runtime.md`
- Jenkins 集成文档：`C:\TA\jenkins_robotframework\jenkins-integration\kpi_ci_cd_flow.md`
- AI Explainer 文档：`C:\TA\resume\career-knowledge-base\03-ai-testing\5g-kpi-anomaly-explainer.md`