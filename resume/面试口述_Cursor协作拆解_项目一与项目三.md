# 面试口述：我怎么用 Cursor 拆解并落地项目一、项目三

对照仓库事实整理，不是凭记忆编提示词。忘了当初哪一句怎么说没关系；面试要讲的是 **先拆什么、一次给 AI 多少上下文、你自己验什么**。

- 项目一代码：`C:\TA\jenkins_robotframework`
- 项目三代码：`C:\TA\robotws_mcp_server`
- 简历口径见：`简历_林XX_自动化测试工程师_通用软件向.md`

仓库里给 Cursor 的「记忆」就是 step 文档。新开对话的恢复顺序也写在文档里，不靠把整仓贴进聊天。

---

## 1. 先用 1 分钟定调（开场就说这个）

我不是把「做个自动化平台」整句丢给 Cursor 让它一次写完。做法是：

1. **我先定痛点和闭环**：人在哪一步浪费时间，做成之后从哪点到哪收。
2. **我先切模块和边界**：谁负责配置、谁负责执行、谁负责回收；每一步写清「做 / 不做」。
3. **写成一份只覆盖当前能力的 step 文档**，再开 Cursor。新会话先让它读索引和当前 step，不把历史聊天当上下文。
4. **Cursor 只改这一步的代码和文档**。我在 Debian / 本地跑验收，把成功或报错贴回去，再修或进入下一步。
5. **AI 生成的代码我当草稿**：看 diff、对接口字段、对页面 / 库 / Jenkins 是否一致。结论（RCA、生成用例）都经人工复核。

一句话：Cursor 负责按当前 step 编码落地；需求怎么切、接不接受、线上通不通，是我的责任。

---

## 2. 给 Cursor 喂上下文的固定套路（两个项目通用）

面试被问「你当时怎么跟 AI 沟通」，按下面讲，比背 prompt 稳。

### 2.1 为什么不能一轮做完

平台和 MCP 都跨多块：页面、接口、库、Jenkins、执行机、索引、约束。一轮生成出来的东西，你无法判断是接口错了、回调错了，还是页面没刷新。所以必须 **一步只增加一个可验收的能力**。

### 2.2 新开对话时喂什么（恢复上下文）

项目一文档写明：Cursor 重启后按这个顺序读，不要靠上一场聊天。

```text
docs/README.md
  -> 路线图 / 综合总结 / 当前 8 天计划
  -> 当前模块 README.md、index.md
  -> 正在做的那一份 step 文档
```

`platform-api` 的最短路径是：

```text
模块 index（进度看板 + 最近 4 个 step）
  -> 稳定专题（测试工作流、API 调用链）
  -> 当前 step
  -> 若已到测试自动化，再看 testing-automation
```

`test-workflow-runner` 同样：先看该模块 index 的进度看板，再看 overview 里的模块边界，再进当前 step。

项目三是：

```text
docs/README.md
  -> 7 层架构规范（长期方向）
  -> 当前 layer 的实现文档
  -> 对应 tests/layerN
```

早期 MCP 还有一份逐步构建记录（后来归到 archive）：一次只做一个 step，同步补 pytest，你本地验收后再下一步。

### 2.3 每一轮实际丢给 Cursor 的内容

通常只有这几样，不会把整个 `C:\TA` 塞进去：

| 给 AI 的 | 不给 / 少给 |
|---|---|
| 当前 step：目标、不做、涉及文件、验收命令 | 下一模块的实现细节 |
| 相关的已有接口 / schema / 调用链文档 | 无关目录的大段代码 |
| 「只改这些文件，不要顺手做下一步」 | 「顺便把前端和 Jenkins 也写了」 |
| 我在服务器上跑出来的日志 / 失败现象 | 没有验收标准的「优化一下」 |

每一份 step 后来都收敛成同一套模板，等于给 Cursor 的任务说明书：

1. 这一步解决什么问题  
2. 改了哪些文件  
3. 核心调用链  
4. 关键字段  
5. 服务器验证命令和预期结果  
6. 需要我确认的业务点  
7. 小结  

测试证据另写在 `testing-automation/`，不和设计文档混在一起。

### 2.4 每一天的协作节奏（项目一 8 天计划里的原文口径）

1. 先读当天 step 和相关代码，确认今天完成什么、不做什么。  
2. 先画接口 / 流程边界，再改代码。  
3. 每完成一个小能力，AI 整理服务器验证命令、预期结果、失败时怎么判断。  
4. **我在服务器上执行验证，把结果贴回去。**  
5. AI 根据验证结果修，或进入下一步。  
6. 当天结束前更新 step 文档、测试记录和演示命令。  

