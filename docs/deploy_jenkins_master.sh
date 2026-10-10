#!/bin/bash
################################################################################
# Jenkins Master + Reporting Portal 自动部署脚本
# 目标服务器: 10.71.210.104 (Debian GNU/Linux 13)
# 功能: 一键部署 Jenkins Master 和 Reporting Portal
# 作者: GitHub Copilot
# 日期: 2026-04-14
################################################################################

set -e  # 遇到错误立即退出
set -u  # 使用未定义变量时报错

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 检查是否以 root 运行
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "请使用 root 权限运行此脚本"
        log_info "使用命令: sudo bash $0"
        exit 1
    fi
}

# 配置变量
MASTER_IP="10.71.210.104"
AGENT1_IP="10.57.155.152"
AGENT2_IP="10.57.177.88"
TESTLINE1="7_5_UTE5G402T813"
TESTLINE2="7_5_UTE5G402T080"

JENKINS_PORT=8080
REPORTING_PORTAL_PORT=8000

INSTALL_DIR="/opt"
REPORTING_PORTAL_DIR="${INSTALL_DIR}/reporting-portal"
GITHUB_REPO="https://github.com/stella555359/cursor_program.git"

# SSH 密钥路径
SSH_KEY_PATH="/root/.ssh/jenkins_rsa"

################################################################################
# 阶段 1: 系统准备
################################################################################

stage1_system_preparation() {
    log_info "=========================================="
    log_info "阶段 1: 系统准备"
    log_info "=========================================="
    
    # 更新系统
    log_info "更新系统包..."
    apt update -qq
    apt upgrade -y -qq
    log_success "系统更新完成"
    
    # 安装基础软件
    log_info "安装基础软件包..."
    apt install -y -qq \
        openjdk-17-jdk \
        python3.11 \
        python3.11-venv \
        python3-pip \
        git \
        curl \
        wget \
        vim \
        nginx \
        htop \
        net-tools \
        sqlite3 \
        ufw \
        gnupg2 \
        ca-certificates \
        apt-transport-https \
        software-properties-common
    log_success "基础软件安装完成"
    
    # 配置防火墙
    log_info "配置防火墙规则..."
    ufw --force enable
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow ${JENKINS_PORT}/tcp comment 'Jenkins'
    ufw allow ${REPORTING_PORTAL_PORT}/tcp comment 'Reporting Portal'
    ufw allow 50000/tcp comment 'Jenkins JNLP'
    ufw reload
    log_success "防火墙配置完成"
    
    # 配置主机名
    log_info "配置主机名..."
    hostnamectl set-hostname jenkins-master
    echo "127.0.0.1 jenkins-master" >> /etc/hosts
    log_success "主机名配置完成"
}

################################################################################
# 阶段 2: 安装 Jenkins
################################################################################

stage2_install_jenkins() {
    log_info "=========================================="
    log_info "阶段 2: 安装 Jenkins"
    log_info "=========================================="
    
    # 添加 Jenkins 仓库密钥
    log_info "添加 Jenkins 仓库..."
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
        gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
    
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] \
        https://pkg.jenkins.io/debian-stable binary/" | \
        tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    
    # 安装 Jenkins
    log_info "安装 Jenkins..."
    apt update -qq
    apt install -y -qq jenkins
    log_success "Jenkins 安装完成"
    
    # 配置 Jenkins
    log_info "配置 Jenkins..."
    
    # 增加 Java 堆内存
    mkdir -p /etc/systemd/system/jenkins.service.d
    cat > /etc/systemd/system/jenkins.service.d/override.conf << EOF
