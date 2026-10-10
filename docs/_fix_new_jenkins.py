"""
修正 new_jekins_lightweight_fixed.md 中过时的技术描述，对齐实际 kpi-anomaly-detector 实现
恢复方案：从 new_jekins_lightweight_CORRECTED.md 读取，执行 IP 替换 + 5 项内容修正
"""

with open(r'c:\TA\docs\new_jekins_lightweight_CORRECTED.md', 'r', encoding='utf-8-sig') as f:
    content = f.read()

# 替换0：Agent IP 修正（10.57.155.152 → 10.57.159.149）
old0 = '10.57.155.152'
new0 = '10.57.159.149'
cnt0 = content.count(old0)
print(f'替换0 Agent IP (x{cnt0}): replacing...')
content = content.replace(old0, new0)
print(f'  after: {content.count(new0)} occurrences of new IP')

# ──────────────────────────────────────────────
# 替换1：3.1.1 现有功能模块描述（错误算法）
# ──────────────────────────────────────────────
old1 = """**现有功能模块**：
1. **KPI Detector**：基于机器学习的异常检测
   - 上传 Excel 数据 → 异常点识别 → 生成检测报告
   - 支持多种算法：Isolation Forest、LOF、DBSCAN
2. **KPI Generator**：性能分析报告生成
   - 处理 CSV/Excel 性能数据 → 统计分析 → 生成可视化报告
   - 支持时间序列分析、对比分析"""
new1 = """**现有功能模块**：
1. **KPI Detector（kpi-anomaly-detector）**：基于统计过程控制的异常检测
   - 上传符合命名规范的 `.xlsx` 文件 → CV 一致性 + T-Test + Shewhart SPC → 生成 HTML 趋势报告 + Excel 分析报告
   - 文件名格式：`{Date}_{Build}_{Env}_{Scenario}_{otherinfo}.xlsx`，Env 含 Txxx/Txxxx 代码
   - 历史数据按 `Env::Scenario` 分组；`is_base_file=false`（默认）排除同 Build 历史；`is_base_file=true` 保留全部历史
2. **KPI Generator（kpi-generator）**：从 Compass 生成 KPI 报告
   - 功能一：按时间戳区间从 Compass 拉取报告（1段→analysis，2-3段→compare，4+段→horizontal_merge）
   - 功能二：将 Scout 导出的 Excel 转为 Compass 格式（scout_conversion）
   - 两种模式均可开启 `auto_detector`，生成后自动提交异常检测"""

# ──────────────────────────────────────────────
# 替换2：3.2.1 目录结构（含错误的 algorithms/ML 文件）
# ──────────────────────────────────────────────
old2 = """```
kpi-portal/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI 应用入口
│   ├── config.py               # 配置管理
│   ├── database.py             # 数据库连接
│   ├── models/                 # SQLAlchemy 数据模型
│   │   ├── __init__.py
│   │   ├── kpi_job.py         # KPI 任务模型
│   │   ├── detector_result.py  # 异常检测结果
│   │   └── generator_result.py # 报告生成结果
│   ├── schemas/                # Pydantic 数据验证
│   │   ├── __init__.py
│   │   ├── kpi_job.py
│   │   ├── detector.py
│   │   └── generator.py
│   ├── api/                    # API 路由
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── detector.py     # 异常检测 API
│   │   │   ├── generator.py    # 报告生成 API
│   │   │   ├── jobs.py        # 任务管理 API
│   │   │   └── dashboard.py   # 仪表盘 API
│   │   └── deps.py             # 依赖注入
│   ├── services/               # 业务逻辑
│   │   ├── __init__.py
│   │   ├── detector_service.py # 异常检测服务
│   │   ├── generator_service.py # 报告生成服务
│   │   └── job_service.py     # 任务管理服务
│   ├── workers/                # 后台任务
│   │   ├── __init__.py
│   │   ├── detector_worker.py  # 异常检测工作器
│   │   └── generator_worker.py # 报告生成工作器
│   └── templates/              # 可选 Web UI
│       └── dashboard.html
├── data/                       # 数据存储
│   ├── kpi_results.db         # SQLite 数据库
│   ├── uploads/               # 上传文件
│   └── reports/               # 生成报告
├── algorithms/                 # KPI 算法库
│   ├── detector/
│   │   ├── isolation_forest.py
│   │   ├── lof.py
│   │   └── dbscan.py
│   └── generator/
│       ├── time_series.py
│       └── comparison.py
├── tests/                      # 单元测试
├── requirements.txt
├── Dockerfile
└── README.md
```"""
new2 = """```
kpi-portal/                        # FastAPI 服务根目录
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI 应用入口，注册 router
│   ├── config.py                  # 配置管理（DETECTOR_SCRIPTS_DIR 等路径）
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── detector.py        # 异常检测 API（文件名验证 + 子进程调用）
│   │       └── generator.py       # 报告生成 API（Compass + Scout 转换）
│   └── services/
│       ├── __init__.py
│       └── job_store.py           # 文件系统任务存储（对齐原 kpi-dashboard 设计）
├── data/
│   ├── jobs/                      # 任务数据（每个 job 一个子目录）
│   │   ├── kpi-anomaly-detector/  # Detector 任务
│   │   └── kpi-generator/         # Generator 任务
│   └── uploads/                   # 临时上传文件
├── kpi-anomaly-detector/          # 原始 detector 脚本（git clone 或 scp 部署）
│   ├── scripts/
│   │   ├── run_detector.py        # 子进程入口
│   │   └── kpi_detector/          # 核心分析包
│   │       ├── detector.py
│   │       ├── shewhart.py
│   │       ├── kpi_types.py
│   │       ├── guard_rails.py
│   │       └── ...
│   ├── data/                      # 输入 .xlsx 文件
│   └── reports/                   # 输出报告 + kpi_history_records.json
├── kpi-generator/                 # 原始 generator 脚本
│   └── kpi_generator.py           # 子进程入口
├── main.py                        # 项目启动入口
└── requirements.txt
```

> **[!] 关键设计原则**：KPI Portal 的 FastAPI 层只负责 **任务队列管理和 Web 接口**，
> 实际分析逻辑直接调用 `kpi-anomaly-detector` 和 `kpi-generator` 的**原始脚本作为子进程**，
> 不在 FastAPI 内部重新实现任何算法。"""

