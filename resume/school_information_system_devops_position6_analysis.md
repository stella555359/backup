# 学校 6 信息系统开发与运维岗匹配分析与面试准备

## 1. 岗位理解

目标岗位是“信息系统开发与运维岗”。从截图中的职责和要求看，这个岗位比“数据平台开发与运维岗”更偏综合型信息化岗位，核心不是只做某个单点功能，而是要能参与学校信息系统从需求、设计、开发、部署、运维、升级、排障到安全管理的完整生命周期。

可以概括为：

```text
信息化项目需求分析
-> 技术方案评估
-> Web 前后端与数据库开发
-> 源代码与配置管理
-> 上线部署与升级
-> 运行监控、故障排查、性能优化
-> 集中管理平台配置与维护
-> 网络安全、数据安全和文档沟通
```

这个岗位看重的是“能不能把一个信息系统做出来、部署起来、管起来、出问题时排查清楚”，而不只是会写代码或会测试。

## 2. 使用 `jenkins_robotframework` 项目申请岗位 6 是否合适

可以使用 `C:\TA\jenkins_robotframework` 作为申请岗位 6 的核心项目经验，而且比岗位 5 更容易解释。

原因是该项目本身就是一个信息系统开发与运维项目：

```text
automation-portal
  -> platform-api
  -> Jenkins integration
  -> Jenkins Agent / UTE
  -> Robot or Python Runner
  -> artifact / result / KPI
  -> callback
  -> run record / detail / portal 展示
```

项目虽然服务于自动化测试场景，但它覆盖了岗位 6 要求中的多个关键能力：

- 信息系统总体设计、模块拆分和技术方案评估。
- Web 前端、FastAPI 后端、接口、JSON 参数、运行记录和结果查询。
- Jenkins、JCasC、Job DSL、seed job、Jenkinsfile 的配置代码化。
- Linux / Debian 环境、Nginx、HTTPS、systemd、SSH Agent、Python venv、Node 构建环境等部署运维。
- Jenkins build、artifact、callback、result JSON、timeline、metadata 等运行状态追踪与问题定位。
- Jenkins Credentials、Token、HTTPS、后端代理 Jenkins、敏感信息不入仓库等安全意识。

因此，对岗位 6 的包装重点应该从“数据平台”调整为：

```text
信息系统开发与运维平台项目
```

或者：

```text
自动化测试任务调度与运维管理平台
```

## 3. 岗位匹配度判断

综合匹配度建议写成：

```text
匹配度较高，核心匹配点集中在信息系统开发、接口设计、Jenkins 持续集成、上线部署、运行维护、问题排查、文档沉淀和跨系统协作能力。
```

如果需要量化表达，可以内部按下面口径理解：

```text
整体匹配度：75% - 85%
```

强匹配项：

- 有硕士学历背景，专业方向属于电子信息 / 通信 / 信号处理，与岗位要求的电子信息、软件工程、计算机相关方向具备相近性。
- 有 12 年软件测试、系统集成、自动化平台和 Jenkins 持续集成经验。
- 当前项目覆盖 FastAPI、React、Jenkins、Python Runner、Robot Framework、SQLite、Nginx、Linux 等平台化技术栈。
- 有需求拆解、接口设计、运行链路设计、部署验证、日志排查和文档化能力。
- 有长期系统测试和故障定位经验，适合信息系统运维和问题处理场景。

需要补强项：

- 数据库开发与可视化数据分析需要准备更直接的讲法或小 Demo。
- 网络安全、数据安全可以强调安全意识和工程实践，但不要夸大成安全专家。
- AI 应用开发不是当前项目的主线，需要准备一个轻量 AI 知识库 / RAG Demo 或至少准备清晰的学习与实践计划。
- 高校信息系统建设经验没有直接经历，需要用“平台化系统建设经验可迁移”来表达。

## 4. 与岗位职责逐条匹配

### 4.1 信息化建设项目总体设计、需求分析、技术方案评估

岗位职责：

```text
负责部处信息化建设项目的总体设计、需求分析、技术方案评估。
```

当前项目对应能力：

- 设计了 `automation-portal + platform-api + Jenkins + test-workflow-runner` 的分层架构。
- 明确前端、后端、调度层、执行层、结果回传层的边界。
- 对 Robot 执行链和 Python orchestrator 执行链做了共存设计。
- 通过 docs 文档沉淀了 roadmap、8 天执行计划、模块索引、Jenkins integration flow 和 runtime 边界。

申请时可表达为：

```text
我在项目中不仅参与功能实现，也负责将需求拆分成前端入口、后端接口、Jenkins 调度、执行器和结果回传等模块，明确各层职责和调用边界，并通过文档记录技术方案和推进步骤。这类经验可以迁移到学校信息化项目的需求分析、方案评估和总体设计中。
```

### 4.2 信息系统规格设计、源代码管理、网络数据安全审查

岗位职责：

```text
负责信息系统规格设计、源代码管理、网络数据安全审查。
```

当前项目对应能力：

- 使用 Git 仓库管理业务代码、Jenkins 配置、Job DSL、Jenkinsfile 和部署文档。
- 使用 JCasC 和 Job DSL 将 Jenkins controller、seed job、folder、pipeline job 等配置纳入代码管理。
- 通过 `RUN_ID`、`TESTLINE`、`BUILD`、`WORKFLOW_SPEC_JSON`、`RESULT_JSON_PATH` 等字段固定跨系统接口规格。
- 坚持浏览器不直接访问 Jenkins，由 `platform-api` 代理 Jenkins 调用，避免 Jenkins 凭据暴露到前端。
- Jenkins Credentials、callback token、Compass / DUT 凭据等敏感信息按环境变量或凭据管理，不写入源码仓库。

