# OpenClaw on FNOS 部署指南

## 快速部署命令（FNOS 上执行）

### 第一步：克隆代码

```bash
# 创建工作目录
mkdir -p ~/openclaw
cd ~/openclaw

# 克隆代码
git clone https://github.com/snrzz/clawStdy.git .
```

### 第二步：配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 生成安全的 gateway token
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -base64 32)
echo "OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN" >> .env

# 编辑配置文件（可选）
# nano .env
```

### 第三步：构建 Docker 镜像

> **注意**：FNOS 上直接构建可能较慢，建议在本地构建后导入

#### 方式 A：本地构建后导入（推荐）

```bash
# 在本地机器上
cd clawStdy
docker build -t openclaw:local .
docker save openclaw:local > openclaw-local.tar

# 传输到 FNOS
scp openclaw-local.tar user@fnos-ip:/path/to/openclaw/

# 在 FNOS 上导入
docker load < openclaw-local.tar
```

#### 方式 B：直接在 FNOS 构建

```bash
cd ~/openclaw
docker build -t openclaw:local .
```

### 第四步：创建必要目录

```bash
# 创建配置和 workspace 目录
mkdir -p ~/.config/openclaw
mkdir -p ~/openclaw-workspace

# 确保权限正确
chmod -R 755 ~/.config/openclaw
chmod -R 755 ~/openclaw-workspace
```

### 第五步：启动服务

```bash
cd ~/openclaw

# 停止旧容器（如果存在）
docker compose down 2>/dev/null

# 启动服务
docker compose up -d

# 检查状态
docker compose ps

# 查看日志
docker compose logs -f
```

### 第六步：访问 OpenClaw

- **Gateway**: http://your-fnos-ip:18789
- **Web UI**: http://your-fnos-ip:18789/_/ (通过浏览器)

## 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 18789 | Gateway | 主服务端口 |
| 18790 | Bridge | 桥接端口（内部使用）|

## 常用管理命令

```bash
# 查看状态
docker compose ps

# 查看日志
docker compose logs -f
docker compose logs -f openclaw-gateway

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

## 故障排除

### 问题 1：权限错误

```bash
# 检查目录权限
ls -la ~/.config/openclaw

# 修复权限
sudo chown -R 1000:1000 ~/.config/openclaw
sudo chown -R 1000:1000 ~/openclaw-workspace
```

### 问题 2：端口被占用

```bash
# 检查端口占用
ss -tlnp | grep 18789

# 修改端口（编辑 .env）
echo "OPENCLAW_GATEWAY_PORT=18790" >> .env
```

### 问题 3：Token 无效

```bash
# 重新生成 token
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -base64 32)
sed -i "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=$OPENCLAW_GATEWAY_TOKEN/" .env

# 重启服务
docker compose restart
```

## 环境变量说明

| 变量 | 必填 | 说明 |
|------|------|------|
| OPENCLAW_GATEWAY_TOKEN | 是 | Gateway 认证 token |
| OPENCLAW_GATEWAY_PORT | 否 | Gateway 端口，默认 18789 |
| OPENCLAW_GATEWAY_BIND | 否 | 绑定地址，lan/0.0.0.0/localhost |
| OPENCLAW_CONFIG_DIR | 否 | 配置目录 |
| OPENCLAW_WORKSPACE_DIR | 否 | 工作空间目录 |

## Docker Compose 文件说明

```yaml
services:
  openclaw-gateway:
    image: openclaw:local          # 本地构建的镜像
    container_name: openclaw-gateway
    restart: unless-stopped        # 自动重启
    init: true                     # 使用 tini 处理信号
    ports:
      - "18789:18789"              # Gateway 端口
      - "18790:18790"              # Bridge 端口
    volumes:
      - ~/.config/openclaw:/home/node/.openclaw  # 配置
      - ~/openclaw-workspace:/home/node/.openclaw/workspace  # 工作区
    environment:
      - OPENCLAW_GATEWAY_TOKEN=xxx  # 认证 token

  openclaw-cli:
    image: openclaw:local
    container_name: openclaw-cli
    stdin_open: true              # 交互式终端
    tty: true
    entrypoint: ["node", "dist/index.js"]  # CLI 模式
```

## 安全性建议

1. **使用强 Token**：`openssl rand -base64 32`
2. **限制端口访问**：使用 FNOS 防火墙
3. **定期更新**：保持代码和依赖最新
4. **备份配置**：定期备份 ~/.config/openclaw
