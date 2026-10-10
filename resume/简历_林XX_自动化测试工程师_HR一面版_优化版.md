<style>
@page { size: A4; margin: 12mm; }
html, body {
  margin: 0 !important;
  padding: 0 !important;
  height: auto !important;
}
html, body, div, p, ul, ol, li, h1, h2, h3, h4, table, td, th, strong, em, span, a {
  font-family: "Microsoft YaHei", "微软雅黑" !important;
}
body {
  font-size: 13px;
  line-height: 1.5;
  color: #222;
}
h1, h2, h3 {
  break-before: auto !important;
  page-break-before: auto !important;
}
h2 {
  font-size: 14px !important;
  font-weight: 700;
  letter-spacing: 1px;
  background: #A6A6A6;
  color: #1a1a1a;
  padding: 5px 12px;
  margin: 10px 0 7px 0;
  -webkit-print-color-adjust: exact;
  print-color-adjust: exact;
}
h3 {
  font-size: 13.5px !important;
  font-weight: 700;
  color: #222;
  margin: 8px 0 6px 0;
  padding: 0;
  border: none;
}
p { margin: 5px 0; }
ul {
  margin: 3px 0 2px 1.2em;
  padding-left: 1.2em;
}
li { margin: 4px 0; }
.page-two {
  break-before: page !important;
  page-break-before: always !important;
  font-size: 13.5px;
  line-height: 1.62;
}
.page-two h2 { margin: 12px 0 8px 0; }
.page-two h3 { margin: 12px 0 8px 0; }
.page-two p { margin: 6px 0; }
.page-two li { margin: 6px 0; }
</style>
<div style="font-family: 'Microsoft YaHei', '微软雅黑'; font-size: 13px; line-height: 1.5; color: #222;">

<p style="text-align: center; font-size: 20px; font-weight: 600; letter-spacing: 8px; margin: 0 0 8px 0; color: #1a1a1a;">个人简历</p>

<h2>基本信息</h2>
<div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 20px;">
  <div style="flex: 1;">
    <table style="width: 100%; border-collapse: collapse; line-height: 1.7; border: none;">
      <tbody>
        <tr><td style="width: 50%; padding: 4px 0; border: none;"><strong>姓　　名</strong>：林 贞</td><td style="width: 50%; padding: 4px 0; border: none;"><strong>学　　历</strong>：硕士</td></tr>
        <tr><td style="padding: 4px 0; border: none;"><strong>移动电话</strong>：15858285359</td><td style="padding: 4px 0; border: none;"><strong>电子邮件</strong>：15858285359@163.com</td></tr>
        <tr><td style="padding: 4px 0; border: none;"><strong>工作年限</strong>：12 年</td><td style="padding: 4px 0; border: none;"><strong>现　　居</strong>：杭州</td></tr>
        <tr><td style="padding: 4px 0; border: none;" colspan="2"><strong>求职意向</strong>：自动化测试工程师 ｜ 杭州</td></tr>
      </tbody>
    </table>
  </div>
  <img src="1cun3.jpg" alt="证件照" style="width: 90px; height: 126px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd; margin-left: 12px;" />
</div>

<h2>专业技能</h2>
<ul>
  <li>自动化框架：精通 Robot Framework、Python，具备公共关键字规划与封装、新 Feature 自动化可行性分析、用例开发及多 release 适配能力，覆盖 CIT、CRT、CDRT 等分级回归</li>
  <li>自动化平台：独立完成基于 FastAPI、React、Nginx 的测试平台需求拆解、模块划分与闭环设计，借助 AI 完成编码落地，并负责联调与验收</li>
  <li>持续集成：熟悉 Jenkins 自动回归，具备 CIT、CRT、CDRT 分级回归的执行、监控与失败分析经验</li>
  <li>AI 辅助测试：基于失败日志完成摘要与根因分类（RCA），并开发 MCP 服务辅助用例编写</li>
  <li>熟练使用 Git 进行版本管理与 Code Review，具备公共测试库接口对接与用例兼容适配经验</li>
  <li>熟悉 5G NR 空口及 L1、L2、L3 信令，可结合 Wireshark、系统日志等分层定位问题，具备系统功能测试和性能测试经验</li>
  <li>熟悉 Linux 常用命令与日志查看；熟悉 QC、JIRA 等测试常用工具</li>
</ul>