申请时可表达为：

```text
我具备源代码和配置代码化管理意识，能够把 Jenkins Job、Pipeline、环境参数和接口字段纳入版本管理，减少手工配置带来的不可追踪问题。同时在设计中注意权限边界，例如前端不直接持有 Jenkins 凭据，敏感配置通过 Jenkins Credentials 或环境变量注入。
```

### 4.3 信息系统上线部署环境建设、更新升级

岗位职责：

```text
负责信息系统上线部署环境建设、更新升级。
```

当前项目对应能力：

- 已梳理 Jenkins Master、Nginx HTTPS、Jenkins prefix、Agent、SSH、Java 17、Python venv、Node.js 构建环境等部署步骤。
- 设计了 `platform-api` 通过 systemd 运行、`automation-portal` 通过 Jenkins / 构建机生成 `dist/` 后由 Nginx 提供访问的发布方式。
- 将 Jenkins 运行环境与业务门户、后端 API 做边界拆分。
- 对服务器代码同步、依赖安装、服务重启、前端构建发布、Nginx 路由做了文档化。

申请时可表达为：

```text
我熟悉 Linux 服务部署的基本流程，能完成 Git 同步、Python 虚拟环境、systemd 服务、Nginx 反向代理、HTTPS 入口、Jenkins Agent 和构建环境配置，并能把部署和升级步骤文档化，便于后续交接和重复执行。
```

### 4.4 信息系统运行监控、问题排查、故障处理、性能测试与优化

岗位职责：

```text
负责信息系统运行监控、问题排查、故障处理、性能测试与优化。
```

当前项目对应能力：

- 平台通过 run 状态、Jenkins build、artifact、callback payload、result JSON、timeline 追踪执行过程。
- Jenkins Pipeline 阶段拆分清晰，便于定位失败发生在 checkout、venv、TAF 环境、runner、Robot、artifact 归档还是 callback。
- 项目文档记录了常见失败模式，例如 JCasC reload 失败、seed job 未生成、Pipeline 找不到 Jenkinsfile、Job 参数不一致、callback 字段不匹配、Agent Java 版本错误等。
- 个人原有经历中包含 5G 系统集成测试、日志分析、抓包定位、Trace 分析、大话务量性能测试和长稳测试。

申请时可表达为：

```text
我擅长按链路分层排查问题。比如一次执行失败，我会先判断是 Jenkins 调度、Agent 环境、代码 checkout、Python 依赖、执行器逻辑、结果归档还是 callback 回传问题，再结合日志、状态字段和产物逐步定位。这种排障方法也适用于学校信息系统的运行维护和故障处理。
```

### 4.5 信息系统集中管理平台运行维护、配置管理与优化

岗位职责：

```text
负责信息系统集中管理平台的运行维护、配置、管理与优化。
```

当前项目对应能力：

- Jenkins 本身就是集中调度和管理平台。
- 当前项目通过 `seed/jenkins-robotframework-seed` 统一生成和维护 `CIT/KPI_Testing/<SBTS>/<testline>`、`CRT/KPI_Testing/<SBTS>/<testline>` 等任务目录。
- 后续新增 SBTS / testline 时，推荐修改 Job DSL 列表并重跑 seed job，而不是手工创建多个 Job。
- 平台将 run 创建、Jenkins 调度、执行状态、artifact 链接和 KPI 结果统一到 `platform-api` 和 portal 展示。

申请时可表达为：

```text
我在项目中把 Jenkins 从单个手工 Job 使用方式，整理成可代码化、可批量生成、可追踪的集中任务管理平台。通过 JCasC、Job DSL、seed job 和 Jenkinsfile，把任务创建、参数配置、执行流程和结果回传纳入统一管理。
```

## 5. 可直接填写到岗位申请表的版本

### 5.1 岗位匹配度短版

```text
本人具备 12 年软件测试、系统集成测试、自动化平台建设和 Jenkins 持续集成经验，硕士学历，长期参与需求分析、系统联调、自动化框架建设、运行环境维护和问题定位。近期在 jenkins_robotframework 项目中，基于 FastAPI、React、Jenkins、JCasC、Job DSL、Jenkins Pipeline 和 Python Runner 设计并建设自动化测试任务调度与运维管理平台，打通前端配置、后端 API、Jenkins 调度、Agent 执行、结果归档、状态回调和运行记录查询链路。该项目与岗位要求的信息系统总体设计、Web 前后端开发、源代码与配置管理、上线部署、运行监控、故障排查、集中管理平台维护和接口开发能力高度匹配。我具备较强的问题分析、文档整理和跨团队沟通能力，能够较快适应高校信息化系统建设与运维工作。
```

### 5.2 岗位匹配度长版

