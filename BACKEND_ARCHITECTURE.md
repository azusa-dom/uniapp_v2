# 🚀 UniApp V2 智能后端系统架构设计

## 📑 目录

- [1. 系统概述](#1-系统概述)
- [2. 技术栈](#2-技术栈)
- [3. 微服务架构](#3-微服务架构)
- [4. 智能 AI 系统](#4-智能-ai-系统)
- [5. 数据库设计](#5-数据库设计)
- [6. API 设计](#6-api-设计)
- [7. 部署方案](#7-部署方案)
- [8. 安全方案](#8-安全方案)
- [9. 实施计划](#9-实施计划)

---

## 1. 系统概述

### 1.1 项目背景

UniApp V2 是一个面向 UCL 留学生和家长的智能移动平台,集成了:
- 📅 **日程管理** - UCL 课程表、活动、预定
- 📧 **邮件同步** - 智能分类、翻译、摘要
- 📊 **成绩管理** - Moodle、WiseFlow 成绩集成
- 🤖 **AI 助手** - 基于 RAG 的智能问答系统
- 🏥 **健康管理** - 医疗记录、预约管理
- 👨‍👩‍👧 **家长监控** - 出勤、成绩、健康数据共享

### 1.2 设计目标

- ⚡ **高性能** - API 响应时间 < 200ms, AI 响应 < 2s
- 🔒 **高安全** - 企业级认证、数据加密、隐私保护
- 📈 **可扩展** - 支持 10,000+ 并发用户
- 🛡️ **高可用** - 99.9% SLA, 自动故障转移
- 🔧 **易维护** - 微服务架构、容器化部署、自动化 CI/CD

### 1.3 核心创新点

🌟 **智能 RAG 系统**
- 基于向量数据库的语义搜索
- 多源数据融合 (UCL API + Moodle + 邮件 + 官网)
- 实时数据更新与索引
- 多模态支持 (文本、图片、PDF)

🌟 **实时数据同步**
- WebSocket 双向通信
- 事件驱动架构
- 智能缓存预热

🌟 **家长端协同**
- 细粒度权限控制
- 隐私数据脱敏
- 实时通知推送

---

## 2. 技术栈

### 2.1 后端框架

```python
# 核心框架
FastAPI 0.110+           # 高性能异步 Web 框架
Pydantic 2.0+            # 数据验证
SQLAlchemy 2.0+          # ORM
Alembic                  # 数据库迁移

# 异步支持
asyncio                  # 异步编程
aiohttp                  # 异步 HTTP 客户端
aioredis                 # 异步 Redis 客户端
asyncpg                  # 异步 PostgreSQL 驱动
```

### 2.2 AI & 机器学习

```python
# LLM 集成
OpenAI SDK               # GPT-4 / GPT-4o
anthropic                # Claude 3.5 Sonnet
DeepSeek SDK             # DeepSeek-V3 (主力模型)

# 向量数据库
Qdrant                   # 向量存储与搜索
sentence-transformers    # 文本嵌入 (BGE-M3)

# 知识图谱
Neo4j                    # 图数据库
networkx                 # 图算法

# RAG 框架
LangChain                # LLM 应用框架
LlamaIndex               # 数据索引与检索

# NLP 工具
spacy                    # 中英文分词
jieba                    # 中文分词
beautifulsoup4           # HTML 解析
```

### 2.3 数据存储

```yaml
PostgreSQL 16:           # 主数据库
  - 用户数据、课程、成绩、邮件元数据
  - 使用 JSONB 存储半结构化数据
  - 时序数据用 TimescaleDB 扩展

Redis 7:                 # 缓存与会话
  - Session 存储
  - API 限流计数
  - 实时数据缓存
  - 消息队列 (Stream)

Qdrant:                  # 向量数据库
  - 文档嵌入存储
  - 语义搜索
  - 推荐系统

MinIO/S3:                # 对象存储
  - 文件上传 (PDF, 图片)
  - 邮件附件
  - 导出数据
```

### 2.4 消息队列 & 任务调度

```python
Celery                   # 异步任务队列
RabbitMQ                 # 消息代理
Celery Beat              # 定时任务
  - 每小时同步 UCL API
  - 每 30 分钟检查新邮件
  - 每天生成数据报告
```

### 2.5 监控 & 日志

```yaml
Prometheus:              # 指标收集
  - API 响应时间
  - 数据库查询性能
  - 缓存命中率

Grafana:                 # 可视化仪表板

ELK Stack:               # 日志分析
  - Elasticsearch        # 日志存储
  - Logstash             # 日志处理
  - Kibana               # 日志可视化

Sentry:                  # 错误追踪
```

### 2.6 DevOps

```yaml
Docker:                  # 容器化
Kubernetes:              # 容器编排
  - Deployment           # 服务部署
  - Service              # 服务发现
  - Ingress              # 流量入口
  - HPA                  # 自动扩缩容

GitHub Actions:          # CI/CD
  - 自动测试
  - 代码质量检查
  - 自动部署

Terraform:               # 基础设施即代码
```

---

## 3. 微服务架构

### 3.1 服务划分

```
backend/
├── gateway/                 # API 网关
│   ├── rate_limiter.py      # 限流中间件
│   ├── auth_middleware.py   # 认证中间件
│   └── router.py            # 路由配置
│
├── services/
│   ├── auth/                # 认证服务
│   │   ├── jwt_handler.py   # JWT 生成/验证
│   │   ├── oauth.py         # OAuth2 集成
│   │   ├── mfa.py           # 多因素认证
│   │   └── permissions.py   # RBAC 权限控制
│   │
│   ├── ucl_proxy/           # UCL API 代理服务
│   │   ├── timetable.py     # 课程表
│   │   ├── rooms.py         # 房间预定
│   │   ├── activities.py    # 活动数据
│   │   ├── people.py        # 人员搜索
│   │   └── cache.py         # 智能缓存
│   │
│   ├── email/               # 邮件服务
│   │   ├── imap_client.py   # IMAP 同步
│   │   ├── smtp_client.py   # 邮件发送
│   │   ├── parser.py        # 邮件解析
│   │   ├── translator.py    # 中英翻译
│   │   ├── summarizer.py    # AI 摘要
│   │   └── categorizer.py   # 智能分类
│   │
│   ├── grades/              # 成绩服务
│   │   ├── moodle.py        # Moodle API
│   │   ├── wiseflow.py      # WiseFlow 集成
│   │   ├── aggregator.py    # 成绩聚合
│   │   └── analytics.py     # 成绩分析
│   │
│   ├── ai/                  # AI 服务 (核心)
│   │   ├── rag/
│   │   │   ├── retriever.py     # 检索器
│   │   │   ├── reranker.py      # 重排序
│   │   │   ├── generator.py     # 生成器
│   │   │   └── evaluator.py     # 答案质量评估
│   │   ├── embeddings/
│   │   │   ├── text_encoder.py  # 文本嵌入
│   │   │   └── multimodal.py    # 多模态嵌入
│   │   ├── knowledge_graph/
│   │   │   ├── builder.py       # 知识图谱构建
│   │   │   ├── query.py         # 图查询
│   │   │   └── reasoning.py     # 推理引擎
│   │   ├── agents/
│   │   │   ├── academic_agent.py # 学业助手
│   │   │   ├── email_agent.py    # 邮件助手
│   │   │   └── schedule_agent.py # 日程助手
│   │   └── llm/
│   │       ├── deepseek.py      # DeepSeek 客户端
│   │       ├── openai.py        # OpenAI 客户端
│   │       └── router.py        # 模型路由
│   │
│   ├── schedule/            # 日程服务
│   │   ├── calendar.py      # 日历管理
│   │   ├── events.py        # 事件管理
│   │   ├── sync.py          # 多端同步
│   │   └── recommendations.py # 智能推荐
│   │
│   ├── health/              # 健康服务
│   │   ├── records.py       # 医疗记录
│   │   ├── prescriptions.py # 处方管理
│   │   ├── appointments.py  # 预约系统
│   │   └── analytics.py     # 健康分析
│   │
│   ├── notifications/       # 通知服务
│   │   ├── apns.py          # Apple 推送
│   │   ├── websocket.py     # WebSocket 服务
│   │   ├── sms.py           # 短信通知
│   │   └── email_notify.py  # 邮件通知
│   │
│   └── analytics/           # 数据分析服务
│       ├── user_behavior.py # 用户行为分析
│       ├── performance.py   # 学业表现分析
│       └── reports.py       # 报告生成
│
├── shared/                  # 共享模块
│   ├── database/
│   │   ├── postgres.py      # PostgreSQL 连接池
│   │   ├── redis.py         # Redis 连接
│   │   └── qdrant.py        # Qdrant 客户端
│   ├── models/              # 数据模型
│   │   ├── user.py
│   │   ├── course.py
│   │   ├── email.py
│   │   └── event.py
│   ├── utils/
│   │   ├── logger.py        # 日志工具
│   │   ├── validators.py    # 验证器
│   │   └── encryption.py    # 加密工具
│   └── config/
│       ├── settings.py      # 配置管理
│       └── secrets.py       # 密钥管理
│
└── tests/                   # 测试
    ├── unit/
    ├── integration/
    └── e2e/
```

### 3.2 服务间通信

```
同步通信 (REST API):
- API Gateway → 各服务
- 服务间直接调用 (仅关键路径)

异步通信 (消息队列):
- 邮件同步完成 → AI 服务 (生成摘要)
- 新成绩发布 → 通知服务 (推送通知)
- 用户行为 → 分析服务 (数据统计)

事件驱动架构:
Event: UserRegistered
  → 发送欢迎邮件
  → 初始化用户数据
  → 同步 UCL 课程表

Event: NewEmailReceived
  → AI 分类
  → 生成摘要
  → 推送通知

Event: GradeUpdated
  → 更新学业报告
  → 通知家长
  → 触发学业分析
```

---

## 4. 智能 AI 系统

### 4.1 RAG 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                    用户查询 (User Query)                  │
│  "下周有哪些 Data Science 的讲座活动？"                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│              Query Understanding (查询理解)               │
│  ├─ 意图识别: 查询活动                                     │
│  ├─ 实体抽取: "下周", "Data Science", "讲座"              │
│  ├─ 时间解析: 2025-01-20 ~ 2025-01-26                    │
│  └─ 查询改写: "Data Science lectures next week"          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│           Multi-Source Retrieval (多源检索)               │
│  ┌──────────────┬──────────────┬──────────────────────┐ │
│  │ Vector DB    │ Knowledge    │ Structured Database  │ │
│  │ (语义搜索)    │ Graph        │ (精确查询)            │ │
│  │              │ (关系推理)    │                      │ │
│  │ UCL 活动文档  │ 课程-讲座     │ Events Table         │ │
│  │ 邮件历史     │ 学科-主题     │ WHERE type='lecture' │ │
│  │ 官网爬取     │ 讲师-研究     │ AND ...              │ │
│  └──────┬───────┴──────┬───────┴──────┬───────────────┘ │
│         │              │              │                 │
│         ↓              ↓              ↓                 │
│    Result Set 1    Result Set 2  Result Set 3          │
└────────────────────┬────────────────────────────────────┘
                     │ Hybrid Retrieval
                     ↓
┌─────────────────────────────────────────────────────────┐
│              Re-ranking (重排序与融合)                    │
│  ├─ 相关性评分 (Cross-Encoder)                           │
│  ├─ 新鲜度加权 (越新越重要)                               │
│  ├─ 多样性优化 (去重、多角度)                             │
│  └─ Top-K 选择 (k=5-10)                                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│         Context Augmentation (上下文增强)                 │
│  ├─ 用户画像注入: "你是 MSc Health Data Science 学生"      │
│  ├─ 对话历史: 过去 3 轮对话                               │
│  ├─ 检索结果: 5 个相关文档片段                            │
│  └─ 元数据: 时间、地点、价格、链接                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│            LLM Generation (生成答案)                      │
│  Model: DeepSeek-V3 (主力) / GPT-4o (备用)               │
│  System Prompt:                                         │
│    "你是 UniApp 的双语学习助手,专注于 UCL 学生的           │
│     学业、活动和校园生活。基于检索到的信息回答,              │
│     保持简洁准确,使用简体中文。"                          │
│                                                         │
│  Temperature: 0.3 (更精确)                               │
│  Max Tokens: 800                                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│          Post-Processing (后处理)                        │
│  ├─ 事实验证 (Fact Checking)                             │
│  ├─ 引用标注 (Citation)                                  │
│  ├─ 格式美化 (Markdown)                                  │
│  └─ 相关推荐 (Related Questions)                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    返回答案给用户                          │
│  "下周有 3 场 Data Science 相关讲座:                       │
│   1. 【1月21日】Machine Learning in Healthcare 🏥         │
│      时间: 14:00-16:00                                   │
│      地点: Roberts Building G08                          │
│      免费,需提前预定                                       │
│   2. ..."                                               │
└─────────────────────────────────────────────────────────┘
```

### 4.2 知识库构建

```python
# 数据源
Knowledge Sources:
  1. UCL API 实时数据
     - 课程表
     - 活动列表
     - 房间预定信息
     - 人员目录

  2. 爬虫数据
     - UCL 官网新闻
     - 学院公告
     - 讲座信息
     - 图书馆资源

  3. Moodle 课程内容
     - 课程大纲
     - 作业要求
     - 课件资料
     - 讨论区内容

  4. 用户邮件
     - 官方通知
     - 导师邮件
     - 课程提醒

  5. 历史对话
     - 高质量问答对
     - 用户反馈
     - 常见问题

# 数据处理流程
Data Processing Pipeline:
  1. 数据采集 (Celery 定时任务)
  2. 清洗与去重
  3. 分块 (Chunking)
     - 语义分块 (保持段落完整性)
     - 重叠分块 (overlap=50 tokens)
     - 最大长度: 512 tokens
  4. 嵌入 (Embedding)
     - Model: bge-m3 (多语言)
     - Dimension: 1024
     - 批处理: 32 docs/batch
  5. 索引 (Indexing)
     - 存入 Qdrant
     - 构建倒排索引
     - 创建元数据过滤器
  6. 质量评估
     - 人工抽检
     - A/B 测试
```

### 4.3 多模态支持

```python
# 文本处理
Text Processing:
  - 中英文分词
  - 实体识别
  - 关键词提取

# PDF 处理
PDF Processing:
  - 版面分析 (Layout Analysis)
  - 表格提取 (Table Extraction)
  - 公式识别 (Formula Recognition)
  - 图片描述生成 (Image Captioning)

# 图片理解
Image Understanding:
  - OCR 文字识别
  - 场景识别 (课程表截图、邮件截图)
  - 图表解析 (成绩图表、数据可视化)
  - 使用 GPT-4 Vision / Claude 3.5 Sonnet
```

### 4.4 智能 Agent 系统

```python
# 学业助手 Agent
class AcademicAgent:
    """
    负责学业相关查询:
    - "我下周有哪些作业要交?"
    - "Machine Learning 这门课的平均分是多少?"
    - "如何提高 Python 编程能力?"
    """
    tools = [
        get_upcoming_assignments,
        get_course_grades,
        search_study_resources,
        analyze_performance_trend
    ]

# 日程助手 Agent
class ScheduleAgent:
    """
    负责日程管理:
    - "明天的课程安排是什么?"
    - "帮我找一个空闲时间段见导师"
    - "这周有哪些值得参加的活动?"
    """
    tools = [
        get_timetable,
        find_free_slots,
        search_activities,
        book_room
    ]

# 邮件助手 Agent
class EmailAgent:
    """
    负责邮件处理:
    - "最近有没有重要的邮件?"
    - "帮我起草一封请假邮件"
    - "总结一下这周收到的邮件"
    """
    tools = [
        search_emails,
        generate_email_draft,
        summarize_emails,
        set_email_reminder
    ]

# Multi-Agent 协作
class AgentOrchestrator:
    """
    根据用户意图路由到对应 Agent
    支持多 Agent 协作完成复杂任务
    """
    def route(self, query: str) -> Agent:
        # 使用分类器识别意图
        intent = self.intent_classifier(query)
        return self.agent_map[intent]
```

---

## 5. 数据库设计

### 5.1 PostgreSQL Schema

```sql
-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'parent')),
    full_name VARCHAR(100),
    ucl_id VARCHAR(50),
    department VARCHAR(100),
    programme VARCHAR(200),
    year_of_study INTEGER,
    profile_picture_url TEXT,
    phone_number VARCHAR(20),
    emergency_contact JSONB,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false
);

-- 学生-家长关联表
CREATE TABLE student_parent_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES users(id) ON DELETE CASCADE,
    relationship VARCHAR(50), -- 'father', 'mother', 'guardian'
    permissions JSONB DEFAULT '{"view_grades": true, "view_attendance": true, "view_health": false}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(student_id, parent_id)
);

-- 课程表
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    department VARCHAR(100),
    credits INTEGER,
    level VARCHAR(20), -- 'undergraduate', 'postgraduate'
    description TEXT,
    syllabus_url TEXT,
    moodle_id VARCHAR(100),
    year VARCHAR(10), -- '2024/2025'
    term VARCHAR(20), -- 'Term 1', 'Term 2', 'Term 3'
    instructor JSONB, -- {"name": "Dr. Smith", "email": "..."}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 学生选课表
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'dropped'
    final_grade VARCHAR(10),
    grade_percentage DECIMAL(5,2),
    UNIQUE(student_id, course_id)
);

-- 课程时间表
CREATE TABLE timetable_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    event_type VARCHAR(50), -- 'lecture', 'tutorial', 'lab', 'seminar'
    title VARCHAR(200),
    description TEXT,
    location VARCHAR(200),
    building VARCHAR(100),
    room_number VARCHAR(50),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    recurrence_rule TEXT, -- iCalendar RRULE format
    instructor JSONB,
    ucl_api_data JSONB, -- 原始 UCL API 数据
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 作业表
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    type VARCHAR(50), -- 'essay', 'problem_set', 'project', 'exam'
    total_points DECIMAL(5,2),
    weight_percentage DECIMAL(5,2),
    due_date TIMESTAMP,
    submission_url TEXT,
    requirements JSONB,
    rubric JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 学生作业提交表
CREATE TABLE assignment_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES users(id) ON DELETE CASCADE,
    submitted_at TIMESTAMP,
    grade DECIMAL(5,2),
    feedback TEXT,
    files JSONB, -- [{"filename": "...", "url": "..."}]
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'submitted', 'graded'
    late_submission BOOLEAN DEFAULT false,
    UNIQUE(assignment_id, student_id)
);

-- 邮件表
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    message_id VARCHAR(255) UNIQUE, -- IMAP message ID
    thread_id VARCHAR(255),
    folder VARCHAR(100) DEFAULT 'INBOX',
    sender_name VARCHAR(200),
    sender_email VARCHAR(255) NOT NULL,
    recipients JSONB, -- [{"name": "...", "email": "..."}]
    subject VARCHAR(500),
    body_text TEXT,
    body_html TEXT,
    snippet TEXT, -- 前200字符
    ai_summary TEXT, -- AI 生成的摘要
    ai_translation TEXT, -- AI 生成的翻译
    category VARCHAR(50), -- 'urgent', 'academic', 'events', 'library', 'personal'
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    has_attachments BOOLEAN DEFAULT false,
    attachments JSONB,
    received_at TIMESTAMP NOT NULL,
    is_read BOOLEAN DEFAULT false,
    is_starred BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    labels JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_received (user_id, received_at DESC),
    INDEX idx_category (category),
    INDEX idx_is_read (is_read)
);

-- UCL 活动表
CREATE TABLE ucl_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(300) NOT NULL,
    description TEXT,
    activity_type VARCHAR(50), -- 'academic', 'cultural', 'sport', 'workshop', 'social'
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    location VARCHAR(200),
    building VARCHAR(100),
    room_number VARCHAR(50),
    organizer VARCHAR(200),
    capacity INTEGER,
    registration_url TEXT,
    price DECIMAL(10,2) DEFAULT 0.00,
    tags JSONB DEFAULT '[]',
    target_audience JSONB, -- ["undergraduates", "postgraduates", "staff"]
    is_free BOOLEAN DEFAULT true,
    requires_registration BOOLEAN DEFAULT false,
    image_url TEXT,
    source_url TEXT, -- UCL 官网链接
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_start_time (start_time),
    INDEX idx_type (activity_type)
);

-- 用户活动参与表
CREATE TABLE activity_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID REFERENCES ucl_activities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'interested', -- 'interested', 'registered', 'attended', 'cancelled'
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attended_at TIMESTAMP,
    feedback TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    UNIQUE(activity_id, user_id)
);