<h2>工作经历</h2>
<p><strong>诺基亚</strong> ｜ 高级测试工程师 ｜ 2018.04—2026.10<br />负责 5G 基站业务线测试，承担自动化用例实现与 CIT、CRT 日常回归。</p>
<p><strong>诺基亚</strong> ｜ 初级测试工程师 ｜ 2014.05—2018.03<br />负责 3G 媒体网关业务线测试，承担性能测试与兼容性测试。</p>

<h2>项目经验</h2>
<h3>项目一：5G gNB E2E KPI Benchmark 自动化回归测试平台（2024—2026）</h3>
<p><strong>项目简介</strong>：面向 T-Mobile 5G 基站 E2E 性能指标（KPI）的持续回归与基线对比，独立推进组内自动化测试平台建设，实现任务集中管理、结果回收、KPI 报告对比出图与 AI 辅助失败分析，减少人工触发、手工收结果和逐条翻日志的工作量。</p>
<p><strong>技术栈</strong>：FastAPI、React、Jenkins、Python、SQLite、AI Analysis、Nginx</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>负责拆解平台需求，划分配置调度、任务执行与结果回收三个模块</li>
  <li>通过 React 页面创建 KPI 任务，经 FastAPI 接口触发 Jenkins 调度，结果回调回写后与页面、数据库、Jenkins 记录核对一致</li>
  <li>对回收的 KPI 报告做历史对比、趋势展示和异常标注，辅助判断本次回归是否劣化</li>
  <li>基于 Jenkins 日志、Python 执行日志与 KPI 报告生成日志摘要、根因分类（RCA）与修复建议，结论经人工复核</li>
  <li>以 Cursor 辅助完成各模块编码落地，并负责联调、Debian 部署验证与问题定位</li>
</ul>

<div class="page-two">
<h2>项目经验</h2>
<h3>项目二：5G gNB Feature 自动化用例开发与 CIT、CRT 回归（2019—2026）</h3>
<p><strong>项目简介</strong>：担任小组自动化接口人，负责将 5G 基站已完成手工测试的 Feature 转化为自动化用例，覆盖载波聚合、切换、MIMO 等场景，同时在约 20 套 5G 基站测试线上维护约 200 条 CIT、CRT 等回归用例，支撑 4 个 release 并行的 CIT 每日执行与失败分析。</p>
<p><strong>技术栈</strong>：Robot Framework、Python、TAF、Jenkins、GitLab</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>负责新 Feature 自动化可行性分析，评估实现路径、环境依赖与复用方式，并规划公共关键字开发</li>
  <li>以 Python 封装组内公共关键字，以 Robot Framework 开发并执行 Feature 用例，覆盖 CIT、CRT、CDRT 等分级回归</li>
  <li>负责组内自动化 Code Review，对接部门公共测试库（TAF）接口变更，完成组内关键字与用例兼容适配</li>
  <li>将自动化代码提交至部门 GitLab，在现有 Jenkins CI 上维护多 release 并行的 CIT、CRT、CDRT 每日回归，完成各版本用例适配、失败分析与缺陷跟踪</li>
  <li>自动化开发前完成环境搭建及待自动化用例的手工验证；CIT、CRT、CDRT 失败时结合抓包与日志定位环境、脚本或产品问题，确认缺陷后提交 Pronto</li>
</ul>

<h3>项目三：组内 Robot Framework 用例 MCP 知识服务（2025—2026）</h3>
<p><strong>项目简介</strong>：面向组内 Robot Framework 用例编写，构建 MCP 知识服务，使用例编写经验不足的组员可通过 Cursor 生成符合本组风格的用例参考，避免公共关键字混用与调试困难。</p>
<p><strong>技术栈</strong>：Python、FastAPI、MCP、SQLite、Robot Framework</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>基于 Robot Framework、Python AST 扫描组内测试仓库，构建用例、关键字、resource 与调用关系索引</li>
  <li>按本组可用的公共关键字范围做约束，避免引用其他 site 或其他组的关键字</li>
  <li>通过 MCP 向 Cursor 提供相似用例、候选关键字和生成上下文，辅助产出符合本组风格的 Robot Framework 用例参考</li>
</ul>

<h2>教育经历</h2>
<ul>
  <li>中国计量大学 ｜ 信号与信息处理 ｜ 硕士 ｜ 2011.09—2014.06</li>
  <li>中国计量大学 ｜ 通信工程 ｜ 本科 ｜ 2007.09—2011.06</li>
</ul>
<h2>证书</h2>
<p>英语六级 ｜ 中级工程师</p>
<h2>自我评价</h2>
<p>善良，真诚，情绪稳定，抗压能力好，不内耗。</p>
</div>

</div>