```text
本人具备硕士学历和 12 年软件测试及自动化平台建设经验，长期负责通信系统集成测试、自动化用例开发、Jenkins 持续集成、版本回归保障、日志分析和问题定位，具备较强的需求理解、系统分析、接口联调、部署验证和文档沉淀能力。

在 jenkins_robotframework 项目中，我围绕自动化测试任务调度与结果回传场景，设计并推进了 automation-portal、platform-api、Jenkins integration、test-workflow-runner 等模块。项目基于 FastAPI、React、Python、Jenkins、JCasC、Job DSL、Jenkins Pipeline、Robot Framework、SQLite、Nginx 等技术，形成从前端提交 workflow、后端创建 run、Jenkins 调度任务、Agent 准备执行环境、Robot 或 Python Runner 执行、artifact 归档、callback 回写平台、前端查看状态和结果的完整闭环。

该经历与信息系统开发与运维岗具有较高匹配度：一是具备信息系统总体设计和技术方案拆解能力，能够明确前端、后端、调度层、执行层和结果层边界；二是具备 Web 后端接口、前端门户、结构化 JSON 参数、运行状态管理和结果查询能力；三是具备 Jenkins、Linux、Nginx、systemd、SSH Agent、Python venv 等部署运维能力；四是具备源代码管理和配置代码化意识，能够用 Git、JCasC、Job DSL、Jenkinsfile 管理系统配置和任务流程；五是具备故障排查和运行维护能力，能够根据日志、状态、构建产物和回调数据定位问题。

我认为自己的经历可以较好迁移到学校信息化建设场景，承担信息系统需求分析、开发联调、上线部署、运行维护、故障处理、接口对接和平台优化等工作。后续也会继续补强数据库建模、可视化分析、AI 应用和数据安全审查方面的实践，以更好支撑学校信息系统建设与运维。
```

### 5.3 项目经历申请表版本

```text
项目名称：自动化测试任务调度与运维管理平台

项目背景：面向 5G 自动化测试和 KPI 回归场景，建设一套跨系统任务调度与结果回传平台，解决测试任务配置分散、Jenkins Job 手工维护、执行状态不易追踪、结果产物和 KPI 后处理缺少统一归档的问题。

技术栈：FastAPI、React、Python、Jenkins、JCasC、Job DSL、Jenkins Pipeline、Robot Framework、SQLite、Nginx、Linux、REST API、JSON。

项目职责：负责参与平台总体方案设计和模块拆分，设计前端 Portal、后端 API、Jenkins 调度层和 Python Runner 执行层的协作链路；负责梳理 run 创建、Jenkins 触发、workflow_spec 参数传递、执行结果 JSON、artifact manifest、callback payload 等接口和字段规范；负责 Jenkins 集成方案设计，使用 JCasC、Job DSL、seed job 和 Jenkinsfile 实现 Jenkins 配置和任务创建代码化；负责整理 Linux / Jenkins / Nginx / Agent / Python venv 等部署运维步骤和常见故障排查文档。

项目成果：形成从前端提交任务、后端创建运行记录、Jenkins 调度执行、Agent 准备环境、Robot 或 Python Runner 执行、结果归档、callback 回写、前端查询详情的完整闭环，提高了任务调度、运行维护和问题排查的标准化与可追踪性。
```

### 5.4 自我评价版本

```text
我属于偏工程落地型的信息系统建设人员，既有长期系统测试、自动化测试和问题定位经验，也在近期项目中系统补强了 FastAPI、React、Jenkins、Linux 部署、CI/CD、接口设计和平台化文档能力。我的优势是能把需求拆成可执行步骤，重视接口边界、运行状态、日志证据和文档沉淀，遇到问题能够按链路分层定位。对于高校信息化岗位，我可以较快承担系统开发联调、上线部署、运行维护、故障排查、接口对接和用户沟通等工作。
```

### 5.5 岗位匹配度或职业规划版本（含 AI 辅助）

适合填写在申请表“岗位匹配度或职业规划”一栏：

```text
本人具备 12 年诺基亚通信系统软件测试、系统集成、自动化用例编写和 Jenkins 持续集成经验，长期参与 feature 需求分析、接口联调、环境部署、自动化回归、日志分析和故障定位。近期结合 Cursor AI 辅助开发方式，围绕 5G gNB E2E KPI 测试项目补强自动化测试框架、系统开发与运维能力，基于 FastAPI、React、Jenkins、JCasC、Job DSL、Jenkins Pipeline、Python Runner、Nginx、Linux、Git/GitLab/GitHub 等技术和工具，完成自动化测试任务调度与运维管理平台的需求拆解、架构边界确认、接口字段梳理、源代码与配置版本管理、Linux 服务器部署联调、运行验证和文档沉淀。项目中 AI 主要用于代码草稿、接口契约、测试设计和文档整理，本人负责技术方案取舍、人工复核、环境验证、问题排查和交付闭环。上述经历与岗位要求的信息系统规格设计、源代码管理、上线部署、运行监控、故障排查、集中管理平台维护和数据安全意识具有较高匹配度。未来希望在学校信息化建设岗位中，继续发挥自动化测试、CI/CD、系统联调、源代码管理和运维排障经验，同时合理运用 AI 工具提升需求分析、开发联调、测试验证、文档整理和问题定位效率，逐步成长为能够支撑学校信息系统开发、上线运维、持续优化和智能化应用落地的复合型信息化工程人员。
```

## 6. 面试中建议重点讲的项目主线

### 6.1 30 秒项目介绍

```text
我最近做的 jenkins_robotframework 项目，本质上是一个自动化测试任务调度与运维管理平台。它不是单纯写测试脚本，而是把前端 Portal、FastAPI 后端、Jenkins 调度、Agent 执行环境、Robot / Python Runner、结果归档和 callback 回写串成闭环。

用户在前端提交 workflow，后端创建 run 并触发 Jenkins，Jenkins 在 Agent 上准备环境并执行任务，执行完成后归档 artifact，并把状态、结果 JSON、KPI 摘要等回传给后端，前端再展示运行详情。

这个项目和信息系统开发运维岗匹配的地方在于，它覆盖了系统设计、接口开发、CI/CD、部署运维、运行状态追踪、故障排查和配置代码化。
```

