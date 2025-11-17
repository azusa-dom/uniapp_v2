# UCL UniApp Backend API 使用指南

## 概述

本API为UCL留学生和家长端移动平台提供后端服务,支持用户认证、学术数据管理、邮箱同步、活动推荐和AI智能助手等功能。

## 基础信息

- **Base URL**: `http://your-domain.com/api/v1`
- **Authentication**: JWT Bearer Token
- **Content-Type**: `application/json`

## 快速开始

### 1. 用户注册

```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@ucl.ac.uk",
    "password": "SecurePassword123",
    "full_name": "Zhang San",
    "role": "student",
    "ucl_id": "ucxxxxx",
    "program": "MSc Health Data Science",
    "department": "Institute of Health Informatics"
  }'
```

### 2. 用户登录

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=student@ucl.ac.uk&password=SecurePassword123"
```

响应示例:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 3. 使用Token访问受保护端点

在后续请求中添加Authorization header:

```bash
curl -X GET http://localhost:8000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## API端点详解

### 认证 Authentication

#### POST /auth/register
注册新用户(学生或家长)

**请求体**:
```json
{
  "email": "string",
  "password": "string (min 8 chars)",
  "full_name": "string",
  "role": "student | parent",
  "ucl_id": "string (optional, for students)",
  "phone": "string (optional)",
  "department": "string (optional)",
  "program": "string (optional)",
  "year_of_study": "integer (optional)"
}
```

#### POST /auth/login
用户登录

**请求体** (form-data):
```
username: email@ucl.ac.uk
password: your-password
```

#### POST /auth/refresh
刷新访问令牌

**请求体**:
```json
{
  "refresh_token": "string"
}
```

#### GET /auth/me
获取当前用户信息

**Headers**: `Authorization: Bearer {token}`

---

### 用户管理 Users

#### GET /users/profile
获取用户资料

#### PUT /users/profile
更新用户资料

**请求体**:
```json
{
  "full_name": "string (optional)",
  "phone": "string (optional)",
  "department": "string (optional)",
  "program": "string (optional)",
  "year_of_study": "integer (optional)"
}
```

#### POST /users/link-student
关联学生账户(仅家长)

**请求体**:
```json
{
  "student_email": "student@ucl.ac.uk",
  "relationship_type": "guardian"
}
```

#### GET /users/students
获取关联的学生列表(仅家长)

#### GET /users/parents
获取关联的家长列表(仅学生)

---

### UCL数据 UCL Data

#### GET /ucl/timetable/personal
获取个人课程表

**响应示例**:
```json
{
  "timetable": [
    {
      "module_name": "Data Science and Statistics",
      "module_id": "CHME0007",
      "start_time": "2024-11-10T09:30:00",
      "end_time": "2024-11-10T11:30:00",
      "location": {
        "name": "Foster Court, Room 114"
      },
      "session_type": "Lecture"
    }
  ]
}
```

#### GET /ucl/timetable/modules
按模块代码获取课程表

**参数**:
- `modules`: 逗号分隔的模块代码 (e.g., "CHME0007,CHME0006")

#### GET /ucl/rooms
查询教室信息

**参数**:
- `roomname`: 教室名称 (optional)
- `roomid`: 教室ID (optional)
- `siteid`: 校区ID (optional)

#### GET /ucl/rooms/bookings
查询教室预订

**参数**:
- `roomid`: 教室ID (required)
- `siteid`: 校区ID (required)
- `start_datetime`: 开始时间 ISO格式 (optional)
- `end_datetime`: 结束时间 ISO格式 (optional)

#### GET /ucl/search/people
搜索UCL人员

**参数**:
- `query`: 搜索关键词 (required)

---

### 邮箱 Emails

#### POST /emails/sync
同步UCL Outlook邮箱

**注意**: 需要配置OAuth2认证

#### GET /emails/
获取邮件列表

