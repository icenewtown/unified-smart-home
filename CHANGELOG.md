# 更新记录

## v0.7（2026-08-13）
- 修复洗衣机完成提醒误报：新增“洗衣机运行中”辅助开关（input_boolean.washer_running，配置在服务器 configuration.yaml），仅当真正运行超过 5 分钟后回到空闲/待机才播报；开机/关机/中途取消不再误触发。
- 手机通知仅在 HA App 在线时推送（承接 v0.6）。

## v0.6（2026-08-13）
- 上线小爱音箱玩法基础包：洗衣机完成提醒（音箱播报+手机通知）、早间播报（7:30 天气+室内温湿度）、晚安模式（23:00 或语音“晚安”关电视+道晚安）、语音离家/回家模式（conversation 传感器关键词触发）。
- 复核手环实体历史数据：电量始终 unknown、充电状态始终 unavailable，确认米家云不提供手环数据，维持移除结论。

## v0.5（2026-08-13）
- 移除手环10 无效组件：删除 3 条电量自动化与统一面板手环卡片（米家云不提供手环电量/充电状态，传感器始终无数据；如需数据需家庭本地 BLE 方案）。

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