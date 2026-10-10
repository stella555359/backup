# 学校数据平台开发与运维岗匹配分析与 Demo 补强计划

## 1. 岗位理解

目标岗位是“数据平台开发与运维岗”，从岗位职责和应聘要求看，它不是单纯的后端开发岗，也不是单纯的数据库运维岗，而是一个偏综合型的平台工程岗位。

核心能力可以归纳为：

```text
数据平台建设
-> 数据接口设计
-> 数据集成与共享
-> 数据质量与安全运维
-> Web 全栈应用开发
-> AI 知识库 / AI 应用开发
-> 服务器、数据库、操作系统运维
-> 文档、沟通、项目组织实施能力
```

这个岗位更看重“能不能把学校内部多个业务系统、数据源、接口、应用和运维流程组织起来”，而不只是会写某一个功能。

## 2. 使用 jenkins_robotframework 项目应聘是否合适

可以使用 `C:\TA\jenkins_robotframework` 作为应聘该岗位的核心项目经验。

原因是这个项目虽然业务场景是自动化测试和 KPI 测试调度，但技术形态非常接近学校数据平台岗位需要的能力：

```text
前端 Portal
-> 后端 API
-> Jenkins CI/CD 调度
-> Python Runner 执行
-> 多仓库 checkout
-> 环境准备
-> 结构化参数传递
-> 结果 JSON 生成
-> callback 回传平台
-> 部署文档和运维排障流程
```

它可以被包装成一个“跨系统数据调度与运维平台”项目，而不是只描述成“自动化测试项目”。

## 3. 与岗位职责的匹配点

### 3.1 数据中台、AI 知识库运行维护和数据资源管理

当前项目对应能力：

- `platform-api` 提供统一后端入口，负责运行请求、参数校验、调度和状态管理。
- `automation-portal` 提供前端配置入口，让用户通过页面创建 workflow。
- `test-workflow-runner` 负责执行结构化 workflow，并输出结构化结果。
- Jenkins 负责统一调度、执行、归档和回调。

可以强调的能力：

```text
具备平台化系统设计能力，能够把前端、后端、执行引擎、CI/CD、结果回传和运维文档串成闭环。
```

需要补强的点：

```text
AI 知识库相关经验还不够直接。
建议补一个 FastAPI + 向量库 + RAG 的小型学校制度知识库 Demo。
```

### 3.2 信息化数据集成、接口设计、接口标准和统计优化

当前项目对应能力：

- 设计了 `automation-portal -> platform-api -> Jenkins -> test-workflow-runner -> platform-api callback` 的接口链路。
- 通过 `WORKFLOW_SPEC_JSON`、`BUILD`、`TESTLINE`、`RUN_ID` 等字段保证跨系统参数一致。
- 通过 callback payload 回传执行结果和阶段状态。
- 通过 schema 和测试用例约束接口行为。

可以强调的能力：

```text
具备跨系统接口设计、参数标准化、状态回传和接口联调经验。
```

### 3.3 校内外数据报送平台对接与开发，解决数据汇总和对齐问题

当前项目对应能力：

- Jenkins job 接收 API 参数并转换为 runner request。
- runner 生成结果 JSON 和 metadata。
- callback 将结果回传 `platform-api`。
- `BUILD`、`TESTLINE`、`WORKFLOW_NAME` 等字段用于结果归档、检索和追踪。

可类比学校场景：

```text
学校里可能是教务、人事、科研、资产、财务等系统之间的数据汇总和对接。
当前项目里是 Portal、API、Jenkins、Runner、配置仓库之间的数据对齐。
技术路径相似，都是解决跨系统字段标准化、流程可追踪、结果可回传的问题。
```

### 3.4 数据库运行性能监测、故障排查、数据质量监测分析和数据安全运维

当前项目对应能力：

- 已有部署、Jenkins、JCasC、Job DSL、环境变量、agent、venv、callback 的运维文档。
- 已经梳理了常见失败模式，例如 checkout 失败、JCasC reload 失败、Jenkins job path 错误、Python 环境缺失。
- `platform-api` 的运行记录和状态回调可以延伸成运行监控和数据质量追踪。

需要补强的点：

```text
数据库和可视化数据分析经验需要更直接展示。
建议补一个 PostgreSQL/MySQL + FastAPI + React 图表的数据分析展示 Demo。
```

### 3.5 数据分析应用开发

当前项目对应能力：

- 前端 Portal + 后端 API + JSON 数据结构已经体现 Web 应用开发能力。
- KPI Runner 输出结果可以作为数据分析输入。

需要补强的点：

```text
建议单独做一个学生 / 教务 / 资产类模拟数据分析 Demo。
重点展示数据库建模、SQL 查询、API 聚合、React 图表展示和数据质量检查。
```

## 4. 简历中的项目描述建议

项目名称建议不要写得太窄。

推荐名称：

```text
自动化测试数据调度与运维平台
```

或者：

```text
跨系统任务调度与数据回传平台
```

项目描述可以写：

```text
基于 FastAPI、React、Jenkins、Python Runner 构建跨系统任务调度与结果回传平台，实现测试流程配置、接口化触发、Jenkins 任务编排、执行环境准备、结构化结果采集与平台回调，提升任务执行、数据流转和运维过程的标准化与可追踪能力。
```

## 5. 简历职责写法

可以写成：

- 负责设计并实现 `platform-api` 后端接口，支持任务创建、参数校验、Jenkins 调度、运行状态管理和结果回调。
- 负责开发 `automation-portal` 前端页面，实现 workflow 配置、任务提交和执行状态展示。
- 负责设计 `test-workflow-runner` Python 执行框架，支持基于 JSON workflow 的任务编排、KPI 参数传递、结果生成和 dry-run 验证。
- 负责 Jenkins CI/CD 集成，使用 JCasC、Job DSL、seed job 和 Jenkinsfile 实现 Jenkins 任务配置代码化，支持自动生成 `CIT/KPI_Testing/<SBTS>/<testline>` 任务目录。
- 负责复用并改造 Jenkins checkout 和环境准备流程，实现 `robotws`、`testline_configuration`、Python/TAF 环境自动准备。
- 负责制定跨系统参数和结果数据结构，包括 `BUILD`、`TESTLINE`、`WORKFLOW_SPEC_JSON`、result JSON、callback payload，提高数据传递一致性和执行过程可追踪性。
- 负责撰写部署、运维和验证文档，覆盖服务器环境变量、JCasC reload、seed job 执行、任务生成、失败排查等流程。