[Service]
Environment="JAVA_OPTS=-Xmx2048m -Xms512m -Djava.awt.headless=true"
EOF
    
    systemctl daemon-reload
    
    # 启动 Jenkins
    log_info "启动 Jenkins 服务..."
    systemctl start jenkins
    systemctl enable jenkins
    
    # 等待 Jenkins 启动
    log_info "等待 Jenkins 启动（最多 120 秒）..."
    for i in {1..24}; do
        if systemctl is-active --quiet jenkins; then
            log_success "Jenkins 服务启动成功"
            break
        fi
        sleep 5
        echo -n "."
    done
    echo ""
    
    # 等待 Jenkins Web 可访问
    log_info "等待 Jenkins Web 服务就绪..."
    for i in {1..24}; do
        if curl -s http://localhost:${JENKINS_PORT} > /dev/null 2>&1; then
            log_success "Jenkins Web 服务就绪"
            break
        fi
        sleep 5
        echo -n "."
    done
    echo ""
    
    # 获取初始管理员密码
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        JENKINS_INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
        log_success "Jenkins 初始管理员密码: ${JENKINS_INITIAL_PASSWORD}"
        echo "${JENKINS_INITIAL_PASSWORD}" > /root/jenkins_initial_password.txt
        log_info "密码已保存到: /root/jenkins_initial_password.txt"
    else
        log_warning "未找到 Jenkins 初始密码文件"
    fi
    
    log_info "Jenkins 访问地址: http://${MASTER_IP}:${JENKINS_PORT}"
}

################################################################################
# 阶段 3: 配置 SSH 密钥
################################################################################

stage3_setup_ssh_keys() {
    log_info "=========================================="
    log_info "阶段 3: 配置 SSH 密钥"
    log_info "=========================================="
    
    # 生成 SSH 密钥对
    if [ ! -f "${SSH_KEY_PATH}" ]; then
        log_info "生成 SSH 密钥对..."
        mkdir -p $(dirname ${SSH_KEY_PATH})
        ssh-keygen -t rsa -b 4096 -C "jenkins@master" -f ${SSH_KEY_PATH} -N ""
        log_success "SSH 密钥生成完成"
    else
        log_info "SSH 密钥已存在，跳过生成"
    fi
    
    # 显示公钥
    log_info "SSH 公钥内容（需要复制到 Agent 服务器）:"
    echo "=========================================="
    cat ${SSH_KEY_PATH}.pub
    echo "=========================================="
    
    log_warning "请手动执行以下命令将公钥复制到 Agent 服务器:"
    echo ""
    echo "ssh-copy-id -i ${SSH_KEY_PATH}.pub jenkins@${AGENT1_IP}"
    echo "ssh-copy-id -i ${SSH_KEY_PATH}.pub jenkins@${AGENT2_IP}"
    echo ""
    
    # 保存私钥位置信息
    echo "${SSH_KEY_PATH}" > /root/jenkins_ssh_key_path.txt
    log_info "SSH 私钥路径已保存到: /root/jenkins_ssh_key_path.txt"
}

################################################################################
# 阶段 4: 部署 Reporting Portal
################################################################################

