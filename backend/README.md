# UCL UniApp Backend API

一个为UCL留学生和家长端设计的综合移动平台后端系统。

## 功能特性

### 🔐 用户认证和授权
- JWT Token 认证
- 学生和家长角色管理
- 家长-学生账户关联

### 📧 邮箱同步
- 通过IMAP同步UCL Outlook邮箱
- AI自动分类邮件（紧急、学术、活动等）
- AI智能摘要和中文翻译

### 📚 学术数据管理
- Moodle课程同步
- 作业和截止日期跟踪
- 成绩管理和分析
- UCL课程表集成

### 🎯 活动推荐
- UCL官方活动数据集成
- 基于用户画像的个性化推荐
- 活动预约和收藏

### 🤖 AI智能助手
- RAG (检索增强生成) 技术
- 基于实时UCL数据的准确回答
- 支持中英双语对话
- 学习规划和时间管理建议

### 📊 UCL数据集成
- UCL API 数据代理
- 教室预订查询
- 校园地图和位置服务
- 人员搜索

## 技术栈

- **Web Framework**: FastAPI 0.109+
- **Database**: PostgreSQL with SQLAlchemy 2.0 (async)
- **Authentication**: JWT (python-jose)
- **AI Services**: DeepSeek API / OpenAI API
- **Email**: IMAP (imaplib2)
- **Caching**: Redis
- **API Integration**: UCL API, Moodle Web Service API

## 项目结构

```
backend/
├── app/
│   ├── api/                  # API路由
│   │   ├── auth.py          # 认证endpoints
│   │   ├── users.py         # 用户管理
│   │   ├── ucl.py           # UCL数据
│   │   ├── emails.py        # 邮箱同步
│   │   ├── academics.py     # 学术数据
│   │   ├── activities.py    # 活动管理
│   │   └── ai_assistant.py  # AI助手
│   ├── models/              # 数据库模型
│   │   ├── user.py
│   │   ├── email.py
│   │   ├── academic.py
│   │   ├── activity.py
│   │   └── ai_conversation.py
│   ├── services/            # 业务逻辑层
│   │   ├── ucl_api_service.py
│   │   ├── email_service.py
│   │   ├── moodle_service.py
│   │   └── ai_assistant_service.py
│   ├── schemas/             # Pydantic schemas
│   ├── middleware/          # 中间件
│   ├── utils/               # 工具函数
│   └── database.py          # 数据库配置
├── config.py                # 配置管理
├── main.py                  # 应用入口
├── requirements.txt         # Python依赖
└── .env.example            # 环境变量示例

```

## 快速开始

### 1. 环境要求

- Python 3.10+
- PostgreSQL 14+
- Redis 6+

### 2. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，填入必要的配置
```

必需的环境变量:
- `DATABASE_URL`: PostgreSQL连接字符串
- `SECRET_KEY`: JWT密钥
- `UCL_API_TOKEN`: UCL API token
- `MOODLE_BASE_URL` and `MOODLE_WS_TOKEN`: Moodle配置
- `DEEPSEEK_API_KEY` 或 `OPENAI_API_KEY`: AI服务密钥

### 4. 初始化数据库

```bash
# 数据库会在首次运行时自动创建表
python main.py
```

### 5. 运行服务器

```bash
# 开发模式
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# 生产模式
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### 6. 访问API文档

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API 端点概览