约定过：AI 不主动在我这边跑 pytest / 前端测试冒充已验收；验证步骤它写，**我在目标环境执行**。

### 2.5 你在 Cursor 里具体扮演哪一层

可以这样说，避免被理解成「AI 做完我不管」或「我是全栈手写」：

- **我**：痛点、模块切分、字段该不该存在、和 Jenkins / 用例仓库怎么接、Debian 部署、联调是否算过。  
- **Cursor**：按 step 写 FastAPI / React / 解析器 / MCP 工具、补测试草稿、同步文档。  
- **我验收**：健康检查、建 run、触发、回调、库里的记录、页面展示、索引能否查出本组关键字。  
- **人工复核**：KPI 是否劣化、RCA 分类、MCP 生成的用例能不能当参考。

---

## 3. 项目一：KPI 回归平台（`jenkins_robotframework`）

### 3.1 痛点（先讲这个，再讲技术）

日常 KPI / 回归之前是分散的：人去 Jenkins 上点、自己找产物、再逐份报告和日志判断这次有没有劣化。我想收成一条闭环：

```text
页面创建任务
  -> 接口落下 run 记录
  -> Jenkins 去调度执行
  -> 结果和产物回来
  -> 页面 / 数据库 / Jenkins 对得上
  -> 能看 KPI 对比和失败摘要
```

不是用页面取代 Jenkins。Jenkins 继续负责任务长、节点、日志、产物、凭证；平台负责把「点、收、看、对」收口。

### 3.2 简历上的三模块，和仓库里的四模块怎么对上

简历对外说三块，避免一次倒太多内部目录名：

| 简历说法 | 实际对应 | 负责 |
|---|---|---|
| 配置调度 | 门户填参 + `platform-api` 创建 run | 任务参数、`run_id`、要跑哪类执行 |
| 任务执行 | `jenkins-integration` + `test-workflow-runner` | Job / 工作空间 / checkout / Robot 或 Python KPI 执行 |
| 结果回收 | callback + SQLite + 门户详情 | 状态回写、产物和 KPI 查询、展示、AI 摘要 |

仓库为了边界清晰拆成四个目录，面试若被追问可以补一句：

- `automation-portal`：React 页面，不直接打执行机。  
- `platform-api`：FastAPI，run 契约、入库、回调、查询；不写 Jenkinsfile，不执行 Robot。  
- `jenkins-integration`：公共 Job / Pipeline / checkout / 回调脚本。  
- `test-workflow-runner`：执行层，读已准备好的 workspace，出 `result.json` / timeline / 产物清单；KPI generator / detector 从这里后处理接入。

「独立推进」指这条切分、联调和验收是我盯的；每一层的代码按 step 用 Cursor 落地。

### 3.3 总策略：后端契约先行，页面后接

没有先做漂亮页面。顺序是：

```text
先能创建并查到 run（接口 + SQLite）
  -> 再冻结和 Jenkins 的交接 / 回调
  -> 再能查产物和 KPI
  -> 再让详情页够用
  -> 再补门户表单和列表
  -> 再补 AI 分析契约和展示
```

原因：页面再好看，回调字段对不上，闭环仍是假的。

### 3.4 逐步怎么做（按真实 step，口述时不必报编号）

下面编号是仓库里的，方便你自己复习；面试用「先…再…」即可。

**（1）先把 `platform-api` 做成最小服务**

- 目录和配置层。  
- `GET /api/health`：证明服务活着。  
- 定 run 的 schema：创建时最少要哪些字段。  
- `POST /api/runs` 先定义返回语义，再接入 SQLite，真正插入一条 run。  
- `GET /api/runs` 列表，`GET /api/runs/{run_id}` 详情。  

这一段喂给 Cursor 的上下文就是：当前只要「能建、能存、能查」，不要触发 Jenkins。验收是健康检查和建 run 后库里有记录。

**（2）冻结执行器无关的创建契约**

创建 run 时要能区分至少两类执行，避免后期字段搅在一起：

- 共用：测试环境、执行类型、构建号等。  
- Robot 任务：用例路径。  
- Python KPI 编排：workflow 描述。  
- KPI 后处理开关（生成报告、异常检测）只属于 KPI 这条链，不塞进普通 Robot 任务。  

验收：缺必填字段要失败；Robot 任务带上 KPI 后处理配置要拒绝。这一步由我在服务器跑接口测试确认过。

**（3）Jenkins 触发和回调的最小闭环**

约定：

