# Jenkins 与 CI/CD 测试高频面试题与回答整理

> 适用目标：自动化测试工程师、测试开发工程师、5G / 通信测试、Jenkins Pipeline、CI/CD 测试平台相关岗位。  
> 回答风格建议：先解释概念，再说明工程取舍，最后结合“Jenkins Controller / Agent、Python / Robot 测试、5G KPI、artifact、callback、AI RCA、Ansible 和灾备重建”等项目经验回答。

## 1. Jenkins 是什么？在测试平台中负责什么？

**回答：**

Jenkins 是一个可扩展的自动化服务器，常用于持续集成、持续测试和持续交付。它通过 Job、Pipeline、Agent 和插件把代码检查、构建、测试、部署及结果归档串联起来。

在测试平台中，Jenkins 更适合承担：

- 根据代码提交、定时任务或平台请求触发测试。
- 把任务调度到具备特定环境的 Agent。
- 管理 timeout、凭据、并发和资源锁。
- 展示阶段状态并归档日志、报告和 KPI 产物。
- 将执行结果 callback 到测试平台。

Jenkins 不应该承载具体的 5G KPI 业务算法。业务逻辑应放在可独立运行的 Python Executor 或 Robot Framework 中，Jenkins 只负责调度和执行编排。

## 2. CI、Continuous Testing 和 CD 有什么区别？

**回答：**

- CI（持续集成）：代码频繁合入后自动执行 lint、类型检查、单元测试、接口测试和构建。
- Continuous Testing（持续测试）：在 CI/CD 各阶段持续执行不同层次测试，例如 smoke、接口、回归、性能和真实 KPI 测试。
- Continuous Delivery：代码始终保持可发布状态，但生产部署通常需要人工批准。
- Continuous Deployment：通过质量门后自动部署到生产环境。

5G KPI 测试 Pipeline 更准确地说属于持续测试；FastAPI、Portal 和 Worker 的发布 Pipeline 才属于 CD。

## 3. Jenkins Controller 和 Agent 的职责分别是什么？

**回答：**

Controller 负责：

- 保存 Jenkins 配置和 Job。
- 接收触发请求。
- 维护队列。
- 调度 Agent。
- 展示 build history。
- 管理凭据和插件。

Agent 负责：

- checkout 代码。
- 执行 Python、Robot、pytest 和前端构建。
- 访问 TAF、gNB、UE、流量工具及 KPI 数据源。
- 生成测试日志和 artifact。

在我的 5G KPI 平台设计中，Master 上的 Controller 配置为 `0 executor`，真实设备操作只在具备测试线网络权限的 Agent 上执行。

## 4. 为什么不建议在 Jenkins Controller 上直接执行测试？

**回答：**

主要原因有：

- 测试消耗 CPU、内存和磁盘，可能影响 Jenkins 调度和 Web 页面。
- 设备凭据和测试线权限不应该放到 Controller。
- 测试依赖复杂，容易污染 Controller 环境。
- Agent 离线或测试进程异常时，不应拖垮 Controller。
- 后续增加 Agent 时更容易横向扩展。

所以 Controller 管控制面，Agent 管执行面，是更清晰的职责隔离。

## 5. Freestyle Job 和 Pipeline 有什么区别？

**回答：**

Freestyle Job 主要通过 Jenkins UI 配置步骤，适合非常简单的任务；但配置不容易评审、版本控制和跨环境恢复。

Pipeline 使用 Jenkinsfile 定义执行流程，优点是：

- 配置进入 Git。
- 可以代码评审。
- 支持 stage、并行、审批、重试和 post。
- 新 Jenkins 环境可以从仓库恢复。
- Pipeline 变更可以追踪。

真实项目优先使用 Pipeline，Freestyle 只适合临时或极简单任务。

## 6. Declarative Pipeline 和 Scripted Pipeline 有什么区别？

**回答：**

Declarative Pipeline 使用固定结构，例如 `pipeline`、`agent`、`stages`、`steps` 和 `post`，可读性和约束更强，适合大多数项目。

Scripted Pipeline 更接近原生 Groovy，灵活性更高，但复杂后容易难以维护。

我的选择是：