## 6. 面试表达建议

不要只说“我做了自动化测试平台”。

更推荐这样表达：

```text
这个项目虽然服务于自动化测试场景，但我负责的核心工作是构建一个跨系统数据调度和运维平台。

前端负责提交结构化 workflow，后端负责接口、参数校验和运行状态管理，Jenkins 负责调度和环境准备，Python Runner 负责执行业务逻辑并生成结构化结果，最后通过 callback 回传平台形成闭环。

这和高校数据中台里常见的数据采集、接口对接、任务调度、状态追踪、结果归档和运维排障有相似技术路径。
```

## 7. 当前项目的短板

用这个项目应聘该岗位时，建议主动补强两块：

```text
短板一：AI 知识库 / RAG 应用经验不够直接
补强方式：做一个学校制度知识库问答 Demo

短板二：数据库 + 数据分析可视化经验不够集中展示
补强方式：做一个学校数据分析展示 Demo
```

两个 Demo 不需要做得很大，关键是让简历和面试中能讲清楚：

```text
我有平台工程项目经验
我也能做 AI 知识库应用
我还能做数据库、API 和可视化数据分析
```

## 8. Demo 1：小型 AI 知识库 Demo 计划

### 8.1 Demo 定位

Demo 名称：

```text
高校制度与办事流程 AI 知识库
```

目标：

```text
把学校制度文档、办事指南、常见问答导入知识库，用户通过页面或 API 提问，系统通过 RAG 检索相关文档片段，并生成带引用来源的回答。
```

对应岗位能力：

- AI 应用开发能力。
- 文档知识管理能力。
- FastAPI 后端开发能力。
- 数据资源管理能力。
- 接口设计能力。

### 8.2 推荐技术栈

第一版尽量轻量，不要一开始上复杂平台。

推荐：

```text
后端：FastAPI
向量库：ChromaDB 或 FAISS
Embedding：sentence-transformers 本地模型
LLM：先支持 mock answer，再预留 OpenAI / Ollama 接口
文档格式：Markdown / TXT / PDF
前端：React + Vite
数据目录：本地 docs/knowledge_base
```

如果电脑本地算力有限，第一版可以先做：

```text
只做 embedding + 检索 + 摘要式回答
LLM 生成回答作为第二阶段
```

### 8.3 第一版功能范围

第一版只做最小闭环：

```text
1. 上传或放入学校制度 Markdown/TXT 文档
2. 后端切分文档为 chunks
3. 生成 embedding
4. 写入向量库
5. 提供 /api/chat 接口
6. 用户提问
7. 检索 Top-K 文档片段
8. 返回回答和引用来源
9. 前端展示问答结果
```

暂时不做：

```text
复杂权限
多租户
大规模文档管理
在线编辑文档
复杂 agent 工作流
```

### 8.4 建议目录结构

建议放在：

```text
C:\TA\resume\demos\school_ai_knowledge_base
```

目录结构：

```text
school_ai_knowledge_base/
  backend/
    app/
      main.py
      config.py
      schemas.py
      services/
        document_loader.py
        chunker.py
        vector_store.py
        rag_service.py
    data/
      source_docs/
        student_status.md
        reimbursement_process.md
        scholarship_policy.md
      chroma/
    requirements.txt

  frontend/
    src/
      App.tsx
      api.ts
      components/
        ChatPanel.tsx
        SourceList.tsx
    package.json

  README.md
```

### 8.5 API 设计

后端接口建议：

```text
POST /api/knowledge/rebuild
  作用：重新读取 source_docs，切分并写入向量库

POST /api/chat
  作用：用户提问，返回回答和引用来源

GET /api/documents
  作用：查看当前知识库文档列表

GET /api/health
  作用：健康检查
```

`POST /api/chat` 请求：

```json
{
  "question": "学生请假流程是什么？",
  "top_k": 3
}
```

响应：

```json
{
  "answer": "根据学生管理规定，请假需要先提交申请...",
  "sources": [
    {
      "file_name": "student_status.md",
      "chunk_id": "student_status-003",
      "score": 0.82,
      "content_preview": "学生因病因事不能参加教学活动，应提前..."
    }
  ]
}
```

### 8.6 实现步骤

Step 1：创建后端 FastAPI 项目。

目标：

```text
跑通 /api/health。
```

验证命令：

```bash
cd C:/TA/resume/demos/school_ai_knowledge_base/backend
python -m venv .venv
.venv/Scripts/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8010
```

预期结果：

```text
浏览器访问 http://127.0.0.1:8010/api/health 返回 {"status":"ok"}
```

常见失败：

```text
uvicorn 找不到：依赖未安装或虚拟环境未激活。
端口占用：换成 8011。
```

Step 2：准备学校制度模拟文档。

目标：

```text
准备 3-5 个 Markdown 文档，模拟学生管理、奖学金、报销、办事流程。
```

验证方式：

```text
确认 backend/data/source_docs 下有 md/txt 文件。
```

Step 3：实现文档加载和切分。

目标：

```text
把 Markdown/TXT 读出来，按固定长度切成 chunks。
```

验证方式：

```text
调用 /api/documents 能看到文档和 chunk 数量。
```

Step 4：接入向量库。

目标：

```text
使用 sentence-transformers 生成 embedding，并写入 ChromaDB 或 FAISS。
```

验证方式：

```text
调用 /api/knowledge/rebuild 后，data/chroma 目录生成索引文件。
```