### 认证 (Authentication)
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/refresh` - 刷新token
- `GET /api/v1/auth/me` - 获取当前用户信息

### 用户管理 (Users)
- `GET /api/v1/users/profile` - 获取用户资料
- `PUT /api/v1/users/profile` - 更新用户资料
- `POST /api/v1/users/link-student` - 关联学生账户（家长）
- `GET /api/v1/users/students` - 获取关联的学生列表

### UCL数据 (UCL Data)
- `GET /api/v1/ucl/timetable/personal` - 获取个人课程表
- `GET /api/v1/ucl/rooms` - 查询教室信息
- `GET /api/v1/ucl/rooms/bookings` - 查询教室预订
- `GET /api/v1/ucl/search/people` - 搜索人员

### 邮箱 (Emails)
- `POST /api/v1/emails/sync` - 同步邮箱
- `GET /api/v1/emails/` - 获取邮件列表
- `GET /api/v1/emails/{email_id}` - 获取邮件详情
- `POST /api/v1/emails/{email_id}/summarize` - AI邮件摘要

### 学术 (Academics)
- `GET /api/v1/academics/courses` - 获取课程列表
- `GET /api/v1/academics/assignments/upcoming` - 获取即将截止的作业
- `POST /api/v1/academics/sync/moodle` - 同步Moodle数据
- `GET /api/v1/academics/grades/summary` - 获取成绩汇总

### 活动 (Activities)
- `GET /api/v1/activities/` - 获取活动列表
- `GET /api/v1/activities/recommended` - 获取推荐活动
- `GET /api/v1/activities/upcoming` - 获取即将举行的活动
- `POST /api/v1/activities/{id}/bookmark` - 收藏活动

### AI助手 (AI Assistant)
- `POST /api/v1/ai/chat` - AI对话
- `GET /api/v1/ai/conversations` - 获取对话历史
- `GET /api/v1/ai/conversations/{id}/messages` - 获取对话消息

## 数据库模型

### User (用户)
- 支持学生和家长两种角色
- 存储UCL API、Moodle token等认证信息
- 支持家长-学生多对多关联

### Email (邮件)
- 邮件元数据和内容
- AI生成的摘要和翻译
- 自动分类（urgent, academic, events等）

### Course (课程)
- 课程基本信息
- Moodle集成
- 成绩跟踪

### Assignment (作业)
- 作业详情和截止日期
- 提交状态
- 成绩和反馈

### Activity (活动)
- UCL官方活动
- 个性化推荐
- 活动预约和收藏

### Conversation & Message (AI对话)
- 对话会话管理
- 消息历史
- RAG上下文跟踪

## AI助手特性

### RAG (检索增强生成)
AI助手使用RAG技术，结合实时UCL数据提供准确答案：

1. **实时数据集成**
   - 用户的课程和成绩
   - 即将到来的作业和截止日期
   - 本周课程表
   - 推荐的校园活动
   - 重要邮件提醒

2. **上下文感知**
   - 基于用户专业和课程定制回答
   - 理解对话历史
   - 提供具体可行的建议

3. **双语支持**
   - 自动识别中英文输入
   - 简体中文回复
   - 专业术语准确翻译

## 安全性

- JWT Token 认证
- 密码bcrypt加密存储
- CORS保护
- 请求速率限制（可选）
- SQL注入防护（SQLAlchemy ORM）

## 性能优化

- 异步I/O (FastAPI + asyncpg)
- Redis缓存（可选）
- 数据库连接池
- 背景任务处理

## 部署

### Docker部署 (推荐)

```bash
# 构建镜像
docker build -t uniapp-backend .

# 运行容器
docker run -d \
  --name uniapp-backend \
  -p 8000:8000 \
  --env-file .env \
  uniapp-backend
```

### 使用Docker Compose

```bash
docker-compose up -d
```

### 传统部署

使用gunicorn + nginx:

```bash
# 安装gunicorn
pip install gunicorn

# 运行
gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000
```

## 环境变量说明

| 变量名 | 说明 | 必需 |
|-------|------|------|
| `DATABASE_URL` | PostgreSQL数据库连接 | 是 |
| `SECRET_KEY` | JWT密钥 | 是 |
| `UCL_API_TOKEN` | UCL API访问token | 是 |
| `MOODLE_BASE_URL` | Moodle服务器地址 | 是 |
| `MOODLE_WS_TOKEN` | Moodle Web Service token | 是 |
| `DEEPSEEK_API_KEY` | DeepSeek AI API密钥 | 二选一 |
| `OPENAI_API_KEY` | OpenAI API密钥 | 二选一 |
| `REDIS_URL` | Redis连接（可选） | 否 |
| `EMAIL_IMAP_SERVER` | IMAP服务器地址 | 是 |
| `EMAIL_SMTP_SERVER` | SMTP服务器地址 | 是 |

## 开发指南

### 运行测试

```bash
pytest
```

### 代码格式化

```bash
black .
flake8 .
```

### 类型检查

```bash
mypy app
```

## 故障排除

### 数据库连接失败

检查PostgreSQL是否运行，DATABASE_URL配置是否正确

### UCL API调用失败

确认UCL_API_TOKEN有效，检查网络连接

### Moodle同步失败

验证Moodle token和Web Service是否启用

### AI响应错误

检查API密钥配置，确认有足够的配额

## 贡献

欢迎提交Issue和Pull Request!

## 许可证

MIT License

## 联系方式

如有问题，请通过GitHub Issues联系。

---

**注意**: 此项目用于教育目的。在生产环境使用前，请确保：
1. 使用强密钥和安全的认证机制
2. 配置正确的CORS策略
3. 启用HTTPS
4. 实施适当的速率限制
5. 定期备份数据库
6. 遵守UCL的API使用条款和数据隐私政策