- 主 Jenkinsfile 使用 Declarative Pipeline。
- 少量复杂判断放进 `script`。
- 更复杂的数据处理下沉到 Python 脚本或 Shared Library。

这样可以避免 Jenkinsfile 逐渐变成难测试的业务代码。

## 7. 为什么建议把 Jenkinsfile 放进 Git？

**回答：**

Jenkinsfile 进入 Git 后可以：

- 与业务代码一起版本管理。
- 通过 Pull Request 审查。
- 追踪某次 Pipeline 变化。
- 在新 Jenkins 上通过 Pipeline SCM 重新加载。
- 回滚到已知可用版本。
- 避免只存在于 Jenkins UI 的隐藏配置。

这也是服务器被回收后能够重建 Jenkins 的基础之一。

## 8. 一个典型 Declarative Pipeline 如何设计？

**回答：**

示例：

```groovy
pipeline {
    agent none

    options {
        timestamps()
        timeout(time: 90, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    parameters {
        string(name: 'RUN_ID', description: 'Platform run id')
        string(name: 'TESTLINE', description: 'Target testline')
    }

    stages {
        stage('Checkout') {
            agent { label 'gnb-kpi && taf' }
            steps {
                checkout scm
            }
        }

        stage('Execute KPI Test') {
            agent { label 'gnb-kpi && taf' }
            steps {
                sh 'python -m gnb_kpi_executor run --request request.json'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
        }
    }
}
```

实际项目还需要资源锁、凭据注入、cleanup 和 callback。

## 9. Jenkins 中 agent、label 和 executor 分别是什么？

**回答：**

- Agent：真正执行构建和测试的节点。
- Label：Agent 的能力标签，例如 `linux`、`python`、`taf`、`gnb-kpi`。
- Executor：一个 Agent 同时可以运行多少个任务。

不能只看服务器 CPU 决定 executor 数量。真实测试可能共享 UE、gNB 和流量工具。

在第一期 5G KPI 项目中，我会把测试 Agent 设为 `1 executor`，优先保证测试线独占和结果可重复。如果 CI 排队严重，再新增不具备测试线权限的 build agent，而不是提高 KPI Agent 并发数。

## 10. Jenkins 参数、环境变量和 Credentials 有什么区别？

**回答：**

- Parameters：由触发者提供的业务输入，例如 `RUN_ID`、build、testline。
- Environment：Pipeline 内运行环境，例如 API URL、workspace 路径。
- Credentials：密码、token、SSH key 等敏感信息。

原则：

- 参数必须校验和白名单化。
- 普通配置可以使用环境变量。
- secret 必须存 Jenkins Credentials 或外部 secret store。
- 不允许用户通过参数提交任意 shell command。

## 11. Jenkins Job 有哪些常见触发方式？

**回答：**

常见方式：

- 手工触发。
- Git webhook。
- Poll SCM。
- 定时 cron。
- 上游 Job。
- Jenkins REST API。
- Multibranch Pipeline 的分支或 PR 事件。

在测试平台中，我会让 Platform API 通过 Jenkins API 触发 KPI Job，并只传 `RUN_ID` 等最小参数；Agent 再从 Platform API 获取已校验的完整执行请求。

## 12. Webhook、Poll SCM 和定时任务如何选择？

**回答：**

- Webhook：代码有变化时立即通知 Jenkins，及时且开销小，优先选择。
- Poll SCM：Jenkins 周期性检查仓库，配置简单但会产生额外请求。
- cron：适合每日回归、夜间 KPI 或周期性健康检查。

Jenkins cron 中常用 `H` 分散任务时间，例如：

```groovy
triggers {
    cron('H 2 * * *')
}
```

这样不同 Job 不会全部在同一分钟启动。

## 13. Jenkins 如何安全使用用户名、密码和 token？

**回答：**

应该把 secret 存在 Jenkins Credentials 中，通过 credential ID 注入：

```groovy
withCredentials([
    string(credentialsId: 'platform-callback-token', variable: 'CALLBACK_TOKEN')
]) {
    sh '''
        python scripts/callback.py \
          --token-env CALLBACK_TOKEN
    '''
}
```

注意：

- Jenkins 的 masking 不是绝对防泄漏。
- 不要 `echo` secret。
- 避免开启 shell debug。
- 不要把 token 放到 URL、artifact 或 callback payload。
- 不要把真实 secret 写入 JCasC、Git 或聊天记录。