- 平台负责记下这次 run，并提供回调入口。  
- 真正怎么 trigger Job、节点、工作空间，放执行 / Jenkins 层，不塞进 FastAPI 里写死。  
- 跑完由 Jenkins 侧把状态、build 信息、产物位置回调回来，平台更新同一条 `run_id`。  

要能讲的异常：回调失败、重复回调、页面显示成功但 Jenkins 红（或反过来）——先对 `run_id` / build 号，再看是 trigger 没出去、执行失败，还是回写失败。

**（4）产物和 KPI 查询面**

回调之后页面不能只显示「成功」。补：

- 产物清单（例如 log、报告、Excel）。  
- KPI 生成摘要、异常检测摘要。  

简历里的「历史对比、趋势、异常标注」对应这里：报告收回来之后接上对比展示；统计规则按 **接入和验收** 讲，不要说整套检测算法都是你从零推导的。

**（5）详情接口升级成「执行后能看完」**

`GET /api/runs/{run_id}` 要能带上 workflow、产物、KPI、detector，门户详情一页能对完，不用再手动翻三处。

**（6）执行层 `test-workflow-runner`（任务执行这一块变厚以后才独立）**

KPI 长流程不适合全部塞进 Robot 文本里，所以执行层单独拆。逐步冻结：

- 请求怎么加载、CLI 能否 dry-run（先不打真环境）。  
- stage / item 怎么串并行，哪些不能乱并行。  
- 统一 `result.json`、时间线、产物清单。  
- generator / detector 作为执行后的内部处理。  
- Python KPI Runner：资源锁、KPI 窗口等。  
- 再和门户的 workflow 配置、Jenkins 调度入口对齐。  

和真实测试线配置、用例仓库、公共库网关的运行时契约，文档里仍标为要继续收口的部分。面试若问「是不是全部环境都自动通了」，就说执行层契约已经按 step 往前推，和真实测试线的最后一截以当时验收为准，不夸成全自动无人值守。

**（7）门户（配置调度的人机入口，放在接口稳定之后）**

最小页面不是大而全后台，而是能完成一次真实任务：

```text
填写测试环境、用例路径
  -> POST 创建 run
  -> POST 触发
  -> 跳到详情
  -> 看状态、Jenkins 引用、产物、KPI
  -> 创建成功但触发失败时可以重试触发
```

列表页看历史任务。Nginx 反代静态页和 API。Debian 上部署、进程和配置是我验收的。

Cursor 写 React 时，我给的上下文是：字段必须和 `platform-api` 已冻结的 JSON 一致，不要自己发明一套表单。联调就是拿同一 `run_id` 对页面、库、Jenkins。

**（8）AI 分析（失败摘要 / RCA）**

先定后端契约，再接实现。目标是对一次 run 能触发分析、能查结构化结果、能出适合汇报的摘要。输入是这次 run 的证据（Jenkins 日志、执行日志、KPI 摘要等），输出是摘要、分类、建议、置信度一类字段。

明确不做：AI 自动重跑 Jenkins、自动改环境、自动关缺陷、自动当发布结论。

简历上的「结论经人工复核」就落在这里：页面给辅助，人决定是否当根因。早期也可以规则 + 模板先跑通结构，再换 LLM；不要说「模型已经替代测试判断」。

### 3.5 项目一：当时一步步喂 Cursor 的例子（口语）

不必说当时原话，说意图即可：

> 先读 `platform-api` 当前 step。这一步只把创建任务写进 SQLite，返回 run_id。不要触发 Jenkins，不要改前端。按 step 模板改代码、补接口测试说明，列出我在服务器上要跑的命令和期望返回。

下一轮失败了就只贴日志：

> 我按你给的命令 POST 了，库里有记录但列表接口缺字段 XX。只修查询，不要顺手做 callback。

门户那一轮：

> 按已冻结的创建 / 触发接口做最小表单和详情。字段名必须和 schema 一致。创建后跳详情，详情要对上 run 状态和 Jenkins build。

部署那一轮：

> 在 Debian 上用 Nginx 反代。列出最小发布步骤和怎么验证 health、建 run、看详情。我来执行，你根据我贴的结果改。

### 3.6 项目一面试 3 分钟压缩版

组里跑端到端 KPI 回归时，触发、收报告、对比、翻日志是分开的。我按配置调度、任务执行、结果回收切开：页面和 FastAPI 管任务和记录，Jenkins 继续调度，回调后对页面、库、Jenkins。落地时后端先冻结接口和库，再接 Jenkins 回调和 KPI 查询，最后做 React 最小页面。每一步写成 step 给 Cursor 改代码，我在 Debian 上验收。KPI 对比和异常标注接在回收之后；失败摘要和 RCA 是辅助，人复核。编码用 Cursor，闭环是否成立我负责。

