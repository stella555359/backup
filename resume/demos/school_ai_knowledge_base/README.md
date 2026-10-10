# 高校制度与办事流程 AI 知识库

## 项目定位

这个 Demo 用于补强“AI 知识库运行维护”和“人工智能应用开发能力”。

目标是做一个小型 RAG 知识库：

```text
学校制度文档 / 办事流程文档
-> 文档切分
-> embedding
-> 向量库
-> 用户提问
-> Top-K 检索
-> 返回回答和引用来源
```

## 技术栈

第一版推荐：

```text
后端：FastAPI
前端：React + Vite
向量库：ChromaDB
Embedding：sentence-transformers
部署：Docker Compose
入口：Nginx HTTPS
```

如果服务器暂时无法下载 embedding 模型，第一阶段可以先做 mock answer 或关键词检索，保证 API 和页面闭环先跑通。

## 目标目录结构

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
      chroma/
    requirements.txt
    Dockerfile

  frontend/
    src/
      App.tsx
      api.ts
      components/
        ChatPanel.tsx
        SourceList.tsx
    package.json
    Dockerfile

  docker-compose.yml
  nginx/
    demo-ai.conf
  docs/
    deployment.md
    learning-record.md
```

## API Overview

```text
GET /api/health
  健康检查。

GET /api/documents
  查看当前知识库文档和 chunk 数量。

POST /api/knowledge/rebuild
  重新读取 source_docs，切分文档并重建向量库。

POST /api/chat
  用户提问，返回回答和引用来源。
```

`POST /api/chat` 示例：

```json
{
  "question": "学生请假流程是什么？",
  "top_k": 3
}
```

响应示例：

```json
{
  "answer": "根据学生管理规定，请假需要先提交申请...",
  "sources": [
    {
      "file_name": "student_leave_policy.md",
      "chunk_id": "student_leave_policy-001",
      "score": 0.82,
      "content_preview": "学生因病因事不能参加教学活动，应提前..."
    }
  ]
}
```

## Docker 部署目标

本地写代码，服务器通过 Git 同步后部署到：

```text
/opt/resume-demos/school_ai_knowledge_base
```

Docker Compose 目标服务：

```text
ai-kb-api
  FastAPI 后端，监听容器内 8010。

ai-kb-frontend
  React build 产物，或由 Nginx 直接托管 dist。

ai-kb-nginx
  可选。第一版如果服务器已有统一 Nginx，就不单独起容器 Nginx。
```

推荐外部入口：

```text
https://<server>/demo-ai/
https://<server>/api/demo-ai/
```

## Overview 实现步骤

### Step 1：后端最小骨架

目标：

```text
创建 FastAPI 后端，跑通 /api/health。
```

主要文件：

```text
backend/app/main.py
backend/requirements.txt
backend/Dockerfile
docker-compose.yml
```

服务器验证命令：

```bash
cd /opt/resume-demos/school_ai_knowledge_base
docker compose up -d --build
curl http://127.0.0.1:8010/api/health
```

预期结果：

```text
返回 {"status":"ok"}。
```

### Step 2：准备模拟制度文档

目标：

```text
准备 3-5 份学校制度 / 办事流程 Markdown 文档。
```

示例：

```text
学生请假制度
奖学金申请流程
财务报销流程
科研项目申报流程
校园卡补办流程
```

主要文件：

```text
backend/data/source_docs/*.md
```

### Step 3：文档加载与切分

目标：

```text
读取 source_docs，将文档切分为 chunks，并返回文档统计。
```

主要文件：

```text
backend/app/services/document_loader.py
backend/app/services/chunker.py
backend/app/schemas.py
```

验证接口：

```text
GET /api/documents
```

### Step 4：接入 ChromaDB

目标：

```text
生成 embedding，写入 ChromaDB。
```

主要文件：

```text
backend/app/services/vector_store.py
backend/data/chroma/
```

验证接口：

```text
POST /api/knowledge/rebuild
```

### Step 5：实现 RAG 问答接口

目标：

```text
根据用户问题检索 Top-K 文档片段，返回回答和来源。
```

主要文件：

```text
backend/app/services/rag_service.py
```

验证接口：

```text
POST /api/chat
```

### Step 6：实现 React 问答页面

目标：

```text
页面支持输入问题、展示回答、展示引用来源。
```

主要文件：

```text
frontend/src/App.tsx
frontend/src/api.ts
frontend/src/components/ChatPanel.tsx
frontend/src/components/SourceList.tsx
```

### Step 7：Nginx HTTPS 接入

目标：

```text
通过统一 Nginx 访问 /demo-ai/ 和 /api/demo-ai/。
```

验证方式：

```bash
curl -I https://<server>/demo-ai/
curl https://<server>/api/demo-ai/health
```

预期结果：

```text
前端返回 200。
API health 返回 ok。
```

## 简历表达

完成后可写：

```text
基于 FastAPI、ChromaDB、sentence-transformers 和 React 构建高校制度知识库问答 Demo，支持制度文档导入、文本切分、向量检索、Top-K 来源引用和问答页面展示，并通过 Docker Compose 与 Nginx HTTPS 部署到 Debian 13 服务器。
```