-- 医疗记录表
CREATE TABLE medical_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    visit_date TIMESTAMP NOT NULL,
    hospital_name VARCHAR(200),
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    diagnosis TEXT,
    symptoms TEXT,
    treatment TEXT,
    notes TEXT,
    documents JSONB, -- [{"type": "report", "url": "..."}]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 处方表
CREATE TABLE prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    medical_record_id UUID REFERENCES medical_records(id) ON DELETE SET NULL,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100), -- "每日三次，餐后服用"
    duration VARCHAR(100), -- "连续7天"
    start_date DATE NOT NULL,
    end_date DATE,
    prescribed_by VARCHAR(100),
    notes TEXT,
    reminder_enabled BOOLEAN DEFAULT true,
    reminder_times JSONB, -- ["08:00", "12:00", "18:00"]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 健康数据表 (时序数据)
CREATE TABLE health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    sleep_hours DECIMAL(4,2),
    steps_count INTEGER,
    stress_level INTEGER CHECK (stress_level >= 0 AND stress_level <= 10),
    mood INTEGER CHECK (mood >= 1 AND mood <= 5), -- 1=很差, 5=很好
    weight_kg DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, metric_date)
);

-- 医疗预约表
CREATE TABLE medical_appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    appointment_date TIMESTAMP NOT NULL,
    doctor_name VARCHAR(100),
    department VARCHAR(100),
    hospital_name VARCHAR(200),
    reason TEXT,
    status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'completed', 'cancelled', 'rescheduled'
    reminder_sent BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AI 对话历史表
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_archived BOOLEAN DEFAULT false
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    metadata JSONB, -- 存储检索结果、引用等
    model_used VARCHAR(50), -- 'deepseek-v3', 'gpt-4o'
    tokens_used INTEGER,
    latency_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_session_created (session_id, created_at)
);