# ──────────────────────────────────────────────
# 替换3：3.2.2 数据模型（SQLAlchemy → 文件系统）
# ──────────────────────────────────────────────
old3 = """#### 3.2.2 核心数据模型

```python
# app/models/kpi_job.py
from sqlalchemy import Column, Integer, String, DateTime, Float, Text, Enum, JSON
from app.database import Base
import enum

class JobStatus(str, enum.Enum):
    QUEUED = "queued"
    RUNNING = "running" 
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class JobType(str, enum.Enum):
    DETECTOR = "detector"
    GENERATOR = "generator"

class KpiJob(Base):
    __tablename__ = "kpi_jobs"
    
    id = Column(Integer, primary_key=True, index=True)
    job_type = Column(Enum(JobType), nullable=False)
    status = Column(Enum(JobStatus), nullable=False, default=JobStatus.QUEUED)
    
    # 关联测试执行
    test_execution_id = Column(String(255), index=True)  # 来自 Robot 测试
    jenkins_build_number = Column(Integer)
    testline = Column(String(100), index=True)
    
    # 输入数据
    input_data = Column(JSON)  # 存储输入参数
    input_file_path = Column(String(500))
    
    # 执行信息
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    duration_seconds = Column(Float)
    
    # 结果
    result_data = Column(JSON)  # 存储分析结果
    output_file_path = Column(String(500))
    error_message = Column(Text)
    
    # 元数据
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime)
```"""
new3 = """#### 3.2.2 任务存储模型（文件系统）

KPI Portal 采用**文件系统任务存储**（对齐原 kpi-dashboard 设计），每个任务以目录形式存储，无需 SQLAlchemy/SQLite：

```
data/jobs/{module}/{job_id}/
├── meta.json          # 任务元数据（状态、参数、进度等）
├── input.xlsx         # 上传的输入文件（detector）
├── request.json       # 请求参数（generator）
├── outputs/           # 生成的报告文件
│   ├── *_trend_viewer.html
│   ├── *_analysis.xlsx
│   └── ...
├── stdout.txt         # 子进程标准输出
├── stderr.txt         # 子进程错误输出
└── result.json        # 脚本写入的最终结果
```

**meta.json 关键字段**（detector）：
```json
{
  "id": "uuid",
  "module": "kpi-anomaly-detector",
  "label": "0416.1_26R2.0126.7_T813...",
  "status": "completed",
  "original_filename": "0416.1_26R2.0126.7_T813.SCF.T813_7UEs_DL_Burst_1csv.xlsx",
  "build": "26R2.0126.7",
  "release": "26R2",
  "environment": "T813",
  "scenario": "7UEs_DL_Burst",
  "is_base_file": false,
  "report_html_path": "data/jobs/.../outputs/*_trend_viewer.html",
  "report_excel_path": "data/jobs/.../outputs/*_analysis.xlsx",
  "created_at": "2026-04-16T10:00:00Z",
  "updated_at": "2026-04-16T10:05:00Z"
}
```

**meta.json 关键字段**（generator）：
```json
{
  "id": "uuid",
  "module": "kpi-generator",
  "status": "completed",
  "job_mode": "analysis",
  "build": "26R2.0126.7",
  "environment": "T813.SCF.T813.gNB.25R3.20260224",
  "scenario": "7UEs_DL_Burst",
  "test_line": "7_5_UTE5G402T813",
  "generated_filename": "0416.1_26R2.0126.7_T813.SCF.T813_7UEs_DL_Burst_1csv.xlsx",
  "auto_detector_enabled": true,
  "detector_job_id": "another-uuid"
}
```"""