Step 5：实现 RAG 检索接口。

目标：

```text
用户提问后返回 Top-K 相关片段。
```

验证方式：

```text
POST /api/chat，能返回 sources。
```

Step 6：实现回答生成。

目标：

```text
第一版可以先用模板回答，把检索到的片段整理成回答。
第二版再接 Ollama 或 OpenAI-compatible API。
```

验证方式：

```text
回答中包含来源文件名和引用片段。
```

Step 7：实现 React 问答页面。

目标：

```text
一个输入框、一个提问按钮、一个回答区域、一个来源列表。
```

验证命令：

```bash
cd C:/TA/resume/demos/school_ai_knowledge_base/frontend
npm install
npm run dev
```

预期结果：

```text
页面可以输入问题并展示回答和 sources。
```

### 8.7 简历中可写成果

完成后可以写：

- 基于 FastAPI 和向量数据库实现高校制度知识库问答 Demo，支持制度文档导入、文本切分、向量检索、Top-K 引用片段返回和问答结果展示。
- 使用 React 构建问答页面，实现用户提问、回答展示和来源追溯，提升制度查询和办事流程检索效率。
- 设计知识库重建、文档列表、问答接口和健康检查接口，具备 AI 应用接口开发和文档数据管理能力。

## 9. Demo 2：数据分析展示 Demo 计划

### 9.1 Demo 定位

Demo 名称：

```text
高校数据分析与可视化驾驶舱
```

目标：

```text
使用学生、课程、选课、成绩、资产、报修等模拟数据，构建数据库、后端聚合 API 和 React 可视化页面，展示学校数据统计、质量检查和趋势分析能力。
```

对应岗位能力：

- 数据库建模能力。
- SQL 查询和性能意识。
- Web 前后端全栈能力。
- 可视化数据分析能力。
- 数据质量监测分析能力。

### 9.2 推荐技术栈

推荐：

```text
数据库：PostgreSQL
后端：FastAPI + SQLAlchemy
迁移：Alembic
前端：React + Vite + ECharts
数据生成：Python Faker
部署：Docker Compose
```

如果本地不方便装 PostgreSQL，可以第一版先用 SQLite，第二版再切 PostgreSQL。

为了贴近岗位，最终建议至少有一个 PostgreSQL 版本。

### 9.3 第一版功能范围

第一版只做学校通用数据场景：

```text
学生基础信息
院系专业信息
课程信息
选课与成绩
资产设备
报修工单
```

Dashboard 展示：

```text
1. 学生总数、院系数量、课程数量、资产数量
2. 各学院学生人数分布
3. 课程平均成绩趋势
4. 不及格率 Top 课程
5. 资产状态分布
6. 报修工单月度趋势
7. 数据质量问题数量，例如缺失手机号、重复学号、异常成绩
```

### 9.4 建议目录结构

建议放在：

```text
C:\TA\resume\demos\school_data_dashboard
```

目录结构：

```text
school_data_dashboard/
  docker-compose.yml

  backend/
    app/
      main.py
      config.py
      database.py
      models.py
      schemas.py
      routers/
        metrics.py
        quality.py
        students.py
        assets.py
      services/
        metrics_service.py
        quality_service.py
    scripts/
      seed_data.py
    requirements.txt

  frontend/
    src/
      App.tsx
      api.ts
      pages/
        Dashboard.tsx
      components/
        MetricCard.tsx
        ChartPanel.tsx
    package.json

  README.md
```

### 9.5 数据库表设计

建议表：

```text
departments
  id
  name

majors
  id
  department_id
  name

students
  id
  student_no
  name
  gender
  department_id
  major_id
  grade_year
  phone
  status

courses
  id
  course_code
  course_name
  department_id
  credit

enrollments
  id
  student_id
  course_id
  semester
  score

assets
  id
  asset_no
  asset_name
  department_id
  status
  purchase_date

repair_tickets
  id
  asset_id
  department_id
  issue_type
  status
  created_at
  closed_at
```

### 9.6 API 设计

后端接口建议：

```text
GET /api/health

GET /api/metrics/overview
  返回学生、课程、资产、工单等总览指标

GET /api/metrics/students-by-department
  返回各学院学生人数

GET /api/metrics/course-score-trend
  返回课程成绩趋势

GET /api/metrics/failure-rate-top
  返回不及格率较高课程

GET /api/metrics/assets-status
  返回资产状态分布

GET /api/metrics/repair-ticket-trend
  返回报修工单趋势

GET /api/quality/summary
  返回数据质量问题统计
```

### 9.7 数据质量检查设计

第一版数据质量规则：

```text
学生手机号为空
学生学号重复
成绩小于 0 或大于 100
课程没有归属学院
资产编号重复
报修单 closed_at 早于 created_at
```

这些规则非常适合面试时讲：

```text
学校数据平台不仅要展示数据，还要发现数据质量问题。
我在 Demo 中设计了基础质量规则，并通过 API 和页面展示问题数量。
```

### 9.8 实现步骤

Step 1：创建 Docker Compose 和数据库。

目标：

```text
启动 PostgreSQL。
```

验证命令：

```bash
cd C:/TA/resume/demos/school_data_dashboard
docker compose up -d postgres
docker compose ps
```

预期结果：

```text
postgres 容器状态为 running。
```

常见失败：

```text
Docker 未启动。
5432 端口被占用。
```

Step 2：创建 FastAPI 后端和数据库连接。

目标：

```text
跑通 /api/health，并能连接 PostgreSQL。
```

验证命令：

```bash
cd C:/TA/resume/demos/school_data_dashboard/backend
python -m venv .venv
.venv/Scripts/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8020
```

预期结果：

```text
http://127.0.0.1:8020/api/health 返回 status ok。
```

Step 3：实现 SQLAlchemy models。

目标：

```text
创建 departments、students、courses、enrollments、assets、repair_tickets 等表。
```

验证方式：