**参数**:
- `category`: urgent | academic | events | administrative (optional)
- `is_read`: true | false (optional)
- `limit`: 数量限制, 默认50
- `offset`: 偏移量, 默认0

**响应示例**:
```json
[
  {
    "id": 1,
    "subject": "Assignment Deadline Extended",
    "sender": "s.johnson@ucl.ac.uk",
    "sender_name": "Dr. Sarah Johnson",
    "excerpt": "Dear Students, Due to technical issues...",
    "category": "urgent",
    "is_read": false,
    "received_at": "2024-11-10T10:30:00"
  }
]
```

#### GET /emails/{email_id}
获取邮件详情

#### POST /emails/{email_id}/summarize
生成AI邮件摘要

**响应示例**:
```json
{
  "ai_summary": "作业截止日期延期至11月10日23:59...",
  "success": true
}
```

#### PATCH /emails/{email_id}/mark-read
标记邮件为已读/未读

**请求体**:
```json
{
  "is_read": true
}
```

---

### 学术 Academics

#### GET /academics/courses
获取所有课程

**响应示例**:
```json
[
  {
    "id": 1,
    "course_code": "CHME0007",
    "course_name": "Data Science and Statistics",
    "department": "Health Data Science",
    "credits": 15,
    "current_grade": 78.5,
    "module_average": 72.0,
    "instructor_name": "Dr. Sarah Johnson"
  }
]
```

#### GET /academics/courses/{course_id}/assignments
获取课程作业

#### GET /academics/assignments/upcoming
获取即将截止的作业

**参数**:
- `limit`: 数量限制, 默认10

**响应示例**:
```json
[
  {
    "id": 1,
    "name": "Statistical Analysis Assignment",
    "course_id": 1,
    "due_date": "2024-11-15T23:59:00",
    "submitted": false,
    "weight": 30.0
  }
]
```

#### POST /academics/sync/moodle
从Moodle同步数据

#### GET /academics/grades/summary
获取成绩汇总

**响应示例**:
```json
{
  "overall_average": 75.8,
  "courses": [
    {
      "course_code": "CHME0007",
      "course_name": "Data Science and Statistics",
      "current_grade": 78.5,
      "module_average": 72.0,
      "credits": 15
    }
  ]
}
```

---

### 活动 Activities

#### GET /activities/
获取活动列表

**参数**:
- `activity_type`: academic | cultural | sport | social | career | lecture | seminar (optional)
- `start_date`: ISO格式日期 (optional)
- `end_date`: ISO格式日期 (optional)
- `limit`: 默认50

**响应示例**:
```json
[
  {
    "id": 1,
    "title": "Health Data Science Career Fair",
    "description": "Meet leading employers...",
    "activity_type": "career",
    "location": "Wilkins Building, South Cloisters",
    "start_time": "2024-11-15T13:00:00",
    "end_time": "2024-11-15T17:00:00",
    "is_free": true,
    "registration_required": true,
    "is_recommended": true
  }
]
```

#### GET /activities/recommended
获取推荐活动

**参数**:
- `limit`: 默认10

**响应示例**:
```json
[
  {
    "id": 1,
    "title": "AI in Healthcare Lecture",
    "activity_type": "lecture",
    "location": "Roberts Building",
    "start_time": "2024-11-12T14:00:00",
    "recommendation_score": 0.92,
    "recommendation_reason": "基于您的健康数据科学专业推荐"
  }
]
```

#### GET /activities/upcoming
获取即将举行的活动

**参数**:
- `days`: 未来天数, 默认7
- `limit`: 默认20

#### POST /activities/{activity_id}/bookmark
收藏/取消收藏活动

**请求体**:
```json
{
  "bookmarked": true
}
```

#### POST /activities/{activity_id}/register
注册参加活动

---

### AI助手 AI Assistant

#### POST /ai/chat
与AI助手对话

**请求体**:
```json
{
  "message": "我这周有哪些作业要交？",
  "conversation_id": 1
}
```