## 14. `stages`、`steps` 和 `post` 分别有什么作用？

**回答：**

- `stages`：描述 Pipeline 的阶段。
- `steps`：阶段内执行的命令或 Jenkins 操作。
- `post`：根据 `always`、`success`、`failure`、`unstable` 等状态执行收尾动作。

测试 Pipeline 中，以下动作通常放在 `post { always { ... } }`：

- 停止流量和清理进程。
- 归档日志和报告。
- 上传 artifact manifest。
- callback Platform API。
- 释放外部资源。

但设备 cleanup 最好也在 Python Executor 的 `finally` 中执行，形成 Pipeline 和业务执行器双层保护。

## 15. Jenkins 中如何使用 timeout、retry 和错误处理？

**回答：**

示例：

```groovy
timeout(time: 10, unit: 'MINUTES') {
    retry(2) {
        sh 'python scripts/fetch_kpi.py'
    }
}
```

原则：

- 每个可能卡住的外部调用都要有 timeout。
- retry 只用于短暂网络失败、只读查询或明确幂等操作。
- gNB reset、流量启动和设备配置等有副作用操作不能盲目重试。
- 需要继续归档证据时，可以使用 `catchError`，但不能隐藏真正失败。

## 16. 如何保证 Pipeline 失败后仍然清理环境？

**回答：**

我会使用三层设计：

1. Python Executor 使用 `try/finally` 停止流量、清理进程并保存状态。
2. Jenkins `post { always { ... } }` 归档证据、执行兜底 cleanup 和 callback。
3. testline resource lease 带过期机制；如果设备状态不确定，则标记 `manual_check_required`，阻止后续任务直接使用。

还要区分 primary failure 和 cleanup failure，不能让清理失败覆盖最初的产品或测试失败。

## 17. `archiveArtifacts`、`stash` 和依赖缓存有什么区别？

**回答：**

- `archiveArtifacts`：保存 build 产物供下载或后续分析，例如日志、报告和 KPI 文件。
- `stash/unstash`：在同一次 Pipeline 的不同节点或 stage 间临时传递文件，不适合长期保存或超大文件。
- Cache：保存依赖下载结果，例如 pip/npm cache，用于加速后续构建。

长期制品管理可以使用 Artifactory、Nexus 或对象存储。第一期小规模项目可以先使用 Jenkins artifact，但必须设置 retention 和磁盘预警。

## 18. Jenkins 如何展示测试报告？

**回答：**

常见方式：

- pytest/JUnit XML：使用 `junit` 发布。
- Robot Framework：归档 `output.xml`、`log.html`、`report.html`，也可使用 Robot 插件。
- Allure：归档 `allure-results` 并由插件生成报告。
- HTML 报告：使用 HTML Publisher 或通过平台统一展示。

报告不仅要给人看，还应保留结构化结果，供 Platform API、趋势分析和 RCA Worker 使用。

## 19. Jenkins 中如何做并行测试？

**回答：**

可以使用 Declarative `parallel` 或 matrix：

```groovy
stage('Tests') {
    parallel {
        stage('API') {
            steps {
                sh 'pytest tests/api'
            }
        }
        stage('Contract') {
            steps {
                sh 'pytest tests/contracts'
            }
        }
    }
}
```

适合并行：

- 无共享状态的单元测试。
- 不同浏览器测试。
- 不同独立环境。

不适合直接并行：

- 共用同一个 UE。
- 共用同一 testline。
- 同时修改同一个 gNB/cell。
- 同时写同一个 KPI 输出目录。

并行前要先分析资源冲突，而不是只为了缩短时间。

## 20. 如何防止多个 Job 同时占用同一测试线？

**回答：**

可以使用 Jenkins Lockable Resources：

```groovy
lock(resource: "testline-${params.TESTLINE}") {
    sh 'python -m gnb_kpi_executor run --request request.json'
}
```

还可以在 Platform API 中保存带 lease 的资源状态，用于 Portal 展示和异常恢复。

两层职责不同：

- Jenkins lock 是实际调度锁。
- PostgreSQL lease 是平台状态、超时和人工恢复依据。