-- 知识库文档表
CREATE TABLE knowledge_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500),
    content TEXT NOT NULL,
    document_type VARCHAR(50), -- 'ucl_api', 'email', 'moodle', 'web_crawl', 'pdf'
    source_url TEXT,
    source_id VARCHAR(255), -- 原始来源的ID
    metadata JSONB, -- 额外元数据
    embedding_id VARCHAR(255), -- Qdrant 中的向量 ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (document_type),
    INDEX idx_source (source_id)
);

-- 用户反馈表
CREATE TABLE user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    message_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    feedback_type VARCHAR(20) CHECK (feedback_type IN ('thumbs_up', 'thumbs_down', 'report')),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 通知表
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    body TEXT,
    type VARCHAR(50), -- 'assignment', 'grade', 'email', 'event', 'system'
    priority VARCHAR(20) DEFAULT 'normal',
    related_id UUID, -- 关联的对象ID (如 assignment_id)
    related_type VARCHAR(50), -- 关联对象类型
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    INDEX idx_user_sent (user_id, sent_at DESC),
    INDEX idx_is_read (is_read)
);

-- 审计日志表
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    ip_address INET,
    user_agent TEXT,
    changes JSONB, -- 变更详情
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_action (user_id, created_at DESC),
    INDEX idx_action (action)
);