**响应示例**:
```json
{
  "conversation_id": 1,
  "response": "根据您的课程信息，本周您有以下作业需要提交：\n\n1. 📝 **数据方法与健康研究 (CHME0013)** - 研究设计报告\n   截止时间：11月20日 23:59\n\n2. 📝 **Python 健康研究编程 (CHME0011)** - 脚本优化练习\n   截止时间：11月15日 23:59\n\n建议您优先完成11月15日的Python作业，距离截止还有3天。需要帮助规划学习时间吗？",
  "model": "deepseek-chat",
  "processing_time": 2.45,
  "sources": ["courses", "assignments", "timetable"]
}
```

**特点**:
- 基于实时UCL数据回答
- 支持中英双语
- 提供个性化建议
- 自动整合课程、作业、活动等信息

#### GET /ai/conversations
获取对话历史

**参数**:
- `limit`: 默认20

#### GET /ai/conversations/{conversation_id}/messages
获取对话消息

#### DELETE /ai/conversations/{conversation_id}
删除对话

---

## 错误处理

### 通用错误响应

```json
{
  "detail": "错误信息"
}
```

### 常见HTTP状态码

- `200 OK`: 请求成功
- `201 Created`: 资源创建成功
- `400 Bad Request`: 请求参数错误
- `401 Unauthorized`: 未认证或token无效
- `403 Forbidden`: 无权限访问
- `404 Not Found`: 资源不存在
- `500 Internal Server Error`: 服务器错误

### 示例错误

```json
{
  "detail": "Could not validate credentials"
}
```

```json
{
  "detail": "Email already registered"
}
```

---

## 最佳实践

### 1. Token管理

- 安全存储access_token和refresh_token
- access_token过期后使用refresh_token获取新token
- 不要在URL中传递token

### 2. 错误处理

```python
import requests

def call_api(endpoint, token):
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/{endpoint}", headers=headers)

    if response.status_code == 401:
        # Token过期，刷新token
        new_token = refresh_access_token()
        return call_api(endpoint, new_token)

    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"API Error: {response.json()['detail']}")
```

### 3. 分页

对于大量数据，使用limit和offset参数:

```bash
# 获取第一页(1-50)
GET /api/v1/emails/?limit=50&offset=0

# 获取第二页(51-100)
GET /api/v1/emails/?limit=50&offset=50
```

### 4. 过滤

合理使用查询参数过滤数据:

```bash
# 仅获取未读的紧急邮件
GET /api/v1/emails/?category=urgent&is_read=false

# 获取本周的学术活动
GET /api/v1/activities/?activity_type=academic&start_date=2024-11-10&end_date=2024-11-17
```

---

## Swift集成示例

```swift
import Foundation

class APIClient {
    static let shared = APIClient()
    let baseURL = "http://your-domain.com/api/v1"
    var accessToken: String?

    func login(email: String, password: String) async throws -> TokenResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "username=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = response.access_token
        return response
    }

    func getUpcomingAssignments() async throws -> [Assignment] {
        let url = URL(string: "\(baseURL)/academics/assignments/upcoming")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Assignment].self, from: data)
    }

    func chatWithAI(message: String, conversationId: Int?) async throws -> ChatResponse {
        let url = URL(string: "\(baseURL)/ai/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ChatRequest(message: message, conversation_id: conversationId)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ChatResponse.self, from: data)
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String
}

struct Assignment: Codable {
    let id: Int
    let name: String
    let due_date: String
}

struct ChatRequest: Codable {
    let message: String
    let conversation_id: Int?
}

struct ChatResponse: Codable {
    let conversation_id: Int
    let response: String
}
```

---

## 支持

- API文档: `/docs` (Swagger UI)
- 技术支持: GitHub Issues
- 邮箱: support@yourdomain.com

---

**注意**: 本文档持续更新中。如有疑问或发现错误，请提交Issue。
