# 测试平台与工程化技能地图

## 核心能力结构

```text
用户入口
-> API 层
-> 调度层
-> 执行层
-> 结果层
-> 部署和运维
-> 质量验证
```

## FastAPI

掌握重点：

- API 路由和请求响应模型。
- run 创建、查询、状态更新。
- callback 接口设计。
- 参数校验和错误处理。
- 与数据库 Repository 层协作。

面试表达：FastAPI 在我的项目里不是单独做 CRUD，而是作为自动化平台的统一入口，负责接收前端请求、创建 run、触发 Jenkins、接收 callback，并对前端提供状态和结果查询。

## React / Portal

掌握重点：

- 用户配置 workflow。
- 展示 run 状态和结果摘要。
- 通过 API 与后端交互。
- 将 Jenkins 的技术细节隐藏在平台后面。

面试表达：门户层的价值是把普通测试用户看到的概念从 Jenkins Job 变成 testline、build、scenario、result 和 KPI summary。

## Jenkins / JCasC / Job DSL / Pipeline

掌握重点：

- Jenkins 作为长任务调度器。
- JCasC 管理 Jenkins 配置。
- Job DSL 生成目录和 Pipeline Job。
- Jenkinsfile 定义执行阶段。
- Credentials、agent、artifact 和日志。

面试表达：我把 Jenkins 从手工 Job 使用方式，整理成可代码化、可批量生成、可追踪的调度层。

## 部署与运维

掌握重点：

- Linux / Debian 基础操作。
- Nginx HTTPS 和反向代理。
- systemd 服务管理。
- Python venv、Node 构建、环境变量。
- 日志查看和服务状态排查。

## 差距清单

| 能力 | 当前状态 | 补强动作 |
|---|---|---|
| PostgreSQL / SQLAlchemy | 当前主项目偏 SQLite | 通过 school_data_dashboard 补直接证据 |
| Docker Compose | Demo 计划中已有 | 完成 AI KB 或 Dashboard 最小部署 |
| 前端复杂交互 | React 作为门户入口 | 面试中定位为能做基础平台页面，不夸大前端专家 |
| 监控告警 | 目前偏日志和状态排查 | 准备 Prometheus/Grafana 基础概念或说明后续规划 |