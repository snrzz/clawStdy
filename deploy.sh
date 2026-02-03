#!/bin/bash
# OpenClaw FNOS 一键部署脚本
# 使用方法: bash deploy.sh

set -e

echo "=========================================="
echo "  OpenClaw FNOS 一键部署脚本"
echo "=========================================="

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置
WORK_DIR="${1:-~/openclaw}"
REPO_URL="https://github.com/snrzz/clawStdy.git"
IMAGE_NAME="openclaw:local"

# 生成 token
generate_token() {
    openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64
}

echo ""
echo "[1/5] 检查环境..."
command -v docker >/dev/null 2>&1 || { echo -e "${RED}错误: 未安装 Docker${NC}"; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e "${RED}错误: 未安装 Git${NC}"; exit 1; }

echo "[2/5] 准备工作目录..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

if [ -f "docker-compose.yml" ]; then
    echo -e "${YELLOW}检测到已有部署，是否更新? [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git pull origin main 2>/dev/null || true
    fi
else
    echo "克隆代码..."
    git clone "$REPO_URL" .
fi

echo "[3/5] 配置环境变量..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    TOKEN=$(generate_token)
    # 使用 # 作为分隔符，避免 token 中 / 导致的问题
    sed -i "s#your-secure-token-here#$TOKEN#" .env
    echo -e "${GREEN}已生成 Gateway Token${NC}"
fi

# 加载环境变量
set -a
source .env
set +a

echo "[4/5] 构建并启动服务..."
echo "构建镜像中（首次可能需要 5-10 分钟）..."

# 构建镜像
docker build -t "$IMAGE_NAME" .

echo "启动服务..."
docker compose up -d --build

echo "[5/5] 检查状态..."
sleep 3
docker compose ps

echo ""
echo "=========================================="
echo -e "${GREEN}部署完成!${NC}"
echo "=========================================="
echo ""
echo "访问地址:"
echo "  Gateway: http://localhost:18789"
echo "  Web UI:  http://localhost:18789/_/"
echo ""
echo "管理命令:"
echo "  查看日志: docker compose logs -f"
echo "  重启:     docker compose restart"
echo "  停止:     docker compose down"
echo ""
