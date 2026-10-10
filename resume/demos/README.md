# Resume Demo Projects

这个目录用于放置面向“学校数据平台开发与运维岗”的两个补强 Demo。

目标不是做大型系统，而是做两个能清楚展示能力闭环的小项目：

```text
1. school_ai_knowledge_base
   高校制度与办事流程 AI 知识库
   重点展示：FastAPI、RAG、向量库、AI 应用接口、Nginx HTTPS 部署。

2. school_data_dashboard
   高校数据分析与可视化驾驶舱
   重点展示：PostgreSQL、FastAPI、SQL 聚合、数据质量检查、React 图表、Docker 部署。
```

## 开发与部署方式

代码开发方式：

```text
本地 Windows 写代码
-> git commit
-> git push
-> Debian 13 服务器 git pull
-> Docker Compose / Nginx / systemd 部署
```

服务器部署目录：

```text
/opt/resume-demos/
  school_ai_knowledge_base/
  school_data_dashboard/
```

本地代码目录：

```text
C:\TA\resume\demos\
  school_ai_knowledge_base\
  school_data_dashboard\
```

## 部署原则

- 两个 Demo 和 `jenkins_robotframework` 完全隔离。
- 不放入 `/opt/jenkins_robotframework`。
- 不复用 Jenkins 项目的 Python venv、数据库或服务端口。
- 使用 Docker Compose 管理服务依赖，尤其是 PostgreSQL。
- Nginx 统一提供 HTTPS 入口。
- 数据库只监听本机或 Docker 内网，不直接暴露公网。
- Demo 使用模拟数据，不放真实学校数据。

## 推荐访问路径

最终通过 Nginx 暴露：

```text
https://<server>/demo-ai/
https://<server>/demo-dashboard/
https://<server>/api/demo-ai/
https://<server>/api/demo-dashboard/
```

## 总体实现顺序

```text
Step 0：建立两个 Demo 目录和 README
Step 1：实现 AI 知识库 Demo 后端最小闭环
Step 2：实现 AI 知识库 Demo 向量检索和问答页面
Step 3：实现 AI 知识库 Docker Compose 和 Nginx 部署
Step 4：实现数据 Dashboard 数据库、后端 API 和模拟数据
Step 5：实现数据 Dashboard React 图表页面
Step 6：实现数据 Dashboard Docker Compose 和 Nginx 部署
Step 7：整理截图、README、简历项目描述和面试讲解稿
```