-- 创建索引以优化查询性能
CREATE INDEX idx_timetable_start ON timetable_events(start_time);
CREATE INDEX idx_assignments_due ON assignments(due_date);
CREATE INDEX idx_emails_user_date ON emails(user_id, received_at DESC);
CREATE INDEX idx_activities_date ON ucl_activities(start_time);
```

### 5.2 Redis 缓存策略

```python
# 缓存键命名规范
Cache Keys:
  # 用户会话
  session:{user_id} -> 用户会话数据 (TTL: 7天)

  # API 限流
  ratelimit:{user_id}:{endpoint} -> 请求计数 (TTL: 1分钟)

  # UCL API 缓存
  ucl:timetable:{user_id} -> 课程表 (TTL: 1小时)
  ucl:activities -> 活动列表 (TTL: 30分钟)
  ucl:rooms -> 房间信息 (TTL: 1小时)

  # 邮件缓存
  email:list:{user_id} -> 邮件列表 (TTL: 5分钟)
  email:detail:{email_id} -> 邮件详情 (TTL: 30分钟)

  # 成绩缓存
  grades:{user_id} -> 成绩数据 (TTL: 1小时)

  # AI 缓存 (相同问题缓存答案)
  ai:cache:{query_hash} -> AI 回复 (TTL: 24小时)

