# OpenClaw FNOS 一键部署指南

## 快速开始（3 步完成）

### 步骤 1: SSH 连接到 FNOS

```bash
ssh your-username@fnos-ip
```

### 步骤 2: 执行一键部署

```bash
# 下载并执行部署脚本
curl -fsSL https://raw.githubusercontent.com/snrzz/clawStdy/main/deploy.sh -o deploy.sh
bash deploy.sh
```

或者手动部署：

```bash
# 克隆代码
mkdir -p ~/openclaw
cd ~/openclaw
git clone https://github.com/snrzz/clawStdy.git .

# 配置环境
cp .env.example .env
# 编辑 .env 文件，设置 OPENCLAW_GATEWAY_TOKEN

# 构建并启动
docker compose build
docker compose up -d
```

### 步骤 3: 访问 Web UI

打开浏览器访问：`http://<fnos-ip>:18789/_/`

---

## 详细说明

### 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 18789 | Gateway | 主服务端口 |
| 18790 | Bridge | 内部桥接端口 |

### 配置说明

主要配置文件：

| 文件 | 说明 |
|------|------|
| `.env` | 环境变量（敏感配置） |
| `docker-compose.yml` | 服务配置 |
| `Dockerfile` | 镜像构建 |

### 环境变量

编辑 `.env` 文件：

```bash
# 必填: Gateway Token（必须修改！）
OPENCLAW_GATEWAY_TOKEN=your-secure-token

# 可选: API Keys
# ANTHROPIC_API_KEY=sk-ant-api03-xxx

# 可选: 端口配置
OPENCLAW_GATEWAY_PORT=18789
```

生成安全的 Token：
```bash
openssl rand -base64 32
```

---

## 管理命令

```bash
# 进入目录
cd ~/openclaw

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f          # 所有服务
docker compose logs -f openclaw-gateway  # 仅 Gateway

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 更新并重启
git pull
docker compose down
docker compose build
docker compose up -d
```

---

## 故障排除

### 问题 1: 端口被占用

```bash
# 检查端口
ss -tlnp | grep 18789

# 修改端口（编辑 .env）
echo "OPENCLAW_GATEWAY_PORT=18790" >> .env
docker compose restart
```

### 问题 2: 权限错误

```bash
# 修复权限
sudo chown -R 1000:1000 ~/openclaw/.openclaw
docker compose restart
```

### 问题 3: 构建失败

```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建
docker compose build --no-cache
docker compose up -d
```

### 问题 4: 无法访问

```bash
# 检查防火墙
sudo firewall-cmd --list-ports
# 或
sudo ufw status

# 开放端口
sudo firewall-cmd --permanent --add-port=18789/tcp
sudo firewall-cmd --reload
```

---

## 数据持久化

| 数据 | 存储位置 | 说明 |
|------|---------|------|
| 配置 | Docker Volume `openclaw_config` | 用户配置、会话等 |
| 工作区 | Docker Volume `openclaw_workspace` | 文件工作区 |

查看数据：
```bash
docker volume ls | grep openclaw
docker volume inspect openclaw_config
```

---

## 安全建议

1. **修改默认 Token**：部署后立即修改 `OPENCLAW_GATEWAY_TOKEN`
2. **限制网络访问**：使用防火墙限制 18789 端口访问
3. **定期更新**：保持代码和镜像最新
4. **备份配置**：定期备份 Docker volumes

```bash
# 备份配置
docker run --rm -v openclaw_config:/data -v $(pwd):/backup alpine tar czf /backup/openclaw-config.tar.gz -C /data .
```