stage4_deploy_reporting_portal() {
    log_info "=========================================="
    log_info "阶段 4: 部署 Reporting Portal"
    log_info "=========================================="
    
    # 创建工作目录
    log_info "创建工作目录..."
    mkdir -p ${REPORTING_PORTAL_DIR}
    cd ${REPORTING_PORTAL_DIR}
    
    # 克隆 GitHub 仓库
    log_info "克隆 GitHub 仓库..."
    if [ -d "cursor_program" ]; then
        log_warning "仓库目录已存在，执行 git pull 更新..."
        cd cursor_program
        git pull origin main
        cd ..
    else
        git clone ${GITHUB_REPO}
    fi
    log_success "代码库克隆完成"
    
    # 创建 Reporting Portal 项目结构
    log_info "创建 Reporting Portal 项目结构..."
    cd cursor_program
    mkdir -p reporting-portal
    cd reporting-portal
    
    # 创建目录结构
    mkdir -p app/{api/v1,models,schemas,services,templates}
    mkdir -p data logs tests alembic/versions
    
    # 创建 __init__.py 文件
    touch app/__init__.py
    touch app/models/__init__.py
    touch app/schemas/__init__.py
    touch app/api/__init__.py
    touch app/api/v1/__init__.py
    touch app/services/__init__.py
    
    # 创建 main.py
    log_info "创建 FastAPI 应用文件..."
    cat > app/main.py << 'EOFMAIN'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.api.v1 import test_results
from app.database import engine, Base

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 创建 FastAPI 应用
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="自动化测试结果管理平台",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(
    test_results.router,
    prefix="/api/v1",
    tags=["test-results"]
)

@app.get("/")
async def root():
    return {
        "message": "Reporting Portal API",
        "version": settings.VERSION,
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
EOFMAIN
    
    # 创建 config.py
    cat > app/config.py << 'EOFCONFIG'
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    APP_NAME: str = "Reporting Portal"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    DATABASE_URL: str = "sqlite:///./data/results.db"
    
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost",
        "http://10.71.210.104",
        "http://10.71.210.104:8080"
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
EOFCONFIG
    
    # 创建 database.py
    cat > app/database.py << 'EOFDATABASE'
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# 数据库文件路径
DB_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
os.makedirs(DB_DIR, exist_ok=True)
DB_PATH = os.path.join(DB_DIR, "results.db")

DATABASE_URL = f"sqlite:///{DB_PATH}"

# 创建引擎
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
    echo=False
)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建基类
Base = declarative_base()

# 依赖注入
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOFDATABASE
    
    # 创建 models/test_result.py
    cat > app/models/test_result.py << 'EOFMODEL'
from sqlalchemy import Column, Integer, String, DateTime, Float, Text, Enum
from app.database import Base
from datetime import datetime
import enum

class TestStatus(str, enum.Enum):
    PASSED = "PASSED"
    FAILED = "FAILED"
    SKIPPED = "SKIPPED"

class TestResult(Base):
    __tablename__ = "test_results"
    
    id = Column(Integer, primary_key=True, index=True)
    test_name = Column(String(500), nullable=False, index=True)
    suite_name = Column(String(255), index=True)
    status = Column(String(20), nullable=False)
    
    # 测试线和版本信息
    testline = Column(String(100), nullable=False, index=True)
    build_version = Column(String(100), index=True)
    af_path = Column(Text)
    
    # 执行信息
    execution_id = Column(String(255), unique=True, index=True)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    duration_seconds = Column(Float)
    
    # 结果详情
    error_message = Column(Text)
    log_path = Column(String(500))
    report_path = Column(String(500))
    
    # Jenkins 信息
    jenkins_job_name = Column(String(200))
    jenkins_build_number = Column(Integer)
    jenkins_build_url = Column(String(500))
    
    # QC 集成（可选）
    qc_domain = Column(String(50))
    qc_project = Column(String(50))
    qc_id = Column(String(50))
    
    # 元数据
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
EOFMODEL
    
    # 创建 schemas/test_result.py
    cat > app/schemas/test_result.py << 'EOFSCHEMA'
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum

class TestStatus(str, Enum):
    PASSED = "PASSED"
    FAILED = "FAILED"
    SKIPPED = "SKIPPED"

class TestResultBase(BaseModel):
    test_name: str = Field(..., max_length=500)
    suite_name: Optional[str] = Field(None, max_length=255)
    status: str
    testline: str = Field(..., max_length=100)
    build_version: Optional[str] = Field(None, max_length=100)
    af_path: Optional[str] = None
    execution_id: Optional[str] = Field(None, max_length=255)
    error_message: Optional[str] = None
    log_path: Optional[str] = None
    report_path: Optional[str] = None
    jenkins_job_name: Optional[str] = None
    jenkins_build_number: Optional[int] = None
    jenkins_build_url: Optional[str] = None

class TestResultCreate(TestResultBase):
    pass

class TestResult(TestResultBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True
EOFSCHEMA
    
    # 创建 api/deps.py
    cat > app/api/deps.py << 'EOFDEPS'
from app.database import SessionLocal

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOFDEPS
    
    # 创建 api/v1/test_results.py
    cat > app/api/v1/test_results.py << 'EOFAPI'
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.api import deps
from app.schemas import test_result as schemas
from app.services import test_service

router = APIRouter()

@router.post("/test-results", response_model=schemas.TestResult, status_code=201)
async def create_test_result(
    *,
    db: Session = Depends(deps.get_db),
    result_in: schemas.TestResultCreate
):
    """接收 Robot Framework 上传的测试结果"""
    result = test_service.create_test_result(db=db, result=result_in)
    return result

@router.get("/test-results", response_model=List[schemas.TestResult])
async def list_test_results(
    *,
    db: Session = Depends(deps.get_db),
    testline: Optional[str] = None,
    status: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000)
):
    """查询测试结果列表"""
    results = test_service.get_test_results(
        db=db, testline=testline, status=status, skip=skip, limit=limit
    )
    return results

@router.get("/test-results/{result_id}", response_model=schemas.TestResult)
async def get_test_result(
    *,
    db: Session = Depends(deps.get_db),
    result_id: int
):
    """获取单条测试结果详情"""
    result = test_service.get_test_result(db=db, result_id=result_id)
    if not result:
        raise HTTPException(status_code=404, detail="测试结果未找到")
    return result

@router.get("/dashboard/stats")
async def get_dashboard_stats(
    *,
    db: Session = Depends(deps.get_db),
    testline: Optional[str] = None
):
    """获取仪表盘统计数据"""
    stats = test_service.get_dashboard_stats(db=db, testline=testline)
    return stats
EOFAPI
    
    # 创建 services/test_service.py
    cat > app/services/test_service.py << 'EOFSERVICE'
from sqlalchemy.orm import Session
from app.models.test_result import TestResult
from app.schemas.test_result import TestResultCreate
from datetime import datetime
from typing import Optional, List

def create_test_result(db: Session, result: TestResultCreate) -> TestResult:
    db_result = TestResult(
        **result.model_dump(),
        created_at=datetime.utcnow()
    )
    db.add(db_result)
    db.commit()
    db.refresh(db_result)
    return db_result

def get_test_result(db: Session, result_id: int) -> Optional[TestResult]:
    return db.query(TestResult).filter(TestResult.id == result_id).first()

def get_test_results(
    db: Session,
    testline: Optional[str] = None,
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
) -> List[TestResult]:
    query = db.query(TestResult)
    
    if testline:
        query = query.filter(TestResult.testline == testline)
    if status:
        query = query.filter(TestResult.status == status)
    
    return query.order_by(TestResult.created_at.desc())\
                .offset(skip)\
                .limit(limit)\
                .all()

def get_dashboard_stats(db: Session, testline: Optional[str] = None):
    query = db.query(TestResult)
    if testline:
        query = query.filter(TestResult.testline == testline)
    
    total = query.count()
    passed = query.filter(TestResult.status == "PASSED").count()
    failed = query.filter(TestResult.status == "FAILED").count()
    skipped = query.filter(TestResult.status == "SKIPPED").count()
    
    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "pass_rate": round(passed / total * 100, 2) if total > 0 else 0
    }