只使用本地文件锁不可靠，因为 Agent 重启或 workspace 被清理后锁信息会丢失。

## 21. CI/CD 中应该如何设计测试分层？

**回答：**

典型分层：

1. 静态检查：format、lint、type、secret scan。
2. 单元测试：函数、service、规则和状态机。
3. Contract 测试：API、callback、artifact manifest。
4. 集成测试：PostgreSQL、Jenkins adapter、外部 provider。
5. 组件测试：FastAPI、Worker、Executor。
6. E2E：Portal -> API -> Jenkins -> Agent -> callback。
7. 真实 Lab：UE attach、DL 流量、KPI。
8. 发布后 smoke 和灾备恢复测试。

越靠近真实设备，成本越高、数量应越少；底层自动测试应快速且数量更多。

## 22. Smoke、Regression 和 Full Regression 有什么区别？

**回答：**

- Smoke：少量关键链路，确认版本和环境基本可用。
- Regression：针对当前改动和主要风险选择回归范围。
- Full Regression：覆盖完整功能和主要配置组合，通常耗时较长。

常见策略：

- PR：lint、unit、contract、API smoke。
- main：增加 integration 和 Portal build。
- 发布前：关键 E2E。
- 夜间或版本节点：真实 KPI regression。

不要让每次代码提交都运行数小时的真实测试线用例。

## 23. 如何处理 flaky test？

**回答：**

Flaky test 是在代码和环境未变化时结果不稳定的测试。

处理步骤：

1. 记录失败频率、Agent、时间和环境。
2. 区分产品、脚本、数据、网络和设备原因。
3. 保存日志、截图、KPI window 和环境快照。
4. 修复不可靠等待、共享状态和清理问题。
5. 必要时隔离，但不能长期用自动重试掩盖。

重试结果也要保留第一次失败证据。测试最终通过不代表第一次失败可以忽略。

## 24. 什么是 Quality Gate？如何设计？

**回答：**

Quality Gate 是进入下一阶段前必须满足的质量条件，例如：

- lint/type 通过。
- 单元和 contract 测试通过。
- 覆盖率不低于项目基线。
- 没有高危 secret 或安全问题。
- migration 校验通过。
- Portal production build 成功。
- 关键 smoke 通过。

Quality Gate 应与风险匹配，不能只追求指标。比如真实 KPI 异常是业务质量门，而不是普通单元测试覆盖率能替代的。

## 25. 什么是 “Thin Pipeline, Thick Python”？

**回答：**

它表示 Jenkinsfile 只负责：

- Agent 和 label。
- stage。
- timeout。
- credentials。
- resource lock。
- archive。
- post/callback。

Python 负责：

- 参数校验。
- TAF/gNB/UE 操作。
- 流量。
- KPI window。
- KPI 采集和异常分析。
- 结构化 result。

优点是 Python 可以本地运行、单元测试和复用，也降低对 Jenkins 的绑定。如果将来换成 GitLab CI，核心 KPI Executor 不需要重写。

## 26. 如何设计一条真实的 5G KPI Jenkins Pipeline？

**回答：**

建议阶段：

```text
Checkout
-> Fetch Validated Request
-> Lock Testline
-> Environment Precheck
-> Prepare UE / gNB
-> UE Attach
-> Start DL Traffic
-> Record KPI Window
-> Collect KPI
-> Analyze KPI
-> Cleanup
-> Archive Artifacts
-> Callback
-> Queue RCA
```

关键点：

- 完整参数从 Platform API 获取，不允许任意命令。
- 所有外部动作有 timeout。
- testline 独占。
- KPI window 只覆盖有效业务时间。
- 无论成功失败都 cleanup、archive 和 callback。
- 流量失败、KPI 采集失败和 KPI 性能异常必须分类处理。

## 27. Jenkins 与测试平台之间为什么需要 callback？

**回答：**

Jenkins 擅长调度和执行，但平台还需要统一保存：

- run 状态。
- stage timeline。
- artifact descriptor。
- KPI summary。
- anomaly。
- RCA revision。

所以 Agent 执行后通过 callback 回写 Platform API。

Callback 应具备：

- `run_id`。
- 唯一 `callback_event_id`。
- 状态机校验。
- service token。
- timeout 和受控重试。
- 幂等处理。

