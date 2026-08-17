# 更新记录

## v0.10（2026-08-17）
- AI 语音助手改为“小爱失败才兜底”：监听 conversation 传感器 answers 属性，小爱回答含“正在学习中/没听懂/没有相关技能”等失败关键词时，DeepSeek 才回答并播报；恢复 30 秒冷却防止重复回答。

## v0.9（2026-08-15）
- 新增 AI 语音助手（DeepSeek 对话桥，待 API key 激活）：conversation 传感器捕获非设备指令 → DeepSeek 回答 → 小爱播报；支持多轮上下文（input_text 存会话 ID）与 HA 设备工具调用。
- 安装 deepseek_conversation 自定义集成（v1.6.0，官方 OpenAI 集成不支持自定义地址，故采用社区专用集成）。

## v0.8（2026-08-14）
- 第一批功能扩展：手机围栏离家/回家自动收尾与欢迎、空调自动温控（input_boolean 开关+面板卡片）、洗衣机故障与洗衣液不足提醒、语音报温度/查洗衣机、23:30 深夜忘关提醒。

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