# 缓存更新策略
Cache Invalidation:
  - Write-Through: 写入数据库后立即更新缓存
  - Cache-Aside: 读取时先查缓存,miss 则查数据库并更新缓存
  - Pub/Sub: 数据更新时通过 Redis Pub/Sub 通知其他服务清除缓存
```

### 5.3 Qdrant 向量索引

```python
# Collection 配置
Collections:
  # UCL 知识库
  ucl_knowledge:
    vector_size: 1024  # bge-m3 嵌入维度
    distance: Cosine
    payload_schema:
      - document_type: keyword
      - source_url: text
      - created_at: datetime
      - department: keyword
      - tags: keyword[]

  # 历史对话
  chat_history:
    vector_size: 1024
    distance: Cosine
    payload_schema:
      - user_id: keyword
      - session_id: keyword
      - quality_score: float
      - feedback: keyword

  # 邮件语义搜索
  email_embeddings:
    vector_size: 1024
    distance: Cosine
    payload_schema:
      - user_id: keyword
      - category: keyword
      - received_at: datetime
      - sender: text

# 检索策略
Retrieval Strategy:
  - Hybrid Search: 向量搜索 + 关键词搜索 + 元数据过滤
  - Re-ranking: 使用 Cross-Encoder 重排序
  - Query Expansion: 查询扩展 (同义词、相关术语)
```

---

## 6. API 设计

### 6.1 RESTful API 规范

```
Base URL: https://api.uniapp.com/v1

认证方式: Bearer Token (JWT)
请求头:
  Authorization: Bearer <access_token>
  Content-Type: application/json
  Accept-Language: zh-CN,en-US

响应格式:
{
  "success": true,
  "data": {...},
  "message": "操作成功",
  "timestamp": "2025-01-17T10:30:00Z",
  "request_id": "req_abc123"
}

错误响应:
{
  "success": false,
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Token 已过期",
    "details": {...}
  },
  "timestamp": "2025-01-17T10:30:00Z",
  "request_id": "req_abc123"
}
```

### 6.2 API 端点列表

```
# 认证 & 用户管理
POST   /auth/register              # 用户注册
POST   /auth/login                 # 用户登录
POST   /auth/logout                # 用户登出
POST   /auth/refresh               # 刷新 Token
POST   /auth/verify-email          # 验证邮箱
POST   /auth/reset-password        # 重置密码
POST   /auth/mfa/enable            # 启用多因素认证
POST   /auth/mfa/verify            # 验证 MFA 代码