### 6.2 2 分钟项目展开

```text
项目分成四层：automation-portal 是前端入口，platform-api 是统一后端，Jenkins integration 是调度和公共前置层，test-workflow-runner 是执行层。

我重点做的是把这几层的边界设计清楚。前端不直接访问 Jenkins，所有请求先到 FastAPI；FastAPI 负责创建 run、保存 workflow、触发 Jenkins、接收 callback；Jenkins 负责 checkout 代码、准备 workspace、激活运行环境、执行 Robot 或 Python Runner、归档 artifact；runner 只关心执行 workflow 并输出标准化 result JSON。

在运维方面，我把 Jenkins 配置尽量代码化，使用 JCasC 创建 seed job，用 Job DSL 生成业务 Job，用 Jenkinsfile 固化执行阶段。这样新增 release 或 testline 时，不需要在 Jenkins 页面手工创建大量 Job，而是通过代码维护，便于版本管理和问题追踪。

如果构建失败，可以根据阶段定位：是 seed job 没生成、Job 参数不对、Jenkinsfile 路径错误、checkout 失败、venv 准备失败、runner 执行失败，还是 callback 回写失败。这个分层排查思路也适用于学校信息系统的运行维护。
```

## 7. 面试高频问题准备

### 7.1 你为什么适合信息系统开发与运维岗？

建议回答：

```text
我不是纯开发背景，但我的经历和这个岗位非常接近。过去 12 年我长期做系统集成测试、自动化平台和 Jenkins 持续集成，熟悉系统上线前后的联调、环境准备、问题定位和运行保障。近期项目中，我又系统补强了 FastAPI、React、Jenkins 配置代码化、Linux 部署、Nginx、systemd、接口设计和结果回调。

这个岗位需要的是既懂开发、又懂部署运维、还能排查问题和写文档的人。我在项目中实际做过需求拆解、接口字段设计、Jenkins Pipeline、Agent 环境准备、artifact 归档、callback 回写和故障排查文档，所以我认为自己能较快迁移到学校信息系统开发和运维工作中。
```

### 7.2 你的项目和学校信息系统有什么关系？

建议回答：

```text
业务场景不同，但技术形态很接近。学校信息系统可能是教务、人事、科研、资产、财务或统一办事平台；我的项目是自动化测试任务调度平台。

两者共同点是都需要前端入口、后端接口、流程调度、状态管理、数据回传、权限边界、部署运维和故障排查。比如学校系统中一个流程可能需要对接多个业务系统，我的项目中一次 run 也需要经过 Portal、API、Jenkins、Agent、Runner、artifact 和 callback。核心能力都是跨系统流程编排和可追踪运维。
```

### 7.3 你在项目中做过哪些开发工作？

建议回答：

```text
主要包括四类。第一是后端接口和数据契约设计，例如 run create、run detail、artifact、KPI summary、callback payload 等。第二是执行层 runner 的 workflow request、stage、item、result JSON 和 artifact manifest。第三是 Jenkins 集成，包括 Job DSL、JCasC、seed job、Jenkinsfile、checkout、request materialize 和 callback helper。第四是前端门户的功能规划，包括 run submit、workflow builder、run list、run detail、KPI summary 和 artifact 展示。
```

### 7.4 你做过哪些运维和部署工作？

建议回答：

```text
项目中涉及 Jenkins Master、Nginx HTTPS、Jenkins prefix、Agent 节点、SSH 凭据、Java 17、Python venv、Node.js 构建环境、systemd 服务、前端 dist 发布等。我的做法是把部署动作拆成可验证步骤，并记录预期结果和常见失败模式。比如 Agent 侧要确认 Java 版本、SSH 连通性、workspace 权限；Jenkins 侧要确认 JCasC reload、seed job、Job DSL、Pipeline script path；后端侧要确认服务启动和 health API。
```

### 7.5 如果系统上线后出现故障，你怎么排查？

建议回答：

```text
我会先按链路分层定位，而不是直接猜原因。

第一步确认入口是否可用，例如 Nginx、HTTPS、前端页面和 API health。第二步看后端日志和 run 记录，确认请求有没有进入系统。第三步看 Jenkins 是否被触发，Job 参数是否正确。第四步看 Agent 是否在线、workspace 是否可写、依赖和环境是否准备成功。第五步看执行器日志、result JSON 和 artifact 是否生成。第六步看 callback 是否成功回写平台。

这样可以把问题从一个大故障拆成网络入口、后端接口、调度、执行环境、业务执行、结果回传几个小范围，定位效率更高。
```

### 7.6 你如何理解源代码管理和配置管理？

建议回答：

```text
我认为信息系统不仅业务代码要进 Git，配置和部署流程也应尽量代码化。比如在项目中，Jenkins Job 不建议在页面里手工逐个创建，而是通过 JCasC、Job DSL、seed job 和 Jenkinsfile 管理。这样 Job 参数、Pipeline 路径、执行阶段和目录结构都有版本记录，便于 code review、回滚和问题追踪。
```

### 7.7 你有哪些安全意识？

建议回答：