EOFSERVICE
    
    # 创建 requirements.txt
    cat > requirements.txt << 'EOFREQ'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
pydantic==2.5.0
pydantic-settings==2.1.0
python-multipart==0.0.6
aiosqlite==0.19.0
python-dateutil==2.8.2
EOFREQ
    
    # 创建虚拟环境并安装依赖
    log_info "创建 Python 虚拟环境..."
    python3.11 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip -q
    pip install -r requirements.txt -q
    log_success "依赖安装完成"
    
    # 初始化数据库
    log_info "初始化数据库..."
    python3 -c "from app.database import Base, engine; Base.metadata.create_all(bind=engine)"
    log_success "数据库初始化完成"
    
    # 创建启动脚本
    cat > run.sh << 'EOFRUN'
#!/bin/bash
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
EOFRUN
    chmod +x run.sh
    
    # 创建 systemd 服务
    log_info "配置 systemd 服务..."
    cat > /etc/systemd/system/reporting-portal.service << EOFSYSTEMD
[Unit]
Description=Reporting Portal FastAPI Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${REPORTING_PORTAL_DIR}/cursor_program/reporting-portal
Environment="PATH=${REPORTING_PORTAL_DIR}/cursor_program/reporting-portal/venv/bin"
ExecStart=${REPORTING_PORTAL_DIR}/cursor_program/reporting-portal/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port ${REPORTING_PORTAL_PORT}
Restart=always