```text
后端启动时自动 create_all，或使用 Alembic migration。
数据库里能看到表。
```

Step 4：生成模拟数据。

目标：

```text
用 Faker 生成学生、课程、成绩、资产和报修工单模拟数据。
```

验证命令：

```bash
python scripts/seed_data.py
```

预期结果：

```text
数据库中插入模拟数据。
```

Step 5：实现指标 API。

目标：

```text
实现 overview、学生分布、成绩趋势、资产状态、报修趋势等 API。
```

验证方式：

```text
浏览器或 Swagger 调用 /docs 中的接口，能看到聚合数据。
```

Step 6：实现数据质量 API。

目标：

```text
统计缺失、重复、异常范围等数据质量问题。
```

验证方式：

```text
GET /api/quality/summary 返回各类质量问题数量。
```

Step 7：实现 React Dashboard。

目标：

```text
展示指标卡片、柱状图、折线图、饼图和数据质量摘要。
```

验证命令：

```bash
cd C:/TA/resume/demos/school_data_dashboard/frontend
npm install
npm run dev
```

预期结果：

```text
页面能展示学校数据概览和图表。
```

### 9.9 简历中可写成果

完成后可以写：

- 基于 PostgreSQL、FastAPI、SQLAlchemy 和 React/ECharts 构建高校数据分析展示 Demo，实现学生、课程、成绩、资产和报修数据的建模、模拟数据生成、聚合查询和可视化展示。
- 设计数据质量检查规则，支持缺失字段、重复编号、异常成绩、异常时间等问题统计，体现数据治理和数据质量监测能力。
- 提供指标总览、学生分布、成绩趋势、资产状态、报修趋势等 API，展示全栈开发和数据分析应用开发能力。

## 10. 两个 Demo 的 Debian 13 服务器部署方案

因为本地电脑性能不够，两个 Demo 推荐放到 `jenkins_robotframework` 项目使用的 Debian 13 服务器上部署。

结论：

```text
可以使用同一台 Debian 13 服务器。
但不要和 Jenkins 混在同一个目录、端口和进程里。
建议用独立目录、独立 Linux 用户、独立端口、独立 systemd service 或 Docker Compose 管理。
```

### 10.1 推荐服务器目录

建议服务器上统一放在：

```text
/opt/resume-demos
```

目录结构：

```text
/opt/resume-demos/
  school_ai_knowledge_base/
    backend/
    frontend/
    data/
      source_docs/
      chroma/
    logs/

  school_data_dashboard/
    backend/
    frontend/
    data/
    logs/
    docker-compose.yml
```

不要放到：

```text
/opt/jenkins_robotframework
```

原因：

```text
/opt/jenkins_robotframework 是主项目目录。
Demo 是简历补强项目，应该独立部署，避免误影响 Jenkins、platform-api、JCasC 或现有 CI/CD。
```

### 10.2 推荐 Linux 用户

建议新建一个普通用户运行 Demo：

```bash
sudo useradd -r -m -d /opt/resume-demos -s /usr/sbin/nologin resume-demos
sudo mkdir -p /opt/resume-demos
sudo chown -R resume-demos:resume-demos /opt/resume-demos
```

预期结果：

```text
/opt/resume-demos 归 resume-demos 用户管理。
Demo 进程不使用 root 运行。
Demo 和 Jenkins 运行用户隔离。
```

常见失败：

```text
Permission denied
  -> 检查目录 owner 是否是 resume-demos。

useradd 失败
  -> 用户可能已存在，使用 id resume-demos 检查。
```

### 10.3 推荐端口规划

建议端口：

```text
AI 知识库后端 FastAPI：8010
AI 知识库前端静态页面：Nginx /demo-ai/

数据 Dashboard 后端 FastAPI：8020
数据 Dashboard 前端静态页面：Nginx /demo-dashboard/

PostgreSQL：127.0.0.1:5433
```

为什么 PostgreSQL 推荐用 `5433`：

```text
避免和服务器上已有 PostgreSQL 5432 冲突。
如果服务器没有 PostgreSQL，也可以继续用 5432。
```

如果已有 Nginx 服务，可以用路径区分：

```text
https://<server>/demo-ai/
https://<server>/demo-dashboard/
https://<server>/api/demo-ai/
https://<server>/api/demo-dashboard/
```

第一版也可以先不配 Nginx，直接用端口访问：

```text
http://<server-ip>:8010/docs
http://<server-ip>:8020/docs
```

### 10.4 AI 知识库 Demo 的服务器部署方式

推荐第一版使用：

```text
FastAPI + ChromaDB/FAISS + sentence-transformers CPU embedding
```

原因：

```text
不依赖 GPU。
不用一开始部署大模型。
服务器 CPU 就能跑小规模制度文档检索。
```

模型建议：

```text
sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2
```

如果服务器无法访问外网，可以提前下载模型，或先用 mock embedding / 关键词检索完成第一版闭环。

部署步骤：

```bash
sudo mkdir -p /opt/resume-demos/school_ai_knowledge_base
sudo chown -R resume-demos:resume-demos /opt/resume-demos/school_ai_knowledge_base

cd /opt/resume-demos/school_ai_knowledge_base/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8010
```

预期结果：

```text
http://<server-ip>:8010/api/health 返回 {"status":"ok"}
http://<server-ip>:8010/docs 可以打开 Swagger 页面
```

后续用 systemd 管理：

```text
/etc/systemd/system/school-ai-kb.service
```

服务职责：

```text
启动 FastAPI 后端。
自动重启。
日志进入 journalctl。
```

建议 systemd 内容：

```ini
[Unit]
Description=School AI Knowledge Base Demo
After=network.target

[Service]
User=resume-demos
WorkingDirectory=/opt/resume-demos/school_ai_knowledge_base/backend
Environment=PYTHONUNBUFFERED=1
ExecStart=/opt/resume-demos/school_ai_knowledge_base/backend/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8010
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

启动命令：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now school-ai-kb
sudo systemctl status school-ai-kb
```