```text
我会重点关注三个方面。第一是凭据不进源码仓库，例如 Jenkins token、SSH 私钥、Compass 凭据、DUT 凭据都应通过 Jenkins Credentials 或环境变量管理。第二是前端不直接访问 Jenkins，避免把 Jenkins token 暴露到浏览器，而是通过后端 API 做统一代理。第三是外部访问通过 Nginx 和 HTTPS 收口，接口回调使用 token 或固定配置做校验。

我不是网络安全专家，但具备基本的数据安全和权限边界意识，后续也会继续补强等保、日志审计、最小权限、数据脱敏等高校信息化常见要求。
```

### 7.8 你在 AI 应用方面有什么准备？

建议回答：

```text
当前 jenkins_robotframework 项目主要是信息系统开发和运维平台，不是直接的 AI 应用项目。但我已经在日常开发中使用 AI 辅助做需求拆解、接口设计、测试点生成、日志分析和文档整理，并坚持人工复核。

如果岗位需要 AI 应用开发，我计划准备一个轻量的高校制度知识库 Demo，使用 FastAPI、向量库、embedding 和 React 实现制度文档导入、检索问答和来源引用。这样可以把 AI 能力和学校信息化场景结合起来。
```

## 8. 面试前需要准备的材料

### 8.1 必须准备

- 一张项目架构图：`Portal -> API -> Jenkins -> Agent -> Runner -> Callback -> DB / Portal`。
- 一段 30 秒项目介绍。
- 一段 2 分钟项目展开。
- 一段故障排查案例，最好围绕 Jenkins Agent、JCasC、seed job、Pipeline 参数或 callback。
- 一段安全意识说明，重点讲凭据、HTTPS、后端代理 Jenkins、敏感信息不入仓库。
- 一段“为什么从测试转信息系统开发运维也能胜任”的解释。

### 8.2 建议补强

- 数据库：准备 `runs`、`artifacts`、`kpi_results` 三张表的设计思路。
- 可视化：准备 run 列表、状态统计、失败原因分布、KPI 摘要趋势的页面设想。
- AI：准备一个高校制度知识库 Demo 的架构和接口说明。
- 网络安全 / 数据安全：准备最小权限、日志审计、数据脱敏、备份恢复、HTTPS、凭据管理的基本概念。
- 高校业务：提前熟悉教务、人事、科研、资产、财务、统一身份认证、办事大厅等典型系统。

## 9. 简历项目描述建议

如果申请岗位 6，简历里的项目名称建议改得更贴近信息系统：

```text
自动化测试任务调度与运维管理平台
```

项目简介建议：

```text
基于 FastAPI、React、Jenkins 和 Python Runner 构建自动化测试任务调度与运维管理平台，实现前端 workflow 配置、后端 run 管理、Jenkins 任务调度、Agent 环境准备、Robot / Python Runner 执行、artifact 归档、callback 状态回写和运行详情查询，提升任务执行、系统运维和问题排查的标准化、自动化和可追踪能力。
```

核心贡献建议：

- 负责平台总体架构拆解，明确前端门户、后端 API、Jenkins 调度层、执行层和结果回传层职责边界。
- 设计 run 创建、Jenkins trigger、workflow_spec 参数传递、result JSON、artifact manifest 和 callback payload 等接口与字段规范。
- 使用 JCasC、Job DSL、seed job 和 Jenkinsfile 实现 Jenkins 配置代码化和 Job 自动生成。
- 设计 Jenkins Pipeline 执行阶段，覆盖 checkout、环境准备、request materialize、runner 执行、artifact 归档和 callback 回传。
- 梳理 Linux / Jenkins / Agent / Nginx / Python venv / Node 构建环境部署步骤，沉淀验证命令和常见失败模式。
- 参与运行状态、日志、artifact 和结果摘要的设计，提升系统运行维护和故障定位效率。

## 10. 岗位短板与应对话术

### 10.1 不是科班计算机专业怎么办

应对：

```text
我的硕士方向是信号与信息处理，本科是通信工程，属于电子信息相关背景。虽然不是纯计算机专业，但 12 年工作都在软件系统测试、自动化开发、Jenkins 持续集成、Python 脚本、接口联调和平台建设中，实际工作内容与信息系统开发运维高度相关。
```

### 10.2 开发经验不如纯后端开发怎么办

应对：

```text
我不把自己包装成纯后端专家，我的优势是系统工程和落地能力。信息系统开发运维岗需要的不只是写业务代码，还包括需求拆解、接口联调、部署、运维、故障处理、文档和沟通。我在这些方面有长期积累，同时近期项目也补强了 FastAPI、React、Jenkins、Linux 部署和接口设计。
```

### 10.3 网络安全经验不深怎么办

应对：

```text
我具备基础安全意识，包括 HTTPS 入口、凭据不入库不入仓库、Jenkins Credentials 管理、前端不直接接触 Jenkins token、接口回调校验、日志和敏感信息隔离等。对于更体系化的安全要求，例如等保、审计、最小权限和数据脱敏，我会按学校规范继续学习并严格执行。
```

### 10.4 没有高校系统经验怎么办

应对：

```text
我没有直接参与高校信息系统建设，但我做过的平台化项目在技术形态上是可迁移的。高校系统常见问题是多系统对接、流程状态跟踪、接口标准、权限和运维保障；我的项目也解决了 Portal、API、Jenkins、Agent、Runner、artifact、callback 之间的跨系统协作和运行追踪问题。我会提前学习高校典型业务系统，尽快补齐业务理解。
```

