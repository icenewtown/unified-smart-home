#!/usr/bin/env bash
# 在 homeassistant 容器内安装 HACS
# 用法：bash scripts/install-hacs.sh（需要当前用户有 docker 权限）
set -euo pipefail

if ! docker ps --format '{{.Names}}' | grep -qx homeassistant; then
  echo "错误：未找到运行中的 homeassistant 容器，请先执行 docker compose up -d"
  exit 1
fi

echo "尝试国内镜像安装 HACS ..."
if docker exec homeassistant bash -c "wget -qO - https://get.hacs.vip | bash -"; then
  echo "国内镜像安装成功。"
else
  echo "国内镜像失败，改用官方源 ..."
  docker exec homeassistant bash -c "wget -qO - https://raw.githubusercontent.com/hacs/install/main/install | bash -"
fi

echo "重启 Home Assistant 容器 ..."
docker restart homeassistant

echo "完成。稍候访问 http://<服务器IP>:8123，在 设置 → 设备与服务 → 添加集成 中搜索 HACS。"