重复 callback 不应重复写入，乱序 callback 不能把终态改回 running。

## 28. 平台代码的 CI Pipeline 应包含哪些阶段？

**回答：**

建议：

```text
Checkout
-> Changed Component Detection
-> Python Lint / Type
-> Python Unit / Contract Tests
-> PostgreSQL Migration Check
-> Portal Lint / Type / Build
-> Secret Scan
-> Package
-> Archive Test and Release Manifest
```

CI 只生成可发布制品，不直接修改服务器。

输出应包含：

- 测试报告。
- coverage。
- frontend dist。
- Python package 或版本化源码包。
- migration manifest。
- dependency manifest。
- git commit 和 release version。

## 29. 平台 CD Pipeline 应包含哪些阶段？

**回答：**

建议：

```text
Verify CI Artifact
-> Manual Approval
-> Host Precheck
-> Backup
-> Database Migration
-> Deploy API / Worker / Portal
-> Validate Nginx / systemd
-> Restart Changed Services
-> Smoke
-> Record Deployment Event
-> Rollback on Failure
```

原则：

- 只部署 CI 已验证的制品。
- migration 前备份。
- 只重启受影响服务。
- Nginx 先检查再 reload。
- smoke 失败立即停止并进入回滚。
- 所有发布和回滚都保存证据。

## 30. 什么是 “Build Once, Deploy Many”？

**回答：**

表示同一个经过 CI 验证的不可变制品依次部署到测试、预发布和生产环境，而不是每个环境重新构建。

好处：

- 避免不同环境构建出不同内容。
- 可以追踪制品版本和 hash。
- 回滚时能准确使用上一版本。
- 测试结论与最终发布内容一致。

不同环境只注入配置和 secret，不重新修改制品内容。

## 31. 常见发布策略有哪些？

**回答：**

- Rolling：逐步替换实例，适合多实例服务。
- Blue-Green：蓝绿两套完整环境，验证后切换流量，回滚快。
- Canary：先给少量流量使用新版本。
- Recreate：停止旧版本后启动新版本，最简单但有短暂停机。

当前双服务器、单实例平台第一期更适合：

- 版本化 release 目录。
- 更新 `current` 指向。
- health/smoke。
- 失败切回上一版本。

不需要为了简历展示强行引入 Kubernetes 蓝绿发布。

## 32. 如何设计回滚？

**回答：**

回滚要在发布前设计，而不是失败后临时想。

分层处理：

1. Portal：切回前一版静态 dist。
2. API/Worker：切回前一版 release artifact。
3. Nginx/systemd：恢复前一版配置。
4. 数据库：根据 migration 是否支持 downgrade 决定。
5. 严重情况：从经过验证的备份恢复。

数据库不能默认自动回滚。破坏性 schema 变化应使用 expand -> migrate -> contract，避免一次发布同时删除旧字段。

## 33. 数据库 migration 在 CI/CD 中要注意什么？

**回答：**

- migration 文件必须进入 Git。
- CI 校验 migration 是否完整。
- 发布前检查当前 revision。
- migration 前备份。
- migration 失败时停止发布。
- 明确是否支持 downgrade。
- API 新旧版本与 schema 应有兼容窗口。

PostgreSQL backup 不能只确认文件存在，还要定期恢复到隔离数据库并查询关键表。

## 34. 不同环境的配置和 secret 如何管理？

**回答：**

建议：

- 非敏感默认配置进入 Git。
- 环境差异放 Ansible inventory、环境变量或受控配置文件。
- secret 放 Jenkins Credentials、Vault 或 root-readable secret file。
- Portal 的 `VITE_*` 属于 build-time 配置，变化后需要重新 build。
- API/Worker secret 不写进镜像、日志和 artifact。

不能把测试、预发布和生产的 `.env` 直接提交到 Git。

## 35. JCasC、Job DSL 和 Pipeline SCM 分别解决什么问题？

**回答：**

- JCasC：配置 Jenkins Controller、Agent、全局设置和 credential ID 引用。
- Job DSL：通过 Seed Job 创建和更新 Job 结构。
- Pipeline SCM：Job 从 Git 读取 Jenkinsfile。

简单理解：

```text
JCasC 管 Jenkins
Job DSL 管 Job
Jenkinsfile 管执行流程
```