### 10.5 项目主要是在 AI 帮助下完成，代码能力没有那么强怎么办

这个问题要诚实处理，但不要把自己说弱。

不建议说：

```text
这个项目基本都是 AI 写的，我其实不太会。
```

也不建议说：

```text
这个项目全部是我独立手写完成的。
```

更稳妥的定位是：

```text
我使用 AI 提升开发效率，但需求拆解、技术方案取舍、接口边界确认、代码人工复核、部署联调、运行验证、问题排查和文档沉淀由我负责。
```

核心逻辑是：

```text
AI 可以生成代码草稿，
但不能替你理解业务目标、判断系统边界、确认字段含义、跑通部署链路、分析失败日志、决定修复方向和完成交付闭环。
```

所以面试中不要把自己包装成“资深全栈开发专家”，而是包装成：

```text
具备测试、自动化、CI/CD 和系统运维背景的信息系统工程人员，能够借助 AI 提升开发效率，并负责需求拆解、系统联调、部署验证、问题排查和文档交付。
```

## 11. AI 辅助开发的描述方式与破解方式

### 11.1 申请表 / 简历中的稳妥描述

可以写：

```text
在项目推进过程中，使用 AI 辅助完成需求拆解、代码草稿生成、接口契约梳理、测试用例设计和文档整理；本人负责业务场景理解、技术方案取舍、代码人工复核、运行验证、部署联调、问题排查和交付文档沉淀，形成 AI 辅助开发 + 人工验证闭环。
```

如果申请表篇幅有限，可以写短版：

```text
项目采用 AI 辅助开发方式提升实现效率，本人重点负责需求拆解、架构边界确认、接口字段审核、部署联调、运行验证、故障排查和文档沉淀。
```

### 11.2 面试被问“这个项目是不是 AI 帮你做的”怎么回答

建议回答：

```text
是的，这个项目有较多 AI 辅助参与，我不会把它包装成完全靠自己纯手写完成。我的做法是把 AI 当成开发效率工具，用它辅助生成代码草稿、测试草稿和文档草稿，但关键判断和最终验证由我负责。

例如项目里哪些模块应该拆开、前端为什么不能直接调 Jenkins、FastAPI 和 Jenkins 的边界怎么划、RUN_ID / BUILD / TESTLINE / WORKFLOW_SPEC_JSON 这些字段怎么传、Jenkins Job 如何通过 JCasC / Job DSL / seed job 管理、失败后怎么按链路排查，这些都需要我理解和确认。

所以我想展示的不是“我已经是资深全栈开发”，而是我能借助 AI 把复杂系统拆开、跑起来、验证清楚，并能解释主链路和排查问题。对于代码细节能力，我也会持续补强，尤其是 FastAPI、Python、Jenkins Pipeline、数据库和前端基础。
```

### 11.3 破解面试风险的核心思路

面试官真正担心的不是“你用了 AI”，而是下面几个问题：

- 你是否看得懂自己项目的主链路。
- 你是否能解释关键技术选择。
- 你是否能独立定位常见问题。
- 你是否能在没有 AI 的情况下做基础修改和验证。
- 你是否诚实，不夸大自己的开发能力。

破解方式不是回避 AI，而是主动建立可信边界：

```text
我承认 AI 参与了代码实现，但我能讲清楚系统为什么这样设计、每层做什么、核心字段怎么流转、部署验证怎么做、失败时怎么定位。
```

这句话背后的能力定位是：

```text
代码实现能力：持续补强中
系统理解能力：可以讲清主链路
工程落地能力：能完成部署、验证、排障和文档
岗位匹配能力：偏信息系统开发运维，而不是纯后端研发
```

### 11.4 面试时可以主动补一句

如果面试氛围比较坦诚，可以主动这样说：

```text
我现在不会把自己定位成纯开发专家。我的强项是测试、自动化、CI/CD、系统联调和问题定位；这个项目是在 AI 辅助下完成的，但我把它作为补齐开发和运维能力的实战项目。对学校信息系统开发与运维岗来说，我更能贡献的是系统上线、运行维护、接口联调、故障排查、文档沉淀和持续优化能力。
```

这句话比硬说“我代码很强”更可信。

## 12. 自己必须能讲清楚的点

下面这些点必须真正理解。面试时只要这些能讲清楚，就不会显得只是“AI 生成了一堆代码”。

### 12.1 主链路：`Portal -> FastAPI -> Jenkins -> Runner -> Callback`

必须能讲清楚：

```text
用户不是直接进 Jenkins 手工点 Job，而是在 automation-portal 里提交运行请求。
portal 把请求发给 platform-api。
platform-api 创建 run 记录，生成 run_id，保存 workflow 或 robot 参数，然后触发 Jenkins。
Jenkins 根据 job 参数在 Agent / UTE 上准备 workspace、checkout 代码、准备 Python / TAF / Robot 环境。
执行器可以是传统 Robot，也可以是 Python test-workflow-runner。
执行完成后，Jenkins 归档 artifact，并通过 callback 把状态、结果摘要、artifact 信息回写给 platform-api。
platform-api 更新 run 状态，前端再查询 run detail 展示结果。
```

面试讲法：

```text
这个链路的核心设计是把用户入口、业务 API、长任务调度和真实执行环境拆开。前端负责交互，FastAPI 负责记录和接口，Jenkins 负责长任务调度和环境准备，Runner 负责执行，callback 负责把结果闭环回平台。
```