GET    /users/me                   # 获取当前用户信息
PATCH  /users/me                   # 更新用户信息
GET    /users/me/profile           # 获取个人档案
POST   /users/me/avatar            # 上传头像
GET    /users/me/preferences       # 获取用户偏好设置
PATCH  /users/me/preferences       # 更新偏好设置

POST   /students/{id}/link-parent  # 学生关联家长
DELETE /students/{id}/unlink-parent/{parent_id}

# UCL API 代理
GET    /ucl/timetable              # 获取个人课程表
GET    /ucl/timetable/courses/{course_code}  # 获取特定课程时间表
GET    /ucl/activities             # 获取校园活动
GET    /ucl/activities/{id}        # 获取活动详情
POST   /ucl/activities/{id}/register  # 报名活动
GET    /ucl/rooms                  # 获取房间列表
GET    /ucl/rooms/{id}/bookings    # 获取房间预定情况
POST   /ucl/rooms/{id}/book        # 预定房间
GET    /ucl/people/search          # 搜索人员

# 课程 & 成绩
GET    /courses                    # 获取课程列表
GET    /courses/{id}               # 获取课程详情
GET    /courses/{id}/assignments   # 获取作业列表
GET    /courses/{id}/grades        # 获取成绩
POST   /courses/{id}/enroll        # 选课

GET    /assignments                # 获取所有作业
GET    /assignments/{id}           # 获取作业详情
POST   /assignments/{id}/submit    # 提交作业
GET    /assignments/{id}/submission  # 获取提交记录

GET    /grades                     # 获取所有成绩
GET    /grades/summary             # 获取成绩汇总
GET    /grades/analytics           # 获取成绩分析

# 邮件管理
GET    /emails                     # 获取邮件列表 (分页)
GET    /emails/{id}                # 获取邮件详情
PATCH  /emails/{id}                # 更新邮件状态 (已读/星标)
DELETE /emails/{id}                # 删除邮件
POST   /emails                     # 发送邮件
POST   /emails/sync                # 手动同步邮件
GET    /emails/categories          # 获取邮件分类统计
GET    /emails/search              # 搜索邮件

# 日程管理
GET    /calendar/events            # 获取日历事件
POST   /calendar/events            # 创建事件
PATCH  /calendar/events/{id}       # 更新事件
DELETE /calendar/events/{id}       # 删除事件
GET    /calendar/recommendations   # 获取推荐活动

# 健康管理
GET    /health/records             # 获取医疗记录
POST   /health/records             # 添加医疗记录
GET    /health/prescriptions       # 获取处方列表
POST   /health/prescriptions       # 添加处方
GET    /health/metrics             # 获取健康数据
POST   /health/metrics             # 记录健康数据
GET    /health/appointments        # 获取预约列表
POST   /health/appointments        # 创建预约

# AI 助手
POST   /ai/chat                    # 发送消息 (流式响应)
GET    /ai/sessions                # 获取对话列表
GET    /ai/sessions/{id}           # 获取对话历史
DELETE /ai/sessions/{id}           # 删除对话
POST   /ai/feedback                # 提交反馈

# 通知
GET    /notifications              # 获取通知列表
PATCH  /notifications/{id}/read    # 标记为已读
PATCH  /notifications/read-all     # 全部标记为已读
DELETE /notifications/{id}         # 删除通知

# 数据分析 (家长端)
GET    /analytics/academic         # 学业表现分析
GET    /analytics/attendance       # 出勤统计
GET    /analytics/behavior         # 行为分析

# 系统
GET    /health                     # 健康检查
GET    /version                    # 版本信息
```

### 6.3 WebSocket API

```
WebSocket URL: wss://api.uniapp.com/v1/ws

连接认证:
  wss://api.uniapp.com/v1/ws?token=<jwt_token>

消息格式:
{
  "type": "message_type",
  "data": {...},
  "timestamp": "2025-01-17T10:30:00Z"
}

支持的消息类型:

# 客户端 → 服务器
- subscribe: 订阅频道
  {
    "type": "subscribe",
    "data": {
      "channels": ["notifications", "email_updates", "grade_updates"]
    }
  }

- unsubscribe: 取消订阅
- ping: 心跳检测

# 服务器 → 客户端
- notification: 新通知
- email_received: 新邮件
- grade_updated: 成绩更新
- timetable_changed: 课程表变更
- activity_reminder: 活动提醒
- pong: 心跳响应
```

---

## 7. 部署方案

### 7.1 Docker 容器化

```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制代码
COPY . .

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8000/health || exit 1

# 启动服务
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  gateway:
    build: ./gateway
    ports:
      - "8000:8000"
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
      - auth_service
      - ucl_proxy
      - ai_service

  # 认证服务
  auth_service:
    build: ./services/auth
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/uniapp
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - postgres
      - redis

  # UCL 代理服务
  ucl_proxy:
    build: ./services/ucl_proxy
    environment:
      - UCL_API_TOKEN=${UCL_API_TOKEN}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis

  # AI 服务
  ai_service:
    build: ./services/ai
    environment:
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - QDRANT_URL=http://qdrant:6333
    depends_on:
      - qdrant
      - postgres

  # 邮件服务
  email_service:
    build: ./services/email
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/uniapp
    depends_on:
      - postgres
      - rabbitmq

  # Celery Worker (异步任务)
  celery_worker:
    build: ./services/celery
    command: celery -A tasks worker --loglevel=info
    environment:
      - CELERY_BROKER_URL=amqp://rabbitmq:5672
    depends_on:
      - rabbitmq
      - postgres

  # Celery Beat (定时任务)
  celery_beat:
    build: ./services/celery
    command: celery -A tasks beat --loglevel=info
    environment:
      - CELERY_BROKER_URL=amqp://rabbitmq:5672
    depends_on:
      - rabbitmq

  # PostgreSQL
  postgres:
    image: postgres:16
    environment:
      - POSTGRES_DB=uniapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Redis
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

  # Qdrant (向量数据库)
  qdrant:
    image: qdrant/qdrant:latest
    volumes:
      - qdrant_data:/qdrant/storage
    ports:
      - "6333:6333"

  # RabbitMQ
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    ports:
      - "5672:5672"
      - "15672:15672"

  # MinIO (对象存储)
  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=admin
      - MINIO_ROOT_PASSWORD=admin123
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"

