# 高校数据分析与可视化驾驶舱

## 项目定位

这个 Demo 用于补强“数据库、数据中台、数据质量监测、数据分析应用开发、Web 全栈开发”能力。

目标是做一个小型学校数据 Dashboard：

```text
学生 / 院系 / 课程 / 成绩 / 资产 / 报修模拟数据
-> PostgreSQL 数据建模
-> FastAPI 聚合查询
-> 数据质量检查
-> React + ECharts 可视化展示
-> Docker Compose + Nginx HTTPS 部署
```

## 技术栈

推荐：

```text
数据库：PostgreSQL
后端：FastAPI + SQLAlchemy
数据生成：Python Faker
前端：React + Vite + ECharts
部署：Docker Compose
入口：Nginx HTTPS
```

## 目标目录结构

```text
school_data_dashboard/
  backend/
    app/
      main.py
      config.py
      database.py
      models.py
      schemas.py
      routers/
        health.py
        metrics.py
        quality.py
      services/
        metrics_service.py
        quality_service.py
    scripts/
      seed_data.py
    requirements.txt
    Dockerfile

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
    Dockerfile

  docker-compose.yml
  nginx/
    demo-dashboard.conf
  docs/
    deployment.md
    learning-record.md
```

## 数据模型 Overview

第一版建议表：

```text
departments
  学院 / 部门。

majors
  专业。

students
  学生基础信息。

courses
  课程信息。

enrollments
  选课和成绩。

assets
  资产设备。

repair_tickets
  报修工单。
```

## API Overview

```text
GET /api/health
  健康检查。

GET /api/metrics/overview
  返回学生、课程、资产、工单等总览指标。

GET /api/metrics/students-by-department
  返回各学院学生人数。

GET /api/metrics/course-score-trend
  返回课程成绩趋势。

GET /api/metrics/failure-rate-top
  返回不及格率较高课程。

GET /api/metrics/assets-status
  返回资产状态分布。

GET /api/metrics/repair-ticket-trend
  返回报修工单趋势。

GET /api/quality/summary
  返回数据质量问题统计。
```

## 数据质量规则

第一版质量规则：

```text
学生手机号为空
学生学号重复
成绩小于 0 或大于 100
课程没有归属学院
资产编号重复
报修单 closed_at 早于 created_at
```

这些规则用于展示：

```text
学校数据平台不仅要展示数据，还要监测数据质量问题。
```

## Docker 部署目标

本地写代码，服务器通过 Git 同步后部署到：

```text
/opt/resume-demos/school_data_dashboard
```

Docker Compose 目标服务：

```text
school-dashboard-postgres
  PostgreSQL 数据库。

school-dashboard-api
  FastAPI 后端。

school-dashboard-frontend
  React build 产物或前端静态服务。
```

推荐端口：

```text
PostgreSQL：127.0.0.1:5433
FastAPI API：127.0.0.1:8020
Nginx HTTPS：
  /demo-dashboard/
  /api/demo-dashboard/
```

## Overview 实现步骤

### Step 1：创建 Docker Compose 和 PostgreSQL

目标：

```text
用 Docker Compose 启动 PostgreSQL，数据持久化到本项目 data/postgres。
```

主要文件：

```text
docker-compose.yml
```

服务器验证命令：

```bash
cd /opt/resume-demos/school_data_dashboard
docker compose up -d postgres
docker compose ps
```

预期结果：

```text
postgres 容器 running。
```

### Step 2：后端最小骨架

目标：

```text
创建 FastAPI 后端，跑通 /api/health，并能读取 DATABASE_URL。
```

主要文件：

```text
backend/app/main.py
backend/app/config.py
backend/requirements.txt
backend/Dockerfile
```

验证接口：

```text
GET /api/health
```

### Step 3：数据库模型

目标：

```text
实现 SQLAlchemy models，并创建学校数据相关表。
```

主要文件：

```text
backend/app/database.py
backend/app/models.py
```

验证方式：

```text
后端启动后数据库中能看到 departments、students、courses、assets 等表。
```

### Step 4：生成模拟数据

目标：

```text
使用 Faker 生成学校模拟数据。
```

主要文件：

```text
backend/scripts/seed_data.py
```

验证命令：

```bash
docker compose exec api python scripts/seed_data.py
```

预期结果：

```text
数据库中插入学生、课程、成绩、资产和报修工单模拟数据。
```

### Step 5：实现指标 API

目标：

```text
实现 overview、学生分布、成绩趋势、资产状态、报修趋势等 API。
```

主要文件：

```text
backend/app/routers/metrics.py
backend/app/services/metrics_service.py
```

验证接口：

```text
GET /api/metrics/overview
GET /api/metrics/students-by-department
GET /api/metrics/assets-status
```

### Step 6：实现数据质量 API

目标：

```text
统计缺失、重复、异常范围、异常时间等问题。
```

主要文件：

```text
backend/app/routers/quality.py
backend/app/services/quality_service.py
```

验证接口：

```text
GET /api/quality/summary
```

### Step 7：实现 React Dashboard

目标：

```text
展示指标卡、柱状图、折线图、饼图和数据质量摘要。
```

主要文件：

```text
frontend/src/pages/Dashboard.tsx
frontend/src/components/MetricCard.tsx
frontend/src/components/ChartPanel.tsx
frontend/src/api.ts
```

### Step 8：Nginx HTTPS 接入

目标：

```text
通过统一 Nginx 访问 /demo-dashboard/ 和 /api/demo-dashboard/。
```

验证方式：

```bash
curl -I https://<server>/demo-dashboard/
curl https://<server>/api/demo-dashboard/health
```

预期结果：

```text
前端返回 200。
API health 返回 ok。
```

## 简历表达

完成后可写：

```text
基于 PostgreSQL、FastAPI、SQLAlchemy、React 和 ECharts 构建高校数据分析与可视化驾驶舱 Demo，支持学生、课程、成绩、资产和报修数据建模、模拟数据生成、聚合指标 API、数据质量检查和图表展示，并通过 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器。
```