为什么这样设计：

```text
因为 Jenkins 凭据不能暴露给浏览器，长任务也不适合由 Web 请求直接执行。通过 FastAPI 代理 Jenkins，可以统一记录 run、校验参数、保存状态；通过 Jenkins 执行，可以利用它的日志、超时、artifact、credentials 和 Agent 调度能力。
```

常见追问：

```text
为什么不让 React 直接调 Jenkins？
```

建议回答：

```text
因为这样会把 Jenkins token 或认证信息暴露到浏览器，也不利于统一记录业务 run_id。后端代理 Jenkins 更安全，也更方便做参数校验、状态管理和结果聚合。
```

### 12.2 核心字段：`RUN_ID`、`BUILD`、`TESTLINE`、`WORKFLOW_SPEC_JSON`

必须能讲清楚每个字段的作用。

```text
RUN_ID：
平台生成的一次运行唯一标识，用来把前端请求、后端 run 记录、Jenkins build、Runner result 和 callback 结果关联起来。

BUILD：
本次测试对应的软件包版本或 CIT 包版本。它会作为 Jenkins 参数传入，也会进入 runner request 和 KPI generator 参数，方便后续按软件版本追踪结果。

TESTLINE：
目标测试线或执行环境标识。Jenkins 根据它知道本次任务要在哪个 testline / UTE 环境准备和执行。

WORKFLOW_SPEC_JSON：
前端或后端传给执行层的结构化 workflow 描述，里面包含 stage、item、串并行关系、KPI generator / detector 开关和参数等。
```

面试讲法：

```text
这些字段的价值是把跨系统链路串起来。前端、FastAPI、Jenkins、Runner 和 callback 都围绕同一个 run_id 和同一组参数工作，避免不同系统各自维护一套含义不一致的字段。
```

常见追问：

```text
如果 callback 回来了，但平台找不到对应 run，可能是什么问题？
```

建议回答：

```text
优先查 RUN_ID 是否一致。可能是 Jenkins 参数传错、Runner request 物化时字段丢失、callback payload 没带 run_id，或者后端 run 记录没有成功创建。排查时会先看 platform-api run 记录，再看 Jenkins build 参数，再看 callback payload。
```

### 12.3 Jenkins 配置代码化：JCasC、Job DSL、seed job、Jenkinsfile

必须能讲清楚它们的关系。

```text
JCasC：
Jenkins Configuration as Code，用来把 Jenkins controller、插件、节点、凭据引用、seed job 等基础配置代码化。

Job DSL：
用 Groovy DSL 定义 Jenkins folder、pipeline job 和参数模板，例如 CIT/KPI_Testing/SBTS26R1/testline 这种 Job 结构。

seed job：
一个专门负责执行 Job DSL 的 Jenkins Job。它 checkout 仓库后运行 jobs/*.groovy，从而自动创建或更新业务 Job。

Jenkinsfile：
具体业务 Job 的执行流程，例如 checkout、prepare env、materialize request、run CLI、archive artifact、callback。
```

面试讲法：

```text
JCasC 负责把 seed job 创建出来；seed job 负责执行 Job DSL；Job DSL 负责创建业务 Pipeline Job；Jenkinsfile 负责定义业务 Job 每次 build 真正执行哪些阶段。
```

为什么这样做：

```text
这样可以减少 Jenkins 页面手工配置。新增 release 或 testline 时，优先改 Job DSL，然后重跑 seed job，由 Jenkins 自动创建或更新 Job。配置进入 Git 后可以 review、回滚，也方便排查变化。
```

常见追问：

```text
为什么不直接在 Jenkins 页面手工创建 Job？
```

建议回答：

```text
手工创建适合临时验证，但不适合长期维护。页面操作不容易 review，也容易出现参数不一致。Job DSL 和 seed job 可以让 Job 结构、参数和 Pipeline 路径都可版本化，后续扩展多个 testline 时更稳定。
```

### 12.4 任务失败时如何按链路排查

必须能讲清楚排查顺序。

```text
第一层：入口是否正常
- Nginx / HTTPS 是否可访问
- 前端页面是否打开
- /api/health 是否正常

第二层：后端是否创建 run
- platform-api 是否收到请求
- run_id 是否生成
- 参数校验是否失败
- 数据库或 run store 是否写入

第三层：Jenkins 是否触发
- Jenkins job path 是否正确
- build 是否出现
- build 参数是否包含 RUN_ID、BUILD、TESTLINE、WORKFLOW_SPEC_JSON

第四层：Agent / UTE 是否可用
- Agent 是否 online
- SSH / Java / workspace 权限是否正常
- Python venv、TAF、Robot 环境是否准备成功

第五层：执行器是否产出结果
- Robot 或 Runner 是否真正执行
- result.json、output.xml、log.html、report.html 是否生成
- artifact 是否归档

第六层：callback 是否回写
- callback payload 是否带 run_id
- platform-api 是否接收成功
- run 状态是否更新
- 前端详情页是否能看到结果
```

面试讲法：

```text
我不会一上来猜代码 bug，而是先按链路缩小范围。因为这种平台问题可能出在入口、API、Jenkins、Agent、执行环境、执行器、artifact 或 callback 任意一层。分层排查可以快速判断问题属于开发、部署、配置还是运行环境。
```

常见追问：

```text
如果 Jenkins build 有了，但平台状态一直不更新，你怎么查？
```

建议回答：