[Install]
WantedBy=multi-user.target
EOFSYSTEMD
    
    # 启动服务
    log_info "启动 Reporting Portal 服务..."
    systemctl daemon-reload
    systemctl start reporting-portal
    systemctl enable reporting-portal
    
    sleep 3
    
    if systemctl is-active --quiet reporting-portal; then
        log_success "Reporting Portal 服务启动成功"
    else
        log_error "Reporting Portal 服务启动失败"
        systemctl status reporting-portal
    fi
    
    log_info "Reporting Portal 访问地址: http://${MASTER_IP}:${REPORTING_PORTAL_PORT}/docs"
}

################################################################################
# 阶段 5: 配置 Nginx 反向代理
################################################################################

stage5_configure_nginx() {
    log_info "=========================================="
    log_info "阶段 5: 配置 Nginx 反向代理"
    log_info "=========================================="
    
    # 创建 Reporting Portal Nginx 配置
    log_info "创建 Nginx 配置文件..."
    cat > /etc/nginx/sites-available/reporting-portal << 'EOFNGINX'
server {
    listen 80;
    server_name 10.71.210.104;
    
    # Reporting Portal
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API 文档
    location /docs {
        proxy_pass http://localhost:8000/docs;
        proxy_set_header Host $host;
    }
    
    location /redoc {
        proxy_pass http://localhost:8000/redoc;
        proxy_set_header Host $host;
    }
    
    # 健康检查
    location /health {
        proxy_pass http://localhost:8000/health;
    }
}
EOFNGINX
    
    # 启用配置
    ln -sf /etc/nginx/sites-available/reporting-portal /etc/nginx/sites-enabled/
    
    # 测试配置
    log_info "测试 Nginx 配置..."
    nginx -t
    
    # 重启 Nginx
    log_info "重启 Nginx..."
    systemctl restart nginx
    systemctl enable nginx
    
    log_success "Nginx 配置完成"
}

################################################################################
# 阶段 6: 创建备份脚本
################################################################################

stage6_create_backup_script() {
    log_info "=========================================="
    log_info "阶段 6: 创建备份脚本"
    log_info "=========================================="
    
    # 创建备份目录
    mkdir -p /opt/backups
    
    # 创建备份脚本
    cat > /opt/backups/backup_reporting_portal.sh << 'EOFBACKUP'
#!/bin/bash
BACKUP_DIR="/opt/backups/reporting-portal"
DB_FILE="/opt/reporting-portal/cursor_program/reporting-portal/data/results.db"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cp $DB_FILE $BACKUP_DIR/results_backup_$DATE.db

# 保留最近 30 天的备份
find $BACKUP_DIR -name "results_backup_*.db" -mtime +30 -delete

echo "Backup completed: results_backup_$DATE.db"
EOFBACKUP
    
    chmod +x /opt/backups/backup_reporting_portal.sh
    
    # 配置 cron 定时任务
    log_info "配置定时备份任务（每天凌晨 2 点）..."
    (crontab -l 2>/dev/null; echo "0 2 * * * /opt/backups/backup_reporting_portal.sh >> /var/log/backup.log 2>&1") | crontab -
    
    log_success "备份脚本创建完成"
}

################################################################################
# 阶段 7: 生成部署报告
################################################################################