---

## 4. 项目三：Robot Framework 用例 MCP（`robotws_mcp_server`）

### 4.1 痛点（和项目一要分开）

项目一解决的是 **跑完怎么看**。项目三解决的是 **写用例时怎么不写乱**。

组里 Robot Framework 用例、resource、关键字分散在大仓库里。经验不足的人直接让 Cursor 按自然语言生成，容易：

- 抄到其他组的关键字；  
- 引用不该引用的 resource；  
- 看起来能跑、Review 时才发现风格和边界不对。

所以做成 **只读知识服务**：先扫描本组仓库，再按本组允许范围给 Cursor 提供相似用例、候选关键字和生成上下文。MCP **不代替人写可合入用例**，生成稿是参考，要人工看、走 Code Review。

### 4.2 为什么从平台仓库拆出去

单独建 `robotws_mcp_server`，不和 KPI 平台混在一个进程里。平台处理 run / Jenkins；MCP 处理仓库知识。Cursor 连的是 MCP 工具，不是去调 Jenkins。

第一版边界也写死了：

- 只读索引和上下文，**默认不调用外部大模型**（生成发生在 Cursor 里）。  
- 不在 MCP 里直接执行测试、不连设备。

### 4.3 两条演进线（面试用「先 MVP，再加厚」）

**先做能用的索引 MVP（archive 里的 Done 1–9）：**

1. 独立项目骨架、README、架构说明。  
2. 解析 Robot Framework 文件（用例、关键字、resource、library、变量、setup/teardown）和 Python 符号（不 import 执行）。  
3. 写入 SQLite：文件、用例、关键字、import、调用边、Python 符号。  
4. 用 profile 表达「本组 / 本业务线」规则，而不是一个全局大名单。  
5. 归属发现：白名单确认哪些用例进相似用例池，硬排除明确不要的路径。  
6. Context Builder + MCP 工具 + 本地 query CLI：按需求返回 profile、相似用例、推荐关键字、风格规则、骨架。  
7. 风格校验（文档、标签、setup/teardown、负向模式等）和 AI Provider 预留（默认空实现）。  
8. 本地 FastAPI Knowledge API：健康检查、取生成上下文、搜用例 / 关键字、校验风格；与 MCP / CLI 共用同一套服务。  

**再按 7 层加厚（`docs/layers/`，简历上不必一层层背）：**

```text
Layer 1 仓库扫描（官方 Robot AST + Python AST → SQLite 事实）
Layer 2 关键字 / 调用关系图
Layer 3 治理：本组范围 allow / deny / warn，并给出规则和证据
Layer 4 语义检索
Layer 5 模板抽取
Layer 6 对生成出来的 Robot 文本做静态校验（不执行）
Layer 7 执行反馈缓存（跑过的结果反过来帮检索）
```

简历三条职责对应：

- 「AST 扫描、建索引」→ Layer 1（及早期 parser + SQLite）。  
- 「按本组公共关键字范围约束」→ profile / 白名单 / Layer 3。  
- 「MCP 给 Cursor 相似用例、候选关键字、生成上下文」→ Context Builder + MCP tools；生成后可用 Layer 6 做静态检查。

通用向面试把内部业务线名字收成「本组 profile / 白名单」即可。通信向若对方懂同一套仓库，再讲到具体业务线。

### 4.4 给 Cursor 的接入方式（容易被追问）

推荐链路是：

```text
本地 Cursor
  -> 本地 stdio MCP（小客户端）
  -> HTTPS（Nginx）
  -> 服务器上的 Knowledge API
  -> 只读 SQLite 索引
```

不做成「Cursor 直接连远程 HTTP MCP」。索引构建和查询分开：定时或手工重建索引；API 只读库，不边查边全盘扫仓库。

部署文档按 Jenkins 主机构 Debian、Nginx 已有 HTTPS、Docker 常驻 API 来写。面试说「计划 / 已按这个切分部署」时，以你当时真正跑通的环境为准，不要把文档里的目标部署说成已经全公司在用。

### 4.5 项目三：当时一步步喂 Cursor 的例子（口语）

第一轮：

> 新建独立仓库，不要放进 KPI 平台。第一版只做只读扫描和 SQLite 索引，MCP 不调用 LLM。写清非目标。

解析那一轮：

