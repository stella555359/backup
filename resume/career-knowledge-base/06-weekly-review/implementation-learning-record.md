# 知识库落地学习记录

## 本步解决的问题

把“两个月求职准备计划”从抽象计划落地为实际 Markdown 知识库目录，后续可以持续写项目复盘、技能地图、AI 测试 Demo、面试题库和周复盘。

## 文件变化与原因

- `career-knowledge-base/README.md`：作为知识库总入口。
- `templates/`：统一项目、知识点、面试回答和周复盘写法。
- `00-career-map/`：沉淀个人定位、求职方向和证据链。
- `01-projects/`：沉淀 4 个可面试项目复盘。
- `02-skills/`：建立自动化测试、平台工程和 AI 测试技能地图。
- `03-ai-testing/`：规划两周 AI 测试 Demo 和学习路线。
- `04-interview-bank/`：沉淀项目深挖、技术题和 STAR 案例。
- `05-job-targets/`：区分自动化测试、AI 测试和平台测试简历表达。
- `06-weekly-review/`：记录两个月节奏和每周复盘。

## 核心调用流

```text
个人经历 / 简历 / 项目文档
-> career map 提炼定位
-> projects 沉淀项目资产
-> skills 映射岗位能力
-> ai-testing 补强新方向
-> interview-bank 转成面试回答
-> job-targets 调整简历版本
-> weekly-review 每周复盘迭代
```

## 关键字段和存放位置

- 求职定位：`00-career-map/personal-positioning-and-evidence-map.md`
- 项目证据链：`01-projects/*.md`
- 技能差距：`02-skills/*skill-map*.md`
- AI Demo 评测字段：`03-ai-testing/two-week-ai-testing-demo-plan.md`
- 面试题回答：`04-interview-bank/*.md`
- 两个月节奏：`06-weekly-review/two-month-weekly-plan.md`

## 验证命令

本次是本地 Markdown 知识库整理，不需要服务器验证。建议在本地由用户执行：

```powershell
cd C:\TA\resume
Get-ChildItem -Recurse career-knowledge-base -File | Select-Object FullName
```

预期结果：能看到 `README.md`、`templates`、`00-career-map` 到 `06-weekly-review` 下的 Markdown 文件。

可选检查：

```powershell
cd C:\TA\resume
Get-Content career-knowledge-base\README.md -TotalCount 20
```

预期结果：能看到“个人求职知识库”和目录导航。

## 常见失败模式

- 如果 `career-knowledge-base` 不存在，说明目录没有创建成功。
- 如果 Markdown 显示乱码，检查编辑器是否按 UTF-8 打开。
- 如果链接路径不可点击，优先确认文件实际路径和大小写。
- 如果内容过多不好维护，先从 `README.md`、`00-career-map`、`01-projects` 三处开始使用。

## 用户复核问题

- 三个求职方向排序是否符合当前投递目标？
- AI 测试 Demo 是否优先做 RAG 知识库，而不是数据 Dashboard？
- 项目复盘中的职责描述是否需要进一步贴近真实工作细节？
- 是否需要下一步把某个项目扩写成完整 8 分钟面试稿？

---

# 5G KPI AI Explainer 调整记录

## 本步解决的问题

把 AI Testing 作品从通用 RAG 知识库调整为更贴近现有工作的 `5G gNB KPI 异常解释助手`。这个方向能复用现有 KPI 自动化回归链路，让 AI 能力服务于真实测试流程：解释 detector 发现的异常、总结证据、生成排查建议，并通过评测样例和人工复核控制幻觉。

## 文件变化与原因

- `03-ai-testing/README.md`：将 AI Testing 主线改为 KPI 异常解释助手。
- `03-ai-testing/two-week-ai-testing-demo-plan.md`：替换通用 RAG 两周计划，改为 KPI Explainer 两周落地计划。
- `03-ai-testing/5g-kpi-anomaly-explainer.md`：新增 Demo 主文档，说明定位、链路、输入输出和面试讲法。
- `03-ai-testing/kpi-explainer-contract.md`：新增 `kpi_explainer_input.json` 和 Markdown 报告输出合同。
- `03-ai-testing/kpi-explainer-eval-cases.md`：新增 10 条 KPI 异常解释评测样例和人工复核标准。
- `02-skills/ai-testing-skill-map-and-gap.md`：把技能地图从 RAG 主线改为 KPI 异常解释、输出约束和评测集。
- `04-interview-bank/technical-questions.md`：补充 KPI AI Explainer 技术问答。
- `01-projects/5g-gnb-kpi-automation-platform.md`：把 AI Explainer 纳入主项目后处理增强能力。
- `06-weekly-review/two-month-weekly-plan.md`：把第 5-6 周产出改成 KPI Explainer 合同、样例和报告。

## 核心调用流

```text
automation-portal
-> platform-api
-> Jenkins KPI Runner
-> Python runner
-> kpi_generator
-> kpi_detector
-> KPI AI Explainer
-> Markdown 异常解释报告
-> 人工复核和面试作品材料
```

## 关键字段和存放位置

- 输入合同：`03-ai-testing/kpi-explainer-contract.md`
- Demo 主文档：`03-ai-testing/5g-kpi-anomaly-explainer.md`
- 评测样例：`03-ai-testing/kpi-explainer-eval-cases.md`
- 两周计划：`03-ai-testing/two-week-ai-testing-demo-plan.md`
- 面试问答：`04-interview-bank/technical-questions.md`
- 主项目表达：`01-projects/5g-gnb-kpi-automation-platform.md`

## 验证命令

本次是本地 Markdown 知识库调整，不需要服务器验证。建议在本地由用户执行：

```powershell
cd C:\TA\resume
Get-Content career-knowledge-base\03-ai-testing\5g-kpi-anomaly-explainer.md -TotalCount 40
```

预期结果：能看到 `5G gNB KPI 异常解释助手` 的定位、系统位置、输入材料和面试讲法。

可选检查：

```powershell
cd C:\TA\resume
Get-Content career-knowledge-base\03-ai-testing\kpi-explainer-eval-cases.md -TotalCount 80
```

预期结果：能看到 10 条 KPI 异常解释评测样例和人工复核标准。

## 常见失败模式

- 如果仍看到“高校制度知识库 RAG”作为主线，说明旧文档没有完全替换。
- 如果 AI 输出写成确定 root cause，说明 prompt 约束不足，应改为“可能原因 + 需要确认”。
- 如果解释没有引用 detector summary、KPI 类型、history 或 scenario，说明输入合同不够结构化。
- 如果 Demo 变得太大，先只做离线 Markdown 报告，不做前端页面或完整 Agent。

## 用户复核问题

- KPI AI Explainer 是否作为两个月 AI Testing 主作品？
- 第一批样例是否优先围绕 throughput、accessibility、mobility、latency、stability 五类 KPI？
- 面试时是否强调“AI 不替代 detector，只解释 detector 输出”这条边界？
- 后续是否需要把它进一步实现成脚本或 portal 页面原型？