# ──────────────────────────────────────────────
# 替换4：3.2.3 API 接口设计（旧的错误版本）
# ──────────────────────────────────────────────
old4 = """#### 3.2.3 API 接口设计

```python
# app/api/v1/detector.py
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.api import deps
from app.schemas import detector as schemas
from app.services import detector_service

router = APIRouter()

@router.post("/detector/submit", response_model=schemas.DetectorJob, status_code=201)
async def submit_detector_job(
    *,
    db: Session = Depends(deps.get_db),
    file: UploadFile = File(...),
    test_execution_id: str = None,
    algorithm: str = "isolation_forest"
):
    \"\"\"
    提交异常检测任务
    \"\"\"
    job = await detector_service.submit_job(
        db=db,
        file=file,
        test_execution_id=test_execution_id,
        algorithm=algorithm
    )
    return job

@router.get("/detector/jobs", response_model=List[schemas.DetectorJob])
async def list_detector_jobs(
    *,
    db: Session = Depends(deps.get_db),
    testline: str = None,
    skip: int = 0,
    limit: int = 100
):
    \"\"\"
    查询异常检测任务列表
    \"\"\"
    jobs = detector_service.get_jobs(
        db=db, testline=testline, skip=skip, limit=limit
    )
    return jobs

@router.get("/detector/jobs/{job_id}/result")
async def get_detector_result(
    *,
    db: Session = Depends(deps.get_db),
    job_id: int
):
    \"\"\"
    获取异常检测结果
    \"\"\"
    result = detector_service.get_result(db=db, job_id=job_id)
    if not result:
        raise HTTPException(status_code=404, detail="检测结果未找到")
    return result

# 类似的，app/api/v1/generator.py 包含报告生成 API
```"""
new4 = """#### 3.2.3 API 接口设计

**Detector API**（`POST /api/v1/detector/jobs`）：

```python
# app/api/v1/detector.py
@router.post("/jobs", status_code=202)
async def submit_detector_job(
    file: UploadFile = File(...),          # 必须是 .xlsx 文件
    is_base_file: bool = Form(False),       # True=包含同Build历史；False=排除同Build历史
    override_environment: str = Form(""),   # 文件名不合规时提供 Env 覆盖
    override_scenario: str = Form(""),      # 文件名不合规时提供 Scenario 覆盖
):
    \"\"\"
    上传 .xlsx 文件提交异常检测任务（异步后台执行）。
    文件名格式：{Date}_{Build}_{Env}_{Scenario}_{otherinfo}.xlsx
    返回：{"job_id": "uuid", "status": "queued", "filename": "..."}
    后台线程调用 kpi-anomaly-detector/scripts/run_detector.py
    \"\"\"

@router.get("/jobs")
def list_detector_jobs(
    q: str = "",           # 搜索文件名
    status: str = "",      # queued/running/completed/failed
    release: str = "",     # 如 26R2
    environment: str = "", # 如 T813
    scenario: str = "",    # 如 7UEs_DL_Burst
    page: int = 1,
    page_size: int = 20,
):
    \"\"\"查询检测任务列表（支持多条件过滤）\"\"\"

@router.get("/jobs/{job_id}")
def get_detector_job(job_id: str):
    \"\"\"获取单个任务详情（含报告路径、分析状态）\"\"\"
```

**Generator API**（`POST /api/v1/generator/jobs`）：

```python
# app/api/v1/generator.py
@router.post("/jobs", status_code=202)
async def submit_generator_job(
    template_set_name: str = Form(""),      # Compass 模板集名称
    template_names: str = Form(""),          # 具体模板名（支持 ;,换行分隔）
    build: str = Form(...),
    environment: str = Form(...),            # 含 Txxx/Txxxx 的环境全称
    scenario: str = Form(...),
    report_timestamps_list: str = Form(...), # Python 列表字符串，如 [["2026-01-29 00:00:00", "2026-01-29 08:00:00"]]
    auto_detector: bool = Form(False),       # 完成后自动提交 detector
    auto_detector_is_base_file: bool = Form(False),
):
    \"\"\"
    按时间段数量自动选模式：1段→analysis | 2-3段→compare | 4+段→horizontal_merge
    后台调用 kpi-generator/kpi_generator.py
    \"\"\"

@router.post("/jobs/scout-conversion", status_code=202)
async def submit_scout_conversion(
    scout_report: UploadFile = File(...),   # Scout 导出的 .xlsx（需含 "Chart Data" Sheet）
    build: str = Form(...),
    environment: str = Form(...),
    scenario: str = Form(...),
    dist_name_filter: str = Form(...),      # DistName 过滤（如 "T813" 或 "T813;T816"）
    auto_detector: bool = Form(False),
):
    \"\"\"将 Scout 报告转换为 Compass 格式，可选自动触发异常检测\"\"\"
```"""

