# 技术题库

## 自动化测试

### Robot Framework 的优势和局限是什么？

优势是用例表达清晰、关键字复用方便、适合稳定业务流程和团队协作。局限是复杂动态编排、串并行混合、复杂数据处理和后处理场景不如 Python 灵活。所以在我的项目里，传统稳定用例继续保留 Robot，新 KPI workflow 使用 Python runner。

### 如何设计自动化测试框架？

先看测试对象和团队使用方式，再设计分层：测试数据、公共关键字、业务流程、断言、日志、报告和 CI 集成。好的框架要让用例容易写、失败容易定位、公共能力容易复用、环境变化容易适配。

### 接口测试关注哪些点？

入参校验、状态码、响应结构、业务状态流转、异常路径、幂等性、权限、数据一致性和日志可追踪性。在平台项目里，我会同时看 API 响应、数据库记录、Jenkins build 和 callback payload。

## Jenkins / CI/CD

### Jenkins 在自动化测试平台里的角色是什么？

Jenkins 是调度层和执行桥接层，负责长任务、agent、环境准备、日志、artifact、credential 和 callback。它不是业务门户，用户入口应该由 React 和 FastAPI 承担。

### Pipeline stage 怎么拆？

通常按 checkout、环境准备、参数生成、执行、结果归档、callback 拆分。这样失败时能快速判断问题在哪一层。

## FastAPI / 平台后端

### 为什么 API 后端不直接跑测试？

测试任务耗时长、依赖执行机环境和外部工具。如果放在 Web 进程里会影响服务稳定性，也不利于日志、超时和 artifact 管理。更合理的是后端创建 run 并触发 Jenkins，执行完成后 callback 回来。

### 如何处理异步任务状态？

创建 run 时记录初始状态，触发 Jenkins 后保存 build 信息。Jenkins 执行过程中或结束后 callback 更新状态和结果。前端通过查询接口看到 run 状态、artifact 和摘要。

## AI 测试

### 你准备的 AI 测试 Demo 为什么选择 KPI 异常解释？

因为它和我的 5G gNB 自动化测试经历直接相关。现有平台已经有 `kpi_generator` 和 `kpi_detector`，可以生成 KPI 数据并用 CV、t-test、IQR、relative change 等方法判断异常。AI 层放在 detector 后面，负责把异常 KPI、历史对比、build、testline 和 scenario 等结构化证据解释成测试工程师能执行的排查建议。这样比通用 RAG Demo 更能证明 AI 能力可以服务真实测试流程。

### 为什么不让 AI 直接判断 KPI 是否异常？

KPI 是否异常应该先由确定性的统计逻辑判断，例如阈值、历史基线、CV、p-value、relative change 和 detector 规则。AI 更适合做解释、归纳和报告生成。如果让 AI 直接判断异常，结果不可控，也不容易复现。我的设计是 detector 负责判断，AI explainer 负责基于证据解释，并由人工复核。

### 如何防止 AI 编造 root cause？

第一，输入使用结构化 JSON，只提供 build、testline、scenario、detector summary、top anomalies 和 artifact metadata。第二，prompt 明确要求只能基于输入证据，不能输出确定 root cause。第三，输出必须使用“可能原因”“需要确认”这类表达。第四，用评测集检查 `must_not_claim`，例如不能把“吞吐下降”直接说成“调度算法 bug 已确认”。

### 如何评估 KPI AI Explainer 的输出质量？

我会从证据一致性、不夸大、可执行性、场景相关性和安全合规五个维度评估。每条评测样例记录 expected keywords、must not claim 和 expected next checks。比如吞吐下降案例里，输出应该提到历史基线、traffic、调度或无线质量，但不能直接断言根因是调度算法问题。

### 这个 AI Explainer 怎么接入现有平台？

第一版可以离线读取 `kpi_detector` summary 和 runner result JSON，生成 Markdown 报告。后续可以作为 followup 后处理挂在 `kpi_detector` 后面，也可以在 portal 的 run detail / KPI summary 页面展示 AI explanation 区块。它不改变现有执行链路，只增强结果解释。

### 如何评估 LLM 回答质量？

可以从正确性、相关性、完整性、可追踪性、稳定性和安全性评估。对 KPI AI Explainer，我更关注它是否基于 detector 证据、是否避免过度结论、是否给出可执行排查建议，以及是否有人工复核记录。