三者结合后，新的 Jenkins Controller 不需要在 UI 中逐项手工恢复。

## 36. Jenkins Shared Library 适合解决什么问题？

**回答：**

Shared Library 适合多个 Jenkinsfile 共享稳定的 Pipeline 逻辑，例如：

- 统一 checkout。
- 统一 Python 环境准备。
- 统一 callback。
- 统一 artifact 归档。
- 统一通知。

但不要把所有业务逻辑都塞入 Shared Library。5G KPI 的 TAF、流量和分析逻辑仍应在 Python package 中。

第一期 Job 数量较少时，可以先保持 Jenkinsfile 清晰；真正出现重复后再抽 Shared Library。

## 37. Jenkins 插件和安全如何管理？

**回答：**

插件风险包括版本不兼容、安全漏洞和服务器重建后版本漂移。

建议：

- 固定 Jenkins core、Java 和插件版本。
- 保存 `plugins.txt` 或 plugin catalog。
- 定期评估安全公告。
- 删除不再使用的插件。
- 最小化管理员权限。
- Jenkins 8080 不直接暴露，通过 Nginx HTTPS 访问。
- Controller 不执行构建。
- Agent 使用专用低权限账号。
- Seed Job、JCasC 和生产发布需要受控权限。

升级前先备份，并在隔离环境验证插件兼容性。

## 38. Jenkins Agent 离线或任务一直排队，如何排查？

**回答：**

Agent 离线按顺序检查：

1. Agent 主机是否开机、网络是否可达。
2. SSH/WebSocket 连接方式是否正常。
3. Java 版本是否兼容。
4. SSH key、用户和文件权限。
5. Jenkins Remoting 日志。
6. Agent 磁盘、内存和 workspace。

任务排队检查：

- label 是否匹配。
- Agent 是否 online。
- executor 是否为 0 或已占满。
- 是否等待 Lockable Resource。
- 是否处于 quiet down。
- 上游依赖或人工 approval 是否未完成。

先找第一个阻塞层，不要一上来就重启 Jenkins。

## 39. Pipeline 失败时如何系统定位？

**回答：**

我会先确定第一个失败 stage，再按层分类：

- SCM：分支、credential、网络。
- Dependency：Python/npm/内部源。
- Build：编译、类型检查、Portal build。
- Test：脚本失败、产品失败、环境失败。
- Agent：离线、磁盘、Java、权限。
- Deployment：migration、systemd、Nginx。
- Callback：401、timeout、API 状态机。
- KPI：流量、采集、数据质量、指标异常。

诊断证据包括：

- Jenkins console。
- stage timeline。
- environment/version manifest。
- service status。
- TAF/traffic 日志。
- KPI summary。
- callback payload/result。

不能只看 console 最后一行，因为它通常只是最终异常，不一定是根因。

## 40. Jenkins、GitHub Actions 和 GitLab CI 如何选择？为什么你的项目用 Jenkins？

**回答：**

- GitHub Actions：适合 GitHub 生态和云端 CI，自托管 Runner 也能访问内网。
- GitLab CI：GitLab、Runner、Pipeline 和 `resource_group` 集成较完整。
- Jenkins：部署灵活、插件丰富、适合私有网络、长时间任务、硬件 Agent 和测试线资源锁。

Jenkins 不是 KPI Executor 的必要依赖，但它很适合当前项目：

- Agent 能访问内部 TAF、gNB、UE 和 KPI 源。
- 测试时间长，需要 timeout、队列和 artifact。
- testline 需要独占锁。
- 支持手工、定时和 API 触发。
- 团队已有 Jenkins 自动回归经验。

为了避免绑定，Python KPI Executor 可以独立 CLI 运行，Platform API 通过通用 Dispatcher 调用 Jenkins。未来更换 GitLab CI 时不重写核心测试逻辑。

## 41. Jenkins 环境如何做到可重建和迁移？

**回答：**

单独写一个 Cursor Skill 不足以保证迁移。可靠方案是：

```text
Ansible
  + JCasC
  + Job DSL
  + Pipeline SCM
  + 插件版本清单
  + PostgreSQL / Artifact 备份
  + Secret Inventory
  + 项目级 Lifecycle Skill
```

