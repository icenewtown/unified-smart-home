# 更新记录

## v0.4（2026-08-12）
- 新增 GitHub 自动同步：Windows 计划任务每天 03:00 运行 `scripts/sync-github.ps1`，自动清理隐私并推送最新版本。
- 仓库美化：README 徽章、MIT License、CHANGELOG、GitHub Topics。

## v0.3（2026-08-12）
- 上线统一仪表盘（unified-dashboard）与“全屋关空调”脚本模板。
- 修复格力云中国区 MQTT 地址：`mqtt-cn.gree.com` → `mqtt.gree.com`（端口 1984）。

## v0.2（2026-08-12）
- 部署完成：Ubuntu 26.04 LTS + Docker + Home Assistant 2026.8.1。
- 接入 Xiaomi Miot Auto / Midea Auto Cloud / Gree Climate Cloud / bemfa。
- 上游反馈：小米官方集成 issue #1769；格力云 issue #12 补充评论。

## v0.1（2026-08-12）
- 项目骨架：git 仓库、README、docker-compose.yml、实施手册、测试清单。