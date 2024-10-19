#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Linux.sh"

# 显示 Logo
curl -s https://raw.githubusercontent.com/sdohuajia/Hyperlane/refs/heads/main/logo.sh | bash
sleep 3

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，正在安装..."

    # 更新系统
    sudo yum update -y

    # 移除旧版本
    sudo yum remove -y docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine

    # 安装必要的包
    sudo yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2

    # 添加 Docker 的源
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # 安装 Docker
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动 Docker 并设置开机自启
    sudo systemctl start docker
    sudo systemctl enable docker

    # 检查 Docker 版本
    docker --version
else
    echo "Docker 已安装，版本为: $(docker --version)"
fi

# 获取相对路径
relative_path=$(realpath --relative-to=/usr/share/zoneinfo /etc/localtime)
echo "相对路径为: $relative_path"

# 创建 chromium 目录并进入
mkdir -p $HOME/chromium
cd $HOME/chromium
echo "已进入 chromium 目录"

# 获取用户输入
read -p "请输入 CUSTOM_USER: " CUSTOM_USER
read -sp "请输入 PASSWORD: " PASSWORD
echo

# 创建 docker-compose.yaml 文件
cat <<EOF > docker-compose.yaml
---
services:
  chromium:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - CUSTOM_USER=$CUSTOM_USER
      - PASSWORD=$PASSWORD
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - CHROME_CLI=https://x.com/ferdie_jhovie #optional
    volumes:
      - /root/chromium/config:/config
    ports:
      - 3010:3000   #Change 3010 to your favorite port if needed
      - 3011:3001   #Change 3011 to your favorite port if needed
    shm_size: "1gb"
    restart: unless-stopped
EOF

echo "docker-compose.yaml 文件已创建，内容已导入。"

# 启动 Docker Compose
docker compose up -d
echo "Docker Compose 已启动。"

echo "部署完成，请打开浏览器操作。"