stage7_generate_report() {
    log_info "=========================================="
    log_info "阶段 7: 生成部署报告"
    log_info "=========================================="
    
    REPORT_FILE="/root/deployment_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > ${REPORT_FILE} << EOFREPORT
================================================================================
Jenkins Master + Reporting Portal 部署报告
================================================================================
部署时间: $(date '+%Y-%m-%d %H:%M:%S')
服务器IP: ${MASTER_IP}

================================================================================
1. Jenkins 信息
================================================================================
访问地址: http://${MASTER_IP}:${JENKINS_PORT}
初始密码: $(cat /root/jenkins_initial_password.txt 2>/dev/null || echo "未找到")
状态: $(systemctl is-active jenkins)

初始化步骤:
1. 访问 Jenkins Web UI
2. 输入初始密码
3. 选择 "Install suggested plugins"
4. 创建管理员用户

================================================================================
2. Reporting Portal 信息
================================================================================
访问地址: http://${MASTER_IP}:${REPORTING_PORTAL_PORT}/docs
API 文档: http://${MASTER_IP}:${REPORTING_PORTAL_PORT}/docs
健康检查: http://${MASTER_IP}:${REPORTING_PORTAL_PORT}/health
状态: $(systemctl is-active reporting-portal)

数据库位置:
${REPORTING_PORTAL_DIR}/cursor_program/reporting-portal/data/results.db

日志查看:
sudo journalctl -u reporting-portal -f

================================================================================
3. SSH 密钥信息
================================================================================
私钥路径: ${SSH_KEY_PATH}
公钥路径: ${SSH_KEY_PATH}.pub

需要将公钥复制到 Agent 服务器:
ssh-copy-id -i ${SSH_KEY_PATH}.pub jenkins@${AGENT1_IP}
ssh-copy-id -i ${SSH_KEY_PATH}.pub jenkins@${AGENT2_IP}

公钥内容:
$(cat ${SSH_KEY_PATH}.pub)

================================================================================
4. 下一步操作
================================================================================
[ ] 访问 Jenkins 完成初始化
[ ] 复制 SSH 公钥到 Agent 服务器
[ ] 在 Jenkins 中添加 Credentials (SSH 私钥)
[ ] 在 Jenkins 中添加 Agent 节点
    - Agent 1: ${AGENT1_IP} (${TESTLINE1})
    - Agent 2: ${AGENT2_IP} (${TESTLINE2})
[ ] 创建 Pipeline Job
[ ] 测试端到端流程

================================================================================
5. 常用命令
================================================================================
# Jenkins 管理
sudo systemctl restart jenkins
sudo systemctl status jenkins
sudo tail -f /var/log/jenkins/jenkins.log

# Reporting Portal 管理
sudo systemctl restart reporting-portal
sudo systemctl status reporting-portal
sudo journalctl -u reporting-portal -f

# 数据库查询
sqlite3 ${REPORTING_PORTAL_DIR}/cursor_program/reporting-portal/data/results.db

# 备份
/opt/backups/backup_reporting_portal.sh

================================================================================
6. Agent 服务器准备命令（在 Agent 上执行）
================================================================================
# 创建 jenkins 用户
sudo useradd -m -s /bin/bash jenkins
sudo usermod -aG sudo jenkins

# 安装依赖
sudo apt update
sudo apt install -y python3.11 python3.11-venv git

# 创建目录
sudo mkdir -p /home/jenkins/workspace /opt /home/ute/CIENV

# 配置 SSH authorized_keys
sudo -u jenkins mkdir -p /home/jenkins/.ssh
sudo -u jenkins chmod 700 /home/jenkins/.ssh
# 然后在 Master 上执行 ssh-copy-id

================================================================================
部署完成！
================================================================================
EOFREPORT
    
    log_success "部署报告已生成: ${REPORT_FILE}"
    
    # 显示报告
    cat ${REPORT_FILE}
}

################################################################################
# 主函数
################################################################################

main() {
    log_info "=========================================="
    log_info "Jenkins Master 自动部署脚本"
    log_info "目标服务器: ${MASTER_IP}"
    log_info "=========================================="
    
    # 检查 root 权限
    check_root
    
    # 执行各阶段
    stage1_system_preparation
    stage2_install_jenkins
    stage3_setup_ssh_keys
    stage4_deploy_reporting_portal
    stage5_configure_nginx
    stage6_create_backup_script
    stage7_generate_report
    
    log_success "=========================================="
    log_success "部署完成！"
    log_success "=========================================="
    log_info "Jenkins: http://${MASTER_IP}:${JENKINS_PORT}"
    log_info "Reporting Portal: http://${MASTER_IP}:${REPORTING_PORTAL_PORT}/docs"
    log_info "部署报告: 查看 /root/deployment_report_*.txt"
}

# 运行主函数
main "$@"
