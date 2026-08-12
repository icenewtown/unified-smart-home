#!/usr/bin/env bash
# 在 Ubuntu 26.04 LTS 上安装 Docker Engine + Compose 插件
# 用法：sudo ./scripts/setup-server.sh
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# 如果 download.docker.com 拉取慢，可把下方两处 URL 替换为
# https://mirrors.aliyun.com/docker-ce/linux/ubuntu

apt-get update
apt-get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# shellcheck disable=SC1091
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

echo "Docker 安装完成："
docker --version
docker compose version