# ──────────────────────────────────────────────
# 替换5：Q2 算法答案（Isolation Forest/DBSCAN → CV/T-Test/Shewhart）
# ──────────────────────────────────────────────
old5 = """**Q2: KPI异常检测的算法选择和实现原理是什么？**

```
A: 采用无监督学习算法组合，解决测试数据的异常识别

1.【算法选择】：
   \u2022 Isolation Forest：处理高维数据，识别离群点
   \u2022 DBSCAN：基于密度聚类，发现异常模式
   \u2022 统计方法：3-sigma规则作为baseline

2.【特征工程】：
   \u2022 时间序列特征：吞吐量、延迟、错误率梯度变化
   \u2022 统计特征：均值、方差、分位数、峰度、偏度
   \u2022 业务特征：测试用例通过率、环境负载等

3.【实现架构】：
   FastAPI异步处理 + pandas数据处理 + scikit-learn算法引擎
   支持在线学习和模型更新

4.【准确率优化】：
   precision: 85%+, recall: 90%+, 通过历史数据验证调优
```"""
new5 = """**Q2: KPI异常检测的算法选择和实现原理是什么？**

```
A: 采用统计过程控制（SPC）方法，专为 5G NR 基站 KPI/Counter 数据设计

1.【分析流程】：
   上传 .xlsx → 文件名解析（提取 Env+Scenario） → 数据去重
   → CV 一致性分析 → T-Test 历史对比 → KPI 类型分类（10种）
   → Guard Rails 硬验证 → Shewhart SPC 控制图 → 生成 HTML+Excel 报告

2.【核心算法】：
   - CV 分析：变异系数检验当前文件内多次运行的一致性（阈值默认 5%）
   - T-Test：当前均值与历史数据（同 Env+Scenario，不同 Build）的统计显著性检验（p 值默认 0.05）
   - Shewhart SPC：8条 Western Electric 规则（±1σ/±2σ/±3σ 趋势）
   - KPI 类型策略：10 种类型（CEILING_SATURATED/FLOOR_SATURATED/COUNT_TYPE 等）采用不同策略

3.【历史数据管理】：
   历史按 Env::Scenario 分组存储（kpi_history_records.json）
   is_base_file=false（默认）：排除同 Build 历史，新旧 Build 对比
   is_base_file=true：保留全部历史（含同 Build），用于稳定性基线建立

4.【Severity 等级】：
   Normal（±2σ内）→ Suspicious（±2σ~±3σ）→ Regression（超±3σ或趋势）→ NoHistory（首次）
```"""

# ─── 执行替换 ───
replacements = [
    ("替换1 KPI模块描述", old1, new1),
    ("替换2 目录结构",   old2, new2),
    ("替换3 数据模型",   old3, new3),
    ("替换4 API接口",    old4, new4),
    ("替换5 Q2算法描述", old5, new5),
]

for name, old, new in replacements:
    cnt = content.count(old)
    if cnt == 1:
        content = content.replace(old, new)
        print(f"{name}: OK")
    elif cnt == 0:
        print(f"{name}: NOT FOUND — skipping")
    else:
        print(f"{name}: AMBIGUOUS ({cnt} matches) — skipping")

with open(r'c:\TA\docs\new_jekins_lightweight_fixed.md', 'w', encoding='utf-8-sig') as f:
    f.write(content)

# verify
with open(r'c:\TA\docs\new_jekins_lightweight_fixed.md', 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()
print(f"\nAll done. Saved {len(lines)} lines to new_jekins_lightweight_fixed.md")
