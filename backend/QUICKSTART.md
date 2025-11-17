# ⚡ Quick Start Guide

快速启动 UniApp 后端系统（5 分钟）

## 第一步：准备环境变量

```bash
cd /home/user/uniapp_v2/backend
cp .env.example .env
```

编辑 `.env` 文件，**至少**配置以下必需项：

```bash
# 必需：JWT 密钥（随机字符串）
JWT_SECRET_KEY=your-random-secret-key-at-least-32-characters-long

# 必需：UCL API Token
UCL_API_TOKEN=uclapi-57b768cb3e4b8cc-2499552a17ad299-7ae012c12b7f9c3-1b31c15b5866279

# 必需：DeepSeek API Key（可选，如果不用 AI 功能可以不配置）
DEEPSEEK_API_KEY=sk-your-deepseek-api-key-here
```

## 第二步：启动所有服务

```bash
# 使用启动脚本（推荐）
bash scripts/start.sh

# 或直接使用 docker-compose
docker-compose up -d
```

## 第三步：验证服务

```bash
# 检查健康状态
curl http://localhost:8000/health

# 应该返回:
# {"status":"healthy","service":"gateway","environment":"development","version":"1.0.0"}
```

## 第四步：访问 API 文档

在浏览器中打开：
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 第五步：测试 API

### 1. 注册用户

```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@ucl.ac.uk",
    "password": "SecurePassword123!",
    "full_name": "Test Student",
    "role": "student",
    "ucl_id": "TEST001"
  }'
```

### 2. 登录获取 Token

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@ucl.ac.uk",
    "password": "SecurePassword123!"
  }'
```

保存返回的 `access_token`

### 3. 使用 Token 访问受保护接口

```bash
# 替换 YOUR_TOKEN 为上一步获取的 access_token
export TOKEN="YOUR_TOKEN"

curl http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 测试 AI 聊天

```bash
curl -X POST http://localhost:8000/api/v1/ai/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "你好，请介绍一下 UCL 的课程安排",
    "stream": false
  }'
```

### 5. 测试 UCL API 代理

```bash
# 获取房间列表
curl http://localhost:8000/api/v1/ucl/rooms \
  -H "Authorization: Bearer $TOKEN"

# 搜索人员
curl "http://localhost:8000/api/v1/ucl/search/people?q=john" \
  -H "Authorization: Bearer $TOKEN"
```

## 常用命令

```bash
# 查看日志
docker-compose logs -f gateway        # Gateway 日志
docker-compose logs -f auth_service   # 认证服务日志
docker-compose logs -f                # 所有服务日志

# 重启服务
docker-compose restart gateway
docker-compose restart

# 停止所有服务
docker-compose down

# 停止并删除数据
docker-compose down -v

# 查看服务状态
docker-compose ps

# 进入数据库
docker-compose exec postgres psql -U uniapp -d uniapp

# 进入 Redis
docker-compose exec redis redis-cli
```

## 🎉 完成！

你现在有一个完整运行的企业级后端系统！

### 接下来可以做什么？

1. **查看 API 文档**: http://localhost:8000/docs
2. **测试更多 API**: 使用 Postman 或 curl
3. **查看数据库**: 使用 TablePlus 或 pgAdmin 连接到 localhost:5432
4. **监控系统**:
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090
   - RabbitMQ: http://localhost:15672 (guest/guest)

### 遇到问题？

查看 [README.md](./README.md) 的故障排除部分，或查看日志：

```bash
docker-compose logs -f --tail=100
```

---

**Have fun building! 🚀**