检查日志：

```bash
journalctl -u school-ai-kb -n 100 --no-pager
```

### 10.5 数据分析 Dashboard Demo 的服务器部署方式

推荐第一版用 Docker Compose 管 PostgreSQL，后端仍用 systemd 或 Docker 都可以。

为了展示运维能力，推荐：

```text
PostgreSQL：Docker Compose
FastAPI backend：systemd
React frontend：build 后由 Nginx 托管
```

PostgreSQL compose 示例：

```yaml
services:
  postgres:
    image: postgres:16
    container_name: school-data-dashboard-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: school_dashboard
      POSTGRES_USER: school_user
      POSTGRES_PASSWORD: change_me
    ports:
      - "127.0.0.1:5433:5432"
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
```

启动命令：

```bash
cd /opt/resume-demos/school_data_dashboard
docker compose up -d postgres
docker compose ps
```

后端环境变量：

```text
DATABASE_URL=postgresql+psycopg://school_user:change_me@127.0.0.1:5433/school_dashboard
```

后端启动：

```bash
cd /opt/resume-demos/school_data_dashboard/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8020
```

预期结果：

```text
http://<server-ip>:8020/api/health 返回 {"status":"ok"}
http://<server-ip>:8020/docs 可以打开 Swagger 页面
```

systemd service 建议：