volumes:
  postgres_data:
  redis_data:
  qdrant_data:
  minio_data:
```

### 7.2 Kubernetes 部署

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: gateway
        image: uniapp/gateway:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
spec:
  selector:
    app: api-gateway
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 7.3 CI/CD 流程

```yaml
# .github/workflows/deploy.yml
name: Deploy Backend

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Run linters
        run: |
          ruff check .
          mypy .

      - name: Run tests
        run: |
          pytest tests/ --cov=. --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker images
        run: |
          docker-compose build

      - name: Push to registry
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker-compose push

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f k8s/
          kubectl rollout status deployment/api-gateway
```

---

## 8. 安全方案

### 8.1 认证与授权

```python
# JWT 配置
JWT:
  Algorithm: RS256 (非对称加密)
  Access Token TTL: 1 hour
  Refresh Token TTL: 7 days
  Token Payload:
    {
      "sub": "user_id",
      "role": "student",
      "email": "user@ucl.ac.uk",
      "exp": 1705497600,
      "iat": 1705494000,
      "jti": "unique_token_id"
    }

# OAuth2 集成
OAuth2 Providers:
  - Google (UCL Gmail)
  - Microsoft (UCL Outlook)
  - UCL SSO (如果可用)

# RBAC 权限模型
Roles:
  - student: 完整访问自己的数据
  - parent: 有限访问关联学生的数据
  - admin: 系统管理员

Permissions:
  students:
    - read:own_profile
    - write:own_profile
    - read:own_grades
    - read:own_emails
    - write:own_todos

  parents:
    - read:child_grades (需学生授权)
    - read:child_attendance
    - read:child_health (需学生授权)
    - cannot: read:child_emails (隐私保护)

  admins:
    - manage:users
    - manage:system
    - read:audit_logs