```text
我会先看 Jenkins build 是否执行到 callback 阶段，再看 callback 脚本日志和 HTTP 返回码；然后检查 callback payload 里的 run_id、status、artifact 字段是否符合后端接口；最后看 platform-api 日志和数据库 run 状态。如果 Jenkins 执行成功但 callback 失败，问题一般集中在 callback URL、token、payload 字段或后端接口校验。
```

### 12.5 自己必须能做的最小代码修改

虽然项目有 AI 辅助，但面试前建议至少能独立做这些小修改：

- 在 FastAPI 里新增或修改一个简单字段。
- 看懂一个 Pydantic schema 的字段含义。
- 看懂一个 Jenkinsfile stage 的作用。
- 修改 Job DSL 里的 testline 列表。
- 看懂 result JSON / callback payload。
- 根据日志判断一个失败点属于哪个层级。

面试讲法：

```text
我承认复杂代码实现还在补强，但我至少要做到能看懂主链路代码、能改基础字段、能调整 Jenkins 参数、能读懂日志和 JSON 结果、能完成部署验证。对信息系统开发与运维岗来说，这些能力能支撑我先承担联调、运维、排障和小功能迭代，再逐步提升更复杂的开发能力。
```

## 13. 面试前 3 天准备计划

### Day 1：项目表达收口

- 背熟 30 秒项目介绍。
- 背熟 2 分钟项目展开。
- 画出项目架构图。
- 整理 1 个 Jenkins 故障排查案例。
- 背熟“AI 辅助开发 + 人工验证闭环”的表述。
- 能讲清 `Portal -> FastAPI -> Jenkins -> Runner -> Callback` 主链路。

### Day 2：岗位能力补强

- 准备数据库表设计：`runs`、`run_artifacts`、`run_kpi_results`。
- 准备 Nginx、systemd、Jenkins Agent、JCasC、Job DSL 的讲法。
- 准备安全意识：凭据、HTTPS、token、最小权限、数据脱敏。
- 能讲清 `RUN_ID`、`BUILD`、`TESTLINE`、`WORKFLOW_SPEC_JSON`。
- 能讲清 JCasC、Job DSL、seed job、Jenkinsfile 的关系。

### Day 3：高校场景迁移

- 准备“如何迁移到教务 / 人事 / 资产 / 科研系统”的回答。
- 准备“如果接手一个学校内部系统，你第一周怎么做”的回答。
- 准备 AI 知识库 Demo 的 1 分钟说明。
- 准备“如果任务失败，我怎么按链路排查”的完整回答。
- 准备 2 个自己能独立完成的小修改示例。

## 14. 如果面试官让你讲接手学校系统的工作思路

可以这样回答：

```text
如果我接手一个学校内部信息系统，我会先做四件事。

第一，梳理业务流程和用户角色，明确这个系统服务哪些部门、有哪些核心流程、哪些数据是关键数据。

第二，梳理技术资产，包括代码仓库、部署环境、数据库、Nginx、服务进程、定时任务、第三方接口、账号权限和备份方式。

第三，建立运行状态和故障排查清单，例如健康检查接口、日志路径、服务启动方式、数据库连接、接口调用链、常见错误和回滚方式。

第四，再根据当前痛点做优化，比如接口标准化、配置代码化、发布流程规范化、日志和监控补齐、权限和敏感数据检查。

我会先保证系统稳定运行，再逐步优化开发和运维流程。
```

## 15. 最推荐的申请表最终版本

如果申请表只能填一段，建议使用下面这一版：

```text
本人具备硕士学历和 12 年软件测试、系统集成、自动化平台建设及 Jenkins 持续集成经验，长期参与需求分析、环境部署、接口联调、自动化回归、日志分析和故障定位。近期在 jenkins_robotframework 项目中，基于 FastAPI、React、Jenkins、JCasC、Job DSL、Jenkins Pipeline、Python Runner、Robot Framework、Nginx 和 Linux 设计并建设自动化测试任务调度与运维管理平台，形成前端 workflow 配置、后端 run 管理、Jenkins 调度、Agent 环境准备、执行器运行、artifact 归档、callback 状态回写和运行详情查询的完整闭环。项目推进中使用 AI 辅助完成代码草稿、接口梳理、测试设计和文档整理，本人重点负责需求理解、方案取舍、接口字段审核、部署联调、运行验证、问题排查和交付文档沉淀。该项目体现了信息系统总体设计、Web 前后端开发、接口规范设计、源码和配置代码化、上线部署、运行维护、故障排查、集中管理平台配置优化及数据安全意识等能力，与信息系统开发与运维岗位要求匹配度较高。本人工作细致负责，重视文档沉淀和跨团队沟通，能够较快适应高校信息化系统建设、开发联调、运维保障和持续优化工作。
```

## 16. 本文档使用建议

- 申请表“岗位匹配度 / 个人优势”优先使用第 15 节。
- 如果字数限制较短，使用第 5.1 节。
- 如果需要填写项目经历，使用第 5.3 节。
- 如果申请表明确要求“岗位匹配度或职业规划”，优先使用第 5.5 节。
- 面试前重点背第 6 节和第 7 节。
- 如果担心 AI 辅助开发被追问，重点背第 11 节和第 12 节。
- 不建议在面试中把自己包装成纯网络安全、纯 AI 或纯后端专家；更稳妥的定位是“信息系统开发运维 + 自动化平台 + Jenkins CI/CD + 系统排障”。

