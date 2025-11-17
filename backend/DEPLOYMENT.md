# UCL UniApp Backend 部署指南

本文档提供了详细的生产环境部署指南。

## 目录

1. [系统要求](#系统要求)
2. [环境准备](#环境准备)
3. [Docker部署(推荐)](#docker部署推荐)
4. [传统部署](#传统部署)
5. [数据库迁移](#数据库迁移)
6. [配置Nginx反向代理](#配置nginx反向代理)
7. [HTTPS配置](#https配置)
8. [监控和日志](#监控和日志)
9. [备份策略](#备份策略)
10. [故障排除](#故障排除)

## 系统要求

### 最低配置
- CPU: 2核
- 内存: 4GB RAM
- 硬盘: 20GB SSD
- 操作系统: Ubuntu 20.04+ / CentOS 8+ / macOS

### 推荐配置
- CPU: 4核
- 内存: 8GB RAM
- 硬盘: 50GB SSD
- 操作系统: Ubuntu 22.04 LTS

### 软件依赖
- Docker 20.10+ 和 Docker Compose 2.0+ (Docker部署)
- 或 Python 3.10+, PostgreSQL 14+, Redis 6+ (传统部署)
- Nginx 1.18+

## 环境准备

### 1. 更新系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 2. 安装Docker和Docker Compose

```bash
# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version
```

### 3. 配置防火墙

```bash
# Ubuntu UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable

# CentOS firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## Docker部署(推荐)

### 1. 克隆代码

```bash
git clone https://github.com/your-repo/uniapp_v2.git
cd uniapp_v2/backend
```

### 2. 配置环境变量

```bash
cp .env.example .env
nano .env
```

编辑必要的环境变量:

```env
# 修改为强密钥
SECRET_KEY=your-super-secret-key-change-this-in-production

# UCL API配置
UCL_API_TOKEN=your-ucl-api-token

# Moodle配置
MOODLE_BASE_URL=https://moodle.ucl.ac.uk
MOODLE_WS_TOKEN=your-moodle-token

# AI服务(至少配置一个)
DEEPSEEK_API_KEY=your-deepseek-key
OPENAI_API_KEY=your-openai-key

# 生产环境设置
DEBUG=False
ENVIRONMENT=production
```

### 3. 启动服务

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 检查服务状态
docker-compose ps
```

### 4. 验证部署

```bash
# 检查健康状态
curl http://localhost:8000/health

# 访问API文档 (生产环境建议禁用)
curl http://localhost:8000/docs
```

### 5. Docker管理命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看实时日志
docker-compose logs -f backend

# 进入容器
docker-compose exec backend bash

# 更新服务
git pull
docker-compose build
docker-compose up -d
```

## 传统部署

### 1. 安装PostgreSQL

```bash
# Ubuntu
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 创建数据库
sudo -u postgres psql
CREATE DATABASE uniapp;
CREATE USER uniapp_user WITH PASSWORD 'strong-password';
GRANT ALL PRIVILEGES ON DATABASE uniapp TO uniapp_user;
\q
```

### 2. 安装Redis

```bash
# Ubuntu
sudo apt install redis-server
sudo systemctl start redis
sudo systemctl enable redis
```

### 3. 安装Python依赖

```bash
cd backend

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 4. 配置环境变量

```bash
cp .env.example .env
nano .env
```

更新DATABASE_URL:
```env
DATABASE_URL=postgresql+asyncpg://uniapp_user:strong-password@localhost:5432/uniapp
```

### 5. 使用Systemd管理服务

创建systemd服务文件:

```bash
sudo nano /etc/systemd/system/uniapp-backend.service
```

添加以下内容:

```ini
[Unit]
Description=UCL UniApp Backend API
After=network.target postgresql.service redis.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/path/to/uniapp_v2/backend
Environment="PATH=/path/to/uniapp_v2/backend/venv/bin"
ExecStart=/path/to/uniapp_v2/backend/venv/bin/gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --access-logfile /var/log/uniapp/access.log \
  --error-logfile /var/log/uniapp/error.log
Restart=always

[Install]
WantedBy=multi-user.target
```

启动服务:

```bash
# 创建日志目录
sudo mkdir -p /var/log/uniapp
sudo chown www-data:www-data /var/log/uniapp

# 重载systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start uniapp-backend
sudo systemctl enable uniapp-backend

# 检查状态
sudo systemctl status uniapp-backend
```

## 配置Nginx反向代理

### 1. 安装Nginx

```bash
sudo apt install nginx
```

### 2. 配置Nginx站点

```bash
sudo nano /etc/nginx/sites-available/uniapp-backend
```

添加以下配置:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 静态文件(如果需要)
    location /static {
        alias /path/to/uniapp_v2/backend/static;
        expires 30d;
    }

    # 健康检查
    location /health {
        access_log off;
        proxy_pass http://127.0.0.1:8000/health;
    }
}
```

启用站点:

```bash
sudo ln -s /etc/nginx/sites-available/uniapp-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## HTTPS配置

### 使用Let's Encrypt(免费)

```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d api.yourdomain.com

# 自动续期
sudo certbot renew --dry-run
```

Nginx配置会自动更新为HTTPS。

## 监控和日志

### 1. 应用日志

```bash
# Docker部署
docker-compose logs -f backend

# 传统部署
tail -f /var/log/uniapp/access.log
tail -f /var/log/uniapp/error.log
```

### 2. 系统资源监控

```bash
# 安装htop
sudo apt install htop

# 查看资源使用
htop

# Docker资源使用
docker stats
```

### 3. 使用Prometheus和Grafana(可选)

FastAPI内置Prometheus指标支持,可以配置专业的监控系统。

## 备份策略

### 1. 数据库备份

```bash
# 创建备份脚本
sudo nano /usr/local/bin/backup-uniapp-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/uniapp"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# PostgreSQL备份
docker exec uniapp_postgres pg_dump -U postgres uniapp > $BACKUP_DIR/uniapp_$DATE.sql

# 压缩备份
gzip $BACKUP_DIR/uniapp_$DATE.sql

# 删除30天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
sudo chmod +x /usr/local/bin/backup-uniapp-db.sh
```

### 2. 配置Cron定时备份

```bash
sudo crontab -e
```

添加:
```
# 每天凌晨2点备份
0 2 * * * /usr/local/bin/backup-uniapp-db.sh
```

### 3. 上传到云存储(可选)

使用rclone上传到AWS S3、Google Drive等。

## 故障排除

### 问题1: 服务无法启动

```bash
# 检查日志
docker-compose logs backend

# 检查端口占用
sudo netstat -tlnp | grep 8000

# 检查配置文件
docker-compose config
```

### 问题2: 数据库连接失败

```bash
# 检查PostgreSQL状态
docker-compose ps postgres

# 检查数据库连接
docker-compose exec postgres psql -U postgres -d uniapp -c "SELECT 1;"

# 查看数据库日志
docker-compose logs postgres
```

### 问题3: 内存不足

```bash
# 限制Docker容器内存
# 在docker-compose.yml中添加:
services:
  backend:
    mem_limit: 2g
    memswap_limit: 2g
```

### 问题4: API响应慢

- 检查数据库查询性能
- 启用Redis缓存
- 增加worker数量
- 优化SQL查询

## 安全建议

1. **更改默认密钥**
   - SECRET_KEY使用强随机字符串
   - 数据库密码使用强密码

2. **限制访问**
   - 配置防火墙规则
   - 使用fail2ban防止暴力破解
   - 仅允许必要的端口

3. **定期更新**
   - 及时更新系统和依赖包
   - 关注安全公告

4. **日志审计**
   - 定期检查访问日志
   - 监控异常请求

5. **备份**
   - 定期备份数据库
   - 测试备份恢复流程

## 性能优化

1. **数据库优化**
   - 创建适当的索引
   - 定期VACUUM
   - 配置连接池

2. **应用优化**
   - 启用Redis缓存
   - 使用CDN加速静态资源
   - 配置Gzip压缩

3. **服务器优化**
   - 调整worker数量
   - 配置nginx缓存
   - 使用HTTP/2

## 生产环境检查清单

- [ ] 修改所有默认密码和密钥
- [ ] 配置HTTPS
- [ ] 配置防火墙
- [ ] 设置数据库备份
- [ ] 配置日志轮转
- [ ] 禁用调试模式 (DEBUG=False)
- [ ] 配置CORS白名单
- [ ] 测试灾难恢复流程
- [ ] 配置监控告警
- [ ] 文档化部署流程

## 支持

如遇到问题,请查看:
- 应用日志
- GitHub Issues
- 官方文档

---

**重要提示**: 生产环境部署前,务必在测试环境完整测试所有功能!