```

### 8.2 数据加密

```python
# 传输层加密
TLS 1.3:
  - 所有 API 请求必须使用 HTTPS
  - WebSocket 使用 WSS
  - 证书自动续期 (Let's Encrypt)

# 存储加密
Database Encryption:
  - 敏感字段使用 AES-256-GCM 加密
    * 密码 (bcrypt hash)
    * 健康数据
    * 家长访问令牌
  - PostgreSQL 启用 TDE (透明数据加密)

# 密钥管理
Secrets Management:
  - 使用 Kubernetes Secrets
  - 环境变量注入
  - 定期轮换密钥
  - AWS Secrets Manager / HashiCorp Vault (生产环境)
```

### 8.3 API 安全

```python
# 限流策略
Rate Limiting:
  Global:
    - 100 请求/分钟/IP
  Per User:
    - 认证用户: 300 请求/分钟
    - AI 服务: 20 请求/分钟 (防止滥用)

  使用 Redis 实现 Token Bucket 算法

# 输入验证
Input Validation:
  - Pydantic 严格模式
  - SQL 注入防护 (ORM 参数化查询)
  - XSS 防护 (输出转义)
  - CSRF 防护 (SameSite Cookie)

# 安全头
Security Headers:
  Strict-Transport-Security: max-age=31536000
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Content-Security-Policy: default-src 'self'
  X-XSS-Protection: 1; mode=block
```

### 8.4 隐私保护

```python
# GDPR 合规
GDPR Compliance:
  - 用户数据导出 (JSON 格式)
  - 删除账户时彻底删除数据
  - 数据最小化原则
  - 明确的隐私政策

# 家长端隐私控制
Parent Privacy:
  - 学生必须明确授权家长访问
  - 细粒度权限控制
  - 敏感数据脱敏 (邮件仅显示摘要)
  - 访问日志记录

# 审计日志
Audit Logging:
  - 记录所有敏感操作
  - 保留 90 天
  - 定期审查异常行为
```

---

## 9. 实施计划

### 9.1 阶段一：基础架构搭建 (Week 1-2)

**目标**: 搭建开发环境和基础服务

```
✅ 任务清单:
  1. 创建项目结构
  2. 配置 Docker 开发环境
  3. 搭建 PostgreSQL 数据库
  4. 设计并实现数据库 Schema
  5. 实现认证服务 (JWT)
  6. 实现 API Gateway
  7. 配置 Redis 缓存
  8. 编写基础测试
  9. 配置 CI/CD 流程

📦 交付物:
  - 可运行的开发环境
  - 基础数据库表结构
  - 用户注册/登录 API
  - Docker Compose 配置
  - GitHub Actions CI 配置
```

### 9.2 阶段二：核心服务开发 (Week 3-4)

**目标**: 实现主要业务逻辑

```
✅ 任务清单:
  1. UCL API 代理服务
     - 课程表同步
     - 活动数据获取
     - 房间预定集成

  2. 邮件服务
     - IMAP 同步实现
     - 邮件解析与存储
     - AI 翻译与摘要 (DeepSeek API)

  3. 成绩服务
     - Moodle API 集成
     - WiseFlow 数据抓取
     - 成绩聚合与分析

  4. 日程管理服务
     - 事件 CRUD
     - 日历同步
     - 推荐算法

📦 交付物:
  - 完整的 RESTful API
  - Celery 定时任务
  - 单元测试覆盖率 > 80%
  - API 文档 (OpenAPI/Swagger)
```

### 9.3 阶段三：AI 系统构建 (Week 5-6)

**目标**: 实现智能 AI 助手

```
✅ 任务清单:
  1. 向量数据库搭建
     - Qdrant 部署与配置
     - 文本嵌入模型集成 (bge-m3)

  2. 知识库构建
     - UCL 数据爬虫
     - 数据清洗与预处理
     - 文档分块与索引

  3. RAG 系统实现
     - Hybrid Retrieval
     - Re-ranking 算法
     - Context Augmentation

  4. LLM 集成
     - DeepSeek API 封装
     - 流式响应实现
     - 对话历史管理

  5. Multi-Agent 系统
     - Agent 路由器
     - 学业/邮件/日程 Agent
     - Tool Calling 实现

📦 交付物:
  - 可对话的 AI 助手
  - 向量数据库索引 > 10,000 文档
  - AI 响应时间 < 3 秒
  - 准确率评估报告
```

### 9.4 阶段四：高级功能与优化 (Week 7-8)

**目标**: 完善系统并优化性能

```
✅ 任务清单:
  1. 实时通信
     - WebSocket 服务
     - 实时通知推送
     - APNs 集成

  2. 数据分析
     - 学业表现分析
     - 行为数据统计
     - 报告生成

  3. 家长端功能
     - 学生关联机制
     - 权限控制细化
     - 隐私数据脱敏

  4. 性能优化
     - 数据库查询优化
     - 缓存策略调整
     - API 响应时间优化

  5. 监控与日志
     - Prometheus 指标
     - Grafana 仪表板
     - ELK 日志系统

📦 交付物:
  - 完整的家长端 API
  - WebSocket 实时通知
  - 性能监控仪表板
  - 系统文档
```

### 9.5 阶段五：测试与部署 (Week 9-10)

**目标**: 全面测试并部署到生产环境

```
✅ 任务清单:
  1. 测试
     - 单元测试 (覆盖率 > 90%)
     - 集成测试
     - 端到端测试
     - 性能测试 (压力测试)
     - 安全测试

  2. 文档
     - API 文档完善
     - 部署文档
     - 用户手册
     - 开发者指南

  3. 部署
     - Kubernetes 集群配置
     - 生产环境部署
     - 数据库迁移
     - DNS 配置
     - SSL 证书

  4. 监控
     - 告警规则配置
     - 日志收集
     - 错误追踪

📦 交付物:
  - 生产环境就绪的后端系统
  - 完整的技术文档
  - 运维手册
  - 用户使用指南
```

---

## 10. 技术亮点总结

### 🌟 创新点

1. **智能 RAG 系统**
   - 多源数据融合 (UCL API + 爬虫 + Moodle + 邮件)
   - 实时数据更新与索引
   - Hybrid Retrieval + Re-ranking
   - 知识图谱推理

2. **Multi-Agent 架构**
   - 专业化 Agent (学业/邮件/日程)
   - Tool Calling 能力
   - Agent 协作机制

3. **实时数据同步**
   - WebSocket 双向通信
   - 事件驱动架构
   - 智能缓存预热

4. **家长端协同**
   - 细粒度权限控制
   - 隐私数据保护
   - 实时监控与通知

### 🚀 性能指标

- **API 响应时间**: < 200ms (P95)
- **AI 响应时间**: < 3s
- **并发支持**: 10,000+ 用户
- **系统可用性**: 99.9% SLA
- **缓存命中率**: > 90%
- **数据库查询**: < 50ms

### 🔒 安全保障

- JWT + OAuth2 认证
- 多因素认证 (MFA)
- RBAC 权限控制
- TLS 1.3 加密
- API 限流保护
- SQL 注入防护
- XSS/CSRF 防护
- 审计日志记录

### 📈 可扩展性

- 微服务架构
- 水平扩展能力
- 容器化部署
- Kubernetes 编排
- 自动扩缩容
- 服务发现与负载均衡

---

## 11. 下一步行动

### 立即开始

1. **确认技术栈** - 是否同意上述技术选型？
2. **确认部署方案** - 本地开发 / 云服务 (AWS/GCP/Azure)?
3. **确认 API 密钥** - DeepSeek / OpenAI / UCL API Token
4. **开始实施** - 按照阶段一计划开始构建

### 需要决策的问题

1. **AI 模型选择**:
   - DeepSeek-V3 (性价比高, 中文优秀)
   - GPT-4o (性能最强, 成本较高)
   - Claude 3.5 Sonnet (平衡之选)
   - 还是混合使用?

2. **部署环境**:
   - 本地开发 (Docker Compose)
   - 云服务 (AWS ECS / GCP Cloud Run / Azure Container Apps)
   - Kubernetes (EKS / GKE / AKS)

3. **数据库托管**:
   - 自建 PostgreSQL
   - 云数据库 (RDS / Cloud SQL / Azure Database)

4. **向量数据库**:
   - 自建 Qdrant
   - Pinecone (托管服务)
   - Weaviate (开源替代)

---

**这个方案是一个企业级的完整后端系统设计,远超简单的 API 代理。你觉得如何?需要调整哪些部分?还是直接开始实施?** 🚀