> 用 Robot Framework 官方 AST 解析 .robot / .resource，用 Python AST 解析 .py。解析失败记问题，继续扫别的文件。不要执行这些 Python。

约束那一轮：

> 检索相似用例时只能走白名单范围。其他组的关键字不要进推荐列表。deny 要带上原因，方便我解释给同事。

MCP 那一轮：

> 提供取生成上下文的工具：入参是需求和 profile，出参是相似用例、候选关键字、风格规则。不要在服务端直接生成整份用例文件。

校验那一轮：

> 对 Cursor 生成的 Robot 文本做静态检查：能不能 parse、有没有引用范围外关键字。输出结构化报告，仍不执行用例。

每一层都要求：先改这一层的模块和对应 pytest，验收命令写进该 layer 文档，我跑过再做下一层。

### 4.6 项目三面试 2 分钟压缩版

写 Robot Framework 用例时，直接让 AI 生成容易串其他组关键字。我把组内仓库扫成结构化索引，用 AST 提用例、关键字和调用关系，再用本组允许范围过滤，通过 MCP 把相似用例和候选关键字交给 Cursor 当参考。服务默认不自己调大模型、不执行用例。生成稿要人看、走 Review。和项目一不是同一条链路：一个管回归怎么跑和怎么看，一个管用例怎么写得符合本组习惯。

---

## 5. 两个项目不要讲成一件事

| | 项目一 | 项目三 |
|---|---|---|
| 要减的人工 | 点 Jenkins、收报告、翻日志 | 找相似用例、避免关键字混用 |
| 主数据 | run、回调、KPI 报告、执行日志 | 仓库里的 .robot / .resource / .py |
| AI 角色 | 失败摘要 / RCA 辅助 | 给生成器用的上下文 |
| Cursor 在哪 | 写平台代码；RCA 也可能调分析 | 写 MCP 代码；写用例时当客户端 |
| 你的验收 | 页面、库、Jenkins 一致 | 索引、检索范围、生成稿只能当参考 |

若问「只能留一个 AI 项目」：日常回归价值看项目一；带新人写用例看项目三。岗位偏 CI / 平台，留一；偏 Robot 资产治理，留三。

---

## 6. 被追问时的短答

**你当时的 prompt 还记得吗？**  
不记逐句。记得每一步都有 step 文档：目标、不做、文件、验收。新会话按索引恢复，不靠聊天记录。

**那不就是 AI 做的项目？**  
模块怎么切、和 Jenkins / 用例仓库怎么接、环境上通不通，是我定义和验收的。Cursor 按当前 step 写实现。和「一句生成整个平台」不是一回事。

**会不会前端其实你不会？**  
React 不是我的主栈。页面字段跟着已冻结的 API。我负责联调：同一 run 在页面、库、Jenkins 对得上。细的状态管理框架不要按前端岗来问我。

**MCP 全组都在用吗？**  
组内辅助写作用例参考，不是全员默认生产路径。索引和约束是为了降低混用，合入仍靠人和 Code Review。

**项目一的 KPI 异常是你做的算法吗？**  
平台把报告收回来，接上对比、出图、异常标注并验收展示。不要把组内已有检测能力说成我从零发明的统计方法。

**CIT 早间自动点门户看结果也是这套吗？**  
不是。那是另一条未写进这份简历的尝试，不要主动展开。

---

## 7. 自己复习时看哪些文件（不必带去面试）

项目一：

- `jenkins_robotframework/docs/README.md`
- `docs/overview/8-day-full-project-execution-plan.md`（含新会话如何恢复、每天节奏）
- `docs/overview/four-module-boundaries-and-flow.md`
- `docs/overview/project-comprehensive-summary.md`
- `docs/modules/platform-api/index.md` 和 `steps/`
- `docs/modules/test-workflow-runner/index.md` 和 `steps/`
- `docs/modules/automation-portal/steps/step-01-robot-portal-b1-mvp.md`
- `docs/modules/platform-api/steps/step-16-ai-analysis-contract.md`

项目三：

- `robotws_mcp_server/docs/README.md`
- `docs/architecture/7-layer-architecture-spec.md`
- `docs/archive/legacy-build-steps.md`（MVP 逐步 Done 1–9）
- `docs/layers/layer-1`～`layer-7`
- `docs/robotws_mcp_project_summary_resume.md`
- `docs/deployment/server-build-steps.md`（接入方式，按实际跑通程度讲）

建议：用一个下午按「step 标题」过一遍，对着代码看调用链，能画两张草图（平台闭环、MCP 索引到 Cursor）。不必还原当年聊天。
