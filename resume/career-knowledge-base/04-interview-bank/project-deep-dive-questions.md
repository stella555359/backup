# 项目深挖题库

## 自动化测试平台项目

### 1. 你这个平台解决了什么问题？

回答要点：分散流程、参数不一致、结果回收慢、失败定位成本高；通过 React + FastAPI + Jenkins + runner + callback 收口为闭环。

### 2. 为什么要引入 FastAPI？

回答要点：统一 API 入口、参数校验、run 记录、状态查询、Jenkins trigger、callback 回写和结果聚合。

### 3. 为什么保留 Jenkins，而不是后端直接执行？

回答要点：长任务、agent、日志、超时、artifact、credential、执行环境隔离；FastAPI 保持轻量和稳定。

### 4. 为什么新 KPI workflow 不完全用 Robot Framework？

回答要点：Robot 适合稳定串行流程；新 workflow 需要串并行、sidecar、后处理和结构化 timeline，Python runner 更合适。

### 5. callback 失败怎么办？

回答要点：Jenkins artifact 保留结果，日志中记录 callback 状态；平台可以通过 run id 和 build number 追踪；后续可补偿重试或人工回放 callback payload。

### 6. 如何保证跨系统参数一致？

回答要点：固定 run id、build、testline、workflow spec、result JSON path、callback token 等字段，通过 schema、接口测试和日志交叉验证。

### 7. 如何定位一次执行失败？

回答要点：先看平台 run 状态，再看 Jenkins stage，判断失败在 trigger、checkout、venv、TAF、runner、artifact、callback 哪一层。

### 8. 如果要新增一个测试线，怎么扩展？

回答要点：配置 testline、Jenkins job 或 Job DSL、执行机环境、workflow 参数、平台下拉配置和验证用例。

## 5G 系统测试项目

### 1. 你如何设计一个 5G feature 的测试策略？

回答要点：需求分析、场景拆分、环境依赖、关键路径、异常场景、自动化可行性、回归级别。

### 2. 自动化可行性怎么判断？

回答要点：流程稳定性、环境可控性、数据可获取性、断言可验证性、维护成本、复用价值。

### 3. Robot 公共关键字如何设计？

回答要点：围绕稳定动作抽象，避免把业务判断过度隐藏；参数清晰、日志完整、失败信息可定位。

### 4. Jenkins 回归失败后怎么处理？

回答要点：按环境、脚本、数据、产品、基础设施分类；保留日志和证据；Ticket 跟踪；复盘重复失败。