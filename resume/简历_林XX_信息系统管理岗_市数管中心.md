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
        <tr><td style="padding: 4px 0; border: none;"><strong>职　　称</strong>：中级工程师</td><td style="padding: 4px 0; border: none;"><strong>求职意向</strong>：信息系统管理 ｜ 杭州</td></tr>
      </tbody>
    </table>
  </div>
  <img src="1cun3.jpg" alt="证件照" style="width: 90px; height: 126px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd; margin-left: 12px;" />
</div>

<h2>专业技能</h2>
<ul>
  <li>信息化项目：具备信息系统需求拆解、模块划分、联调验收与部署验证经验，能配合相关方推进任务闭环</li>
  <li>质量与验收：12 年系统测试经验，熟悉需求分析、测试策略、用例设计、缺陷跟踪、回归管理与测试报告</li>
  <li>问题分析：可结合系统日志、抓包与业务结果区分环境、操作或系统问题，熟悉 Linux 常用命令与日志查看</li>
  <li>协同沟通：担任组内接口人，对接跨组变更与公共能力接口，具备评审、进度同步和文档说明经验</li>
  <li>结果管理：具备任务集中管理、结果回收核对与指标异常分析经验，能将执行记录沉淀为可追溯材料</li>
  <li>常用工具：熟悉 Git、Jenkins、QC、JIRA；了解 Python、FastAPI、Nginx 在内部系统中的应用</li>
  <li>专业背景：硕士专业为信号与信息处理（信息与通信工程），熟悉通信信息系统测试及版本迭代下的质量保障</li>
</ul>

<h2>工作经历</h2>
<p><strong>诺基亚</strong> ｜ 高级测试工程师 ｜ 2018.04—2026.10<br />负责 5G 基站业务线质量保障，承担需求协同、系统测试、回归管理与组内信息化工具建设。</p>
<p><strong>诺基亚</strong> ｜ 初级测试工程师 ｜ 2014.05—2018.03<br />负责 3G 媒体网关业务线测试，承担性能测试、兼容性测试及问题闭环。</p>

<h2>项目经验</h2>
<h3>项目一：组内 KPI 回归管理平台（2024—2026）</h3>
<p><strong>项目简介</strong>：面向 5G 基站 KPI 持续回归，独立推进组内信息化平台建设，实现任务集中管理、结果自动回收、指标报表对比展示与失败辅助分析，减少人工触发、手工收结果和逐条翻日志。</p>
<p><strong>技术栈</strong>：FastAPI、React、Jenkins、Python、SQLite、Nginx</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>负责需求拆解，划分配置调度、任务执行与结果回收三个模块</li>
  <li>组织页面创建任务、接口触发执行、结果回写，并与页面、数据库、执行记录核对一致</li>
  <li>对回收的 KPI 报表做汇总对比、趋势展示和异常标注，形成可查阅的分析材料</li>
  <li>汇总执行日志与 KPI 报告，形成摘要与问题分类，结论经人工复核后用于失败定位</li>
  <li>负责联调、Debian 环境部署验证与问题定位</li>
</ul>

<div class="page-two">
<h2>项目经验</h2>
<h3>项目二：5G 基站系统测试与回归管理（2019—2026）</h3>
<p><strong>项目简介</strong>：担任小组接口人，负责将已完成手工验证的功能纳入回归，覆盖载波聚合、切换、MIMO 等场景；在约 20 套测试线上维护约 200 条回归用例，支撑 4 个版本并行的每日执行与失败分析。</p>
<p><strong>技术栈</strong>：Python、Jenkins、GitLab、Linux</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>参与需求评审，评估实现路径、环境依赖与复用方式，并协调组内能力建设</li>
  <li>负责环境搭建及关键路径手工验证；回归失败时结合日志与抓包定位环境、操作或产品问题，确认后提交缺陷单</li>
  <li>维护多版本并行的每日回归，完成版本适配、失败分析与缺陷跟踪</li>
  <li>对接部门公共能力变更，完成组内用例兼容；组织组内评审，保障交付规范</li>
</ul>

<h3>项目三：组内测试知识库（2025—2026）</h3>
<p><strong>项目简介</strong>：面向组内用例编写规范，构建内部知识服务，按本组已有用例和关键字提供参考，减少跨组混用与返工。</p>
<p><strong>技术栈</strong>：Python、FastAPI、SQLite</p>
<p><strong>主要职责</strong>：</p>
<ul>
  <li>扫描组内测试仓库，建立用例、关键字与调用关系目录</li>
  <li>按本组可用范围做约束，避免引用其他组别的能力</li>
  <li>为编写人员提供相似用例和候选关键字参考，结论经人工复核</li>
</ul>

<h2>教育经历</h2>
<ul>
  <li>中国计量大学 ｜ 信号与信息处理 ｜ 硕士 ｜ 2011.09—2014.06</li>
  <li>中国计量大学 ｜ 通信工程 ｜ 本科 ｜ 2007.09—2011.06</li>
</ul>
<h2>证书</h2>
<p>英语六级 ｜ 中级工程师</p>
<h2>自我评价</h2>
<p>做事踏实，沟通配合，文字表达清楚，情绪稳定，抗压能力较好。</p>
</div>

</div>