```ini
[Unit]
Description=School Data Dashboard Demo API
After=network.target docker.service

[Service]
User=resume-demos
WorkingDirectory=/opt/resume-demos/school_data_dashboard/backend
Environment=PYTHONUNBUFFERED=1
Environment=DATABASE_URL=postgresql+psycopg://school_user:change_me@127.0.0.1:5433/school_dashboard
ExecStart=/opt/resume-demos/school_data_dashboard/backend/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8020
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 10.6 Nginx 推荐配置

如果服务器已经有 Nginx，可以给两个 Demo 加路径转发。

示例：

```nginx
location /api/demo-ai/ {
    proxy_pass http://127.0.0.1:8010/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

location /api/demo-dashboard/ {
    proxy_pass http://127.0.0.1:8020/api/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

location /demo-ai/ {
    alias /opt/resume-demos/school_ai_knowledge_base/frontend/dist/;
    try_files $uri $uri/ /demo-ai/index.html;
}

location /demo-dashboard/ {
    alias /opt/resume-demos/school_data_dashboard/frontend/dist/;
    try_files $uri $uri/ /demo-dashboard/index.html;
}
```

注意：

```text
如果当前 Nginx 已经服务 Jenkins 的 /jenkins 路径，不要覆盖原有 server block。
只新增 location。
改 Nginx 前先备份配置。
```

检查命令：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

预期结果：

```text
nginx -t 显示 syntax is ok 和 test is successful。
reload 后 Jenkins 原有 /jenkins 仍可访问。
```

### 10.7 服务器资源建议

最低建议：

```text
CPU：2 cores
内存：4 GB
磁盘：20 GB 可用空间
```

更推荐：

```text
CPU：4 cores
内存：8 GB
磁盘：40 GB 可用空间
```

原因：

```text
AI 知识库 embedding 模型会占用内存。
PostgreSQL 和前端构建也会占用资源。
如果同机已有 Jenkins，要避免 Demo 抢占过多资源。
```

检查命令：

```bash
free -h
df -h
nproc
systemctl status jenkins
```

预期结果：

```text
内存和磁盘空间充足。
Jenkins 当前服务正常。
```

### 10.8 安全边界建议

这两个 Demo 用于简历展示，不建议直接暴露到公网。

建议：

```text
只在内网访问。
如果需要外部访问，用 VPN、跳板机或临时安全访问方式。
不要把真实学校数据放入 Demo。
不要把真实 token、密码、私钥提交到 Git。
PostgreSQL 只监听 127.0.0.1。
Nginx 只反代必要路径。
```

简历中可以这样表达：

```text
Demo 使用模拟数据部署在 Debian 13 服务器，后端服务通过 systemd 托管，数据库使用 Docker Compose 管理，Nginx 统一反向代理，服务间通过本机端口隔离，避免直接暴露数据库。
```

### 10.9 服务器部署后的验证清单

AI 知识库 Demo：

```bash
curl http://127.0.0.1:8010/api/health
curl http://127.0.0.1:8010/api/documents
journalctl -u school-ai-kb -n 50 --no-pager
```

预期结果：

```text
health 返回 ok。
documents 能看到模拟制度文档。
日志无启动异常。
```

数据 Dashboard Demo：

```bash
curl http://127.0.0.1:8020/api/health
curl http://127.0.0.1:8020/api/metrics/overview
curl http://127.0.0.1:8020/api/quality/summary
docker compose -f /opt/resume-demos/school_data_dashboard/docker-compose.yml ps
journalctl -u school-data-dashboard -n 50 --no-pager
```

预期结果：

```text
health 返回 ok。
overview 返回学生、课程、资产、工单等统计值。
quality 返回数据质量问题数量。
postgres 容器 running。
后端日志无数据库连接错误。
```

Nginx 验证：

```bash
curl -I http://127.0.0.1/demo-ai/
curl -I http://127.0.0.1/demo-dashboard/
curl http://127.0.0.1/api/demo-ai/health
curl http://127.0.0.1/api/demo-dashboard/health
```

预期结果：

```text
前端返回 200 或 304。
后端 health 返回 ok。
Jenkins 原有 /jenkins 路径不受影响。
```

## 11. 两个 Demo 的推荐实现顺序

建议顺序：

```text
第一阶段：AI 知识库 Demo
原因：直接补岗位里“AI知识库”和“人工智能应用开发能力”的关键词。

第二阶段：数据分析 Dashboard Demo
原因：补“数据库、数据分析、可视化、数据质量监测”的关键词。

第三阶段：把两个 Demo 和 jenkins_robotframework 项目整合进简历
原因：形成一个完整能力组合。
```

推荐时间安排：

```text
Day 1：AI 知识库后端最小闭环
Day 2：AI 知识库前端页面和 README
Day 3：数据 Dashboard 数据库和后端 API
Day 4：数据 Dashboard 前端图表和 README
Day 5：整理简历项目描述和面试讲解稿
```

服务器部署顺序建议：

```text
Day 1：在 Debian 13 上准备 /opt/resume-demos、Python、Node.js、Docker、Nginx
Day 2：部署 AI 知识库后端和 source_docs，跑通 /api/health、/api/documents
Day 3：接入向量库，跑通 /api/chat
Day 4：部署 Dashboard PostgreSQL 和后端 API
Day 5：部署两个 React 前端到 Nginx，并整理简历描述和截图
```

## 12. 最终简历组合方式

简历中可以形成三个项目层次。

第一层：核心工程项目。

```text
自动化测试数据调度与运维平台
突出平台工程、接口集成、CI/CD、Jenkins、运维部署、跨系统数据回传。
```

第二层：AI 应用补强项目。

```text
高校制度与办事流程 AI 知识库
突出 FastAPI、RAG、向量检索、知识库、AI 应用开发。
```

第三层：数据分析补强项目。

```text
高校数据分析与可视化驾驶舱
突出 PostgreSQL、数据建模、SQL 聚合、数据质量检查、React 图表。
```

这样组合后，对岗位要求的覆盖会更完整：

```text
Web 全栈开发：jenkins_robotframework + 两个 Demo
数据平台与接口：jenkins_robotframework
AI 知识库：AI 知识库 Demo
数据库与数据分析：Dashboard Demo
服务器与运维：Jenkins/JCasC/Job DSL/部署文档
数据安全意识：接口规范、credential、环境变量、权限边界、callback
文档和沟通：已有大量方案文档和运维手册
```

## 13. 下一步实现建议

建议先从 Demo 1 开始，原因是岗位职责第一条就提到 AI 知识库。

下一步可以执行：

```text
Step 1：在 C:\TA\resume\demos\school_ai_knowledge_base 创建 FastAPI 后端骨架
Step 2：准备 3 个学校制度 Markdown 模拟文档
Step 3：实现 /api/health、/api/documents
Step 4：实现文档 chunk 切分
Step 5：接入向量库和 /api/chat
Step 6：同步到 Debian 13 的 /opt/resume-demos/school_ai_knowledge_base 部署
```

完成 Demo 1 后，再进入 Demo 2。

每个小步骤完成后，都需要记录：

```text
解决了什么问题
改了哪些文件
接口调用流
关键字段
验证命令
预期结果
常见失败模式
```

这样最后不仅能展示 Demo，还能展示你有项目文档、运维交付和问题排查能力。

## 14. 报名应聘用项目经验描述

这一节用于后天报名提交时快速整理项目经验。

建议写法：

```text
主项目写为已完成或持续建设项目。
两个 Demo 如果报名时尚未全部完成，可以写为“个人补充项目 / 原型项目 / 建设中项目”，不要夸大成已上线生产系统。
```

如果报名系统只能填 1-2 个项目，优先顺序是：

```text
1. 自动化测试数据调度与运维平台
2. 高校制度与办事流程 AI 知识库
3. 高校数据分析与可视化驾驶舱
```

其中第 1 个项目展示平台工程和运维能力，第 2、3 个项目补齐学校岗位里的 AI 知识库、数据库和数据分析能力。

## 15. 项目经验一：自动化测试数据调度与运维平台

项目名称：

```text
自动化测试数据调度与运维平台
```

项目状态：

```text
已完成核心链路，持续迭代优化
```

技术栈：

```text
FastAPI、React、Python、Jenkins、JCasC、Job DSL、Jenkins Pipeline、Docker/Nginx、REST API、JSON Schema、Linux
```

项目背景：

```text
面向自动化测试和 KPI 测试场景，建设一套跨系统任务调度与结果回传平台。
平台通过前端 Portal 配置测试 workflow，通过后端 API 统一管理运行请求和调度参数，通过 Jenkins 执行任务编排、环境准备和结果归档，通过 Python Runner 执行业务逻辑并生成结构化结果，最终回调平台形成运行闭环。
```

简历项目描述：

```text
基于 FastAPI、React、Jenkins 和 Python Runner 构建跨系统任务调度与结果回传平台，实现测试流程配置、接口化触发、Jenkins 任务编排、执行环境准备、结构化结果采集与平台回调，提升任务执行、数据流转和运维过程的标准化、自动化和可追踪能力。
```

个人职责：

- 负责设计 `platform-api` 后端接口，支持任务创建、参数校验、Jenkins 调度、运行状态管理和结果回调。
- 负责设计 `automation-portal` 前端 workflow 配置入口，实现测试流程配置、任务提交和执行状态查看。
- 负责设计 `test-workflow-runner` Python 执行框架，支持基于 JSON workflow 的任务编排、KPI 参数传递、dry-run 验证和结构化结果生成。
- 负责 Jenkins CI/CD 集成，使用 JCasC、Job DSL、seed job 和 Jenkinsfile 实现 Jenkins Job 配置代码化。
- 负责设计 KPI Runner Jenkins Job 目录结构，支持 `CIT/KPI_Testing/<SBTS>/<testline>` 和 `CRT/KPI_Testing/<SBTS>/<testline>` 的任务组织方式。
- 负责复用 Jenkins checkout 和环境准备流程，实现 `robotws`、`testline_configuration`、Python/TAF 环境自动准备。
- 负责制定跨系统参数标准，包括 `BUILD`、`TESTLINE`、`WORKFLOW_SPEC_JSON`、`RUN_ID`、result JSON 和 callback payload，保证多系统之间字段一致和结果可追踪。
- 负责编写部署、运维和排障文档，覆盖服务器环境变量、JCasC reload、seed job 执行、Job 自动生成、Jenkins build 验证和常见失败模式。

项目亮点：

- 使用 JCasC 管理 Jenkins 基础配置，减少 Jenkins 页面手工配置。
- 使用 Job DSL 和 seed job 自动生成 Jenkins folders 和 pipeline jobs，支持后续新增 SBTS/testline 时通过代码维护。
- 将测试执行链路从前端、后端、Jenkins、Python Runner 到 callback 打通，形成端到端闭环。
- 通过结构化 JSON 参数和结果文件提升跨系统数据传递的一致性。
- 通过详细运维文档和验证步骤提升部署、排障和交接效率。

与学校数据平台岗位的关联：

```text
该项目虽然业务场景是自动化测试，但核心能力是数据平台岗位需要的“平台化开发、跨系统接口集成、任务调度、运行状态管理、结果数据回传、服务器部署和运维排障”。
学校数据中台也需要对接多个系统、统一接口标准、管理数据流转过程、监测运行状态并形成可追踪闭环，因此该项目具有较强迁移价值。
```

报名系统短版描述：

```text
负责建设自动化测试数据调度与运维平台，基于 FastAPI、React、Jenkins、Python Runner 打通前端配置、后端 API、Jenkins 调度、执行环境准备、结构化结果生成和平台回调链路。使用 JCasC、Job DSL、seed job 和 Jenkinsfile 实现 Jenkins 配置代码化和任务自动生成，设计 BUILD、TESTLINE、WORKFLOW_SPEC_JSON、result JSON、callback payload 等跨系统参数标准，提升任务执行和数据流转的自动化、标准化和可追踪能力。
```

面试展开讲法：

```text
这个项目可以类比学校数据中台里的跨系统数据流转。
前端相当于用户入口，后端相当于统一接口层，Jenkins 相当于调度和执行平台，Python Runner 相当于业务处理引擎，callback 相当于结果归档和状态回传。
我重点做的是接口标准化、任务调度、执行环境准备、结果数据结构设计和部署运维文档。
```

## 16. 项目经验二：高校制度与办事流程 AI 知识库

项目名称：

```text
高校制度与办事流程 AI 知识库
```

项目状态：

```text
个人补充项目，计划 4-6 天内完成可演示版本
```

技术栈：

```text
FastAPI、React、ChromaDB、sentence-transformers、RAG、Docker Compose、Nginx HTTPS、Debian 13
```

项目背景：

```text
面向高校制度查询、办事流程咨询和常见问题检索场景，建设一个轻量级 AI 知识库 Demo。
系统将学校制度文档、学生办事流程、奖学金申请流程、报销流程等 Markdown/TXT 文档导入知识库，通过文本切分、向量化和 Top-K 检索实现问答，并返回引用来源，帮助用户快速定位制度依据。
```

简历项目描述：

```text
基于 FastAPI、ChromaDB、sentence-transformers 和 React 构建高校制度与办事流程 AI 知识库 Demo，支持制度文档导入、文本切分、向量检索、Top-K 来源引用、问答接口和前端问答页面，并通过 Docker Compose 和 Nginx HTTPS 部署到 Debian 13 服务器。
```

个人职责：

- 负责设计知识库后端接口，包括健康检查、文档列表、知识库重建和问答接口。
- 负责实现学校制度文档加载、文本切分、chunk metadata 管理和来源引用返回。
- 负责接入 ChromaDB 和 embedding 模型，实现本地向量检索。
- 负责设计 RAG 问答流程，根据用户问题检索相关制度片段并生成带来源的回答。
- 负责开发 React 问答页面，支持问题输入、回答展示和引用来源展示。
- 负责使用 Docker Compose 容器化部署后端和前端，并通过 Nginx 提供 HTTPS 访问入口。

项目亮点：

- 贴合岗位中“AI 知识库运行维护”和“人工智能应用开发能力”的要求。
- 使用 RAG 方案解决制度文档查询问题，回答结果可追溯到具体来源文档。
- 使用 Docker Compose 和 Nginx 部署，体现服务器运维和服务隔离能力。
- 使用模拟学校制度文档，不涉及真实敏感数据，符合数据安全意识。

计划实现步骤：

```text
Day 1：FastAPI 后端骨架，完成 /api/health、/api/documents。
Day 2：完成文档加载、chunk 切分和模拟制度文档。
Day 3：接入 ChromaDB 和 embedding，完成 /api/knowledge/rebuild、/api/chat。
Day 4：完成 React 问答页面和来源展示。
Day 5：完成 Docker Compose、Nginx HTTPS 部署和 README。
```

报名系统短版描述：

```text
规划并实现高校制度与办事流程 AI 知识库 Demo，基于 FastAPI、ChromaDB、sentence-transformers 和 React 构建 RAG 问答流程，支持制度文档导入、文本切分、向量检索、问答接口、来源引用和前端展示，并使用 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器，展示 AI 知识库应用开发与运维能力。
```

如果报名时尚未完成，建议写成：

```text
正在建设高校制度与办事流程 AI 知识库 Demo，目标是基于 FastAPI、ChromaDB、sentence-transformers 和 React 实现制度文档导入、向量检索、RAG 问答和来源追溯，并计划通过 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器。
```

## 17. 项目经验三：高校数据分析与可视化驾驶舱

项目名称：

```text
高校数据分析与可视化驾驶舱
```

项目状态：

```text
个人补充项目，计划 4-6 天内完成可演示版本
```

技术栈：

```text
PostgreSQL、FastAPI、SQLAlchemy、React、ECharts、Python Faker、Docker Compose、Nginx HTTPS、Debian 13
```

项目背景：

```text
面向高校数据统计、数据质量监测和可视化分析场景，建设一个轻量级数据分析 Dashboard Demo。
系统使用学生、院系、专业、课程、成绩、资产和报修工单等模拟数据，构建 PostgreSQL 数据模型，通过 FastAPI 提供聚合指标和数据质量接口，通过 React + ECharts 展示学校数据概览、趋势分析和异常数据统计。
```

简历项目描述：

```text
基于 PostgreSQL、FastAPI、SQLAlchemy、React 和 ECharts 构建高校数据分析与可视化驾驶舱 Demo，实现学生、课程、成绩、资产和报修数据建模、模拟数据生成、聚合指标 API、数据质量检查和图表展示，并通过 Docker Compose 和 Nginx HTTPS 部署到 Debian 13 服务器。
```

个人职责：

- 负责设计 PostgreSQL 数据模型，包括院系、专业、学生、课程、选课成绩、资产和报修工单等表。
- 负责使用 Python Faker 生成学校业务模拟数据，构造正常数据和部分异常数据。
- 负责实现 FastAPI 后端接口，提供总览指标、学生分布、成绩趋势、资产状态、报修趋势等聚合 API。
- 负责设计数据质量检查规则，包括手机号缺失、重复学号、异常成绩、重复资产编号、异常报修时间等。
- 负责开发 React + ECharts 可视化页面，展示指标卡、柱状图、折线图、饼图和数据质量摘要。
- 负责使用 Docker Compose 部署 PostgreSQL、后端 API 和前端服务，并通过 Nginx 提供 HTTPS 统一访问入口。

项目亮点：

- 贴合岗位中“数据库运维、数据质量监测分析、数据分析应用开发”的要求。
- 从数据库建模、模拟数据生成、SQL 聚合查询、API 设计到前端图表展示形成完整链路。
- 数据质量检查规则能体现数据治理意识，不只是简单做可视化页面。
- 使用 PostgreSQL 和 Docker Compose 展示数据库服务隔离、数据持久化和部署运维能力。

计划实现步骤：

```text
Day 1：完成 Docker Compose PostgreSQL 和 FastAPI 后端骨架。
Day 2：完成 SQLAlchemy models 和数据库建表。
Day 3：完成 Faker 模拟数据生成和 seed 脚本。
Day 4：完成 metrics API 和 quality API。
Day 5：完成 React + ECharts Dashboard 页面。
Day 6：完成 Docker Compose、Nginx HTTPS 部署、README 和截图。
```

报名系统短版描述：

```text
规划并实现高校数据分析与可视化驾驶舱 Demo，基于 PostgreSQL、FastAPI、SQLAlchemy、React 和 ECharts 构建学生、课程、成绩、资产和报修数据分析应用，支持模拟数据生成、聚合指标 API、数据质量检查和图表展示，并使用 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器，展示数据库建模、数据分析和全栈开发能力。
```

如果报名时尚未完成，建议写成：

```text
正在建设高校数据分析与可视化驾驶舱 Demo，目标是基于 PostgreSQL、FastAPI、SQLAlchemy、React 和 ECharts 实现学校模拟数据建模、指标聚合、数据质量检查和可视化展示，并计划通过 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器。
```

## 18. 报名表项目经历组合建议

如果报名表可以写三个项目，建议按以下顺序：

```text
1. 自动化测试数据调度与运维平台
2. 高校制度与办事流程 AI 知识库
3. 高校数据分析与可视化驾驶舱
```

如果报名表只能写两个项目：

```text
1. 自动化测试数据调度与运维平台
2. 高校制度与办事流程 AI 知识库
```

原因：

```text
岗位职责第一条明确提到 AI 知识库，所以 AI Demo 的优先级高于 Dashboard Demo。
Dashboard Demo 可以放在“其他项目 / 个人项目 / 技能补充”里，或者面试时补充说明。
```

如果报名表只能写一个项目：

```text
自动化测试数据调度与运维平台
```

但在项目描述末尾补一句：

```text
同时正在补充高校制度 AI 知识库和高校数据分析驾驶舱 Demo，以强化 AI 应用、数据库建模和数据分析可视化能力。
```

## 19. 针对岗位要求的关键词覆盖

报名材料中建议自然覆盖这些关键词：

```text
数据中台
数据接口
接口标准
数据共享
数据汇总
数据质量
数据库
运行维护
故障排查
AI 知识库
人工智能应用
Web 前后端
可视化分析
服务器部署
Linux
Nginx HTTPS
Docker Compose
PostgreSQL
FastAPI
React
Jenkins
自动化运维
文档编写
跨部门沟通
```

不要堆砌关键词，而是用项目描述带出来：

```text
通过接口标准化解决数据传递问题。
通过 Docker Compose 和 Nginx 实现隔离部署与 HTTPS 访问。
通过数据质量规则发现缺失、重复、异常范围等问题。
通过 RAG 知识库提升制度文档查询效率。
通过 Jenkins/JCasC/Job DSL 提升任务运维自动化水平。
```

## 20. 两天内报名材料准备优先级

后天要提交报名，建议优先做这几件事：

```text
第一优先级：把主项目描述写进简历
第二优先级：把两个 Demo 写成“个人补充项目 / 建设中项目”
第三优先级：补充项目 README 和目录结构，证明已经开始落地
第四优先级：如果时间够，完成 AI 知识库 /api/health 和 source_docs
第五优先级：准备 1 分钟项目讲解稿
```

1 分钟讲解稿：

```text
我目前最核心的项目是一个跨系统任务调度与数据回传平台，使用 FastAPI、React、Jenkins 和 Python Runner 打通前端配置、后端接口、Jenkins 调度、执行环境准备、结构化结果生成和 callback 回传。这个项目锻炼了我在平台开发、接口标准化、服务器部署、CI/CD、运行排障和文档交付方面的能力。

针对学校数据平台岗位，我还补充规划了两个个人 Demo：一个是高校制度与办事流程 AI 知识库，用 FastAPI、向量库和 RAG 做制度问答；另一个是高校数据分析与可视化驾驶舱，用 PostgreSQL、FastAPI 和 React/ECharts 做学校模拟数据分析和数据质量检查。这三个项目组合起来，可以覆盖岗位需要的数据平台、AI 知识库、数据库、Web 全栈和运维部署能力。
```