其中：

- Ansible 执行确定性的服务器安装和配置。
- Jenkins as Code 恢复 Jenkins 和 Job。
- 外部备份恢复平台状态和历史数据。
- Skill 判断首次安装、迁移或灾备模式，生成执行计划、检查项和验证步骤。

可以实现少量停机、可重复重建，但单 Controller 不能保证真正零停机，也不能迁移正在运行的 Job。

## 42. 如果面试官问：你在 Jenkins 和 CI/CD 上最有价值的经验是什么？

**推荐回答：**

我在 Jenkins 上的经验不只是创建一个 Job，而是把自动化测试做成完整闭环：

1. 设计 Controller / Agent 隔离，真实 5G 测试只在具备 TAF 和测试线权限的 Agent 执行。
2. 使用 Pipeline 把 checkout、环境检查、Python / Robot 执行、KPI 后处理、artifact 和 callback 串起来。
3. 通过 testline 资源锁、timeout、finally cleanup 和幂等 callback 保证长时间测试的可靠性。
4. 使用 JCasC、Job DSL、Pipeline SCM 和 Ansible 设计可恢复部署，避免服务器更换后手工重建。
5. 将 Jenkins console、测试日志和 KPI evidence 交给 RCA Worker，生成结构化故障分析和报告。

这样 Jenkins 是自动化测试平台中的调度与证据中心，而不是一个只能手工点击执行脚本的工具。

## 结合当前简历的 Jenkins / CI/CD 面试表达总结

### 你的简历相关亮点

- 具备 Jenkins Controller / Agent 分布式执行经验。
- 长期支撑 5G CIT / CRT / KPI 自动回归。
- 能将 Robot Framework、Python / TAF 和 Jenkins Pipeline 集成。
- 理解参数、凭据、artifact、callback、资源锁和失败清理。
- 具备 FastAPI + PostgreSQL + Jenkins + Agent 的测试平台设计能力。
- 了解 JCasC、Job DSL、Pipeline SCM 和 Ansible 可恢复部署。
- 能结合 Jenkins console、设备日志和 KPI 结果进行分层 RCA。

### 面试时可以这样概括

> 我使用 Jenkins 主要是建设 5G 自动化回归和 KPI 测试闭环。架构上由 Controller 负责任务调度，专用 Agent 访问 TAF、gNB、UE 和 KPI 数据源；Pipeline 负责 checkout、资源锁、timeout、凭据、执行阶段、artifact 和 callback，真实业务逻辑放在可独立运行的 Python Executor 或 Robot Framework 中。平台通过 FastAPI 和 PostgreSQL 管理 run、stage、KPI 及 RCA，失败后仍会执行 cleanup、归档证据并回写状态。部署侧使用 JCasC、Job DSL、Pipeline SCM 和 Ansible，使 Jenkins 与平台能够在新服务器上重建。

### 建议重点准备的个人案例

1. 一个 Jenkins Agent offline 或 label 不匹配导致任务排队的排查案例。
2. 一个 Robot/Python 测试失败后仍完成 cleanup、artifact 和 callback 的案例。
3. 一个 testline 或 UE 资源冲突，通过锁和串行策略解决的案例。
4. 一个 Jenkins console、TAF 日志和 KPI summary 联合定位问题的案例。
5. 一个 JCasC、Job DSL、Pipeline SCM 分工设计的案例。
6. 一个服务器被回收后，如何通过 Ansible、备份和 Jenkins as Code 重建的案例。

### 面试回答模板

遇到 Jenkins / CI/CD 问题，可以按以下顺序回答：

```text
1. 先解释 Jenkins 或 CI/CD 概念。
2. 再说明 Pipeline 中如何落地。
3. 补充可靠性、安全或恢复方面的考虑。
4. 最后结合一个 5G 自动化测试场景。
```

示例：

> 比如 Jenkins 并行执行，概念上可以使用 parallel stage，但在 5G 测试中不能直接把所有用例并行，因为 UE、gNB 和 testline 可能是共享资源。我的做法是先分析资源维度：无共享状态的 API 和数据检查可以并行，真实 UE 或流量测试通过 Lockable Resources 串行；同时 Python Executor 使用资源标识和 finally cleanup，避免任务失败后污染下一次测试。
