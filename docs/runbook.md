# 实施手册

从零到可用的完整步骤。所有命令默认在阿里云服务器（Ubuntu 26.04 LTS）上以 root 或 sudo 执行。

## 0. 前置条件

- 阿里云实例：≥2 核 2G、Ubuntu 26.04 LTS、公网 IP、root/sudo 权限。
- 安全组：入方向放行 TCP 8123（若自定义端口则放行对应端口）。
- 账号：小米账号、美的美居账号、格力+ 账号，均已绑定设备且原 App 可正常控制。
- 一台小爱音箱（可选，语音控制用）。
- 手机安装 Home Assistant App（iOS/Android）。

## 1. 把项目放到服务器

方式 A：git 私有仓库

```bash
# 本地
git remote add origin <你的私有仓库地址>
git push -u origin main

# 服务器
sudo apt-get update && sudo apt-get install -y git
sudo git clone <你的私有仓库地址> /opt/smart_home
```

方式 B：scp（Windows PowerShell 本地执行）

```powershell
scp -r E:\smart_home ubuntu@<服务器IP>:/opt/smart_home
```

## 2. 安装 Docker 并启动 HA

```bash
cd /opt/smart_home
sudo ./scripts/setup-server.sh
sudo docker compose up -d
docker ps
```

首次拉取镜像需要几分钟。完成后访问 `http://<服务器IP>:8123`。
如果拉镜像慢，先给 Docker 配置阿里云镜像加速器（阿里云容器镜像服务 → 镜像加速器），再重新 `up -d`。

如果 `ghcr.io` 官方源拉取失败/超时，改用国内镜像：

```bash
sudo docker pull ghcr.nju.edu.cn/home-assistant/home-assistant:stable
sudo docker tag ghcr.nju.edu.cn/home-assistant/home-assistant:stable ghcr.io/home-assistant/home-assistant:stable
sudo docker compose up -d
```

## 3. HA 初始化

1. 打开 `http://<服务器IP>:8123`，按向导创建管理员账号（强密码）。
2. 设置 → 用户 → 管理员账号 → 开启两步验证（2FA），必做。
3. 验证手机 App：登录同一个地址，能打开即成功。

## 4. 安装 HACS

```bash
cd /opt/smart_home
bash scripts/install-hacs.sh
```

脚本默认优先使用国内镜像源（get.hacs.vip），失败时自动回退官方源。

重启完成后：设置 → 设备与服务 → 添加集成 → 搜索 HACS → 按提示用 GitHub 账号授权（国内网络如失败可配置代理后重试）。

## 5. 接入小米

1. 云服务器部署请使用 **Xiaomi Miot Auto**（`al-one/hass-xiaomi-miot`）：添加集成 → 使用小米账号 → 填账号密码、地区 `cn`、连接模式选 **Cloud** → 勾选设备。
2. 官方 **Xiaomi Home** 集成把 OAuth 回调地址硬编码为 `homeassistant.local:8123`，要求 HA 与浏览器同局域网，**不适用于云服务器部署**；仅当未来改家庭本地主控时使用。
3. 验收：实体状态与实际一致，能完成开关/模式等控制。

## 6. 接入美的

1. HACS → 搜索并安装 **Midea Auto Cloud**（`sususweet/midea_auto_cloud`），重启 HA。
2. 添加集成 → Midea Auto Cloud → 输入美居账号密码 → 拉取设备并添加。
3. 注意：同一美居账号不要同时登录其他美居系云插件，会被踢 token。
4. 验收：设备状态同步、控制生效。

## 7. 接入格力

1. 安装 **Gree Climate Cloud**（仓库 `davo22/homeassistant-gree-cloud`，domain 为 `gree_cloud`）：把 `custom_components/gree_cloud` 拷贝到 `/opt/smart_home/config/custom_components`。
2. 安装其依赖的云版 greeclimate fork（直连 GitHub 不稳定时用 ghfast.top 代理）：
   `docker exec homeassistant pip install --force-reinstall --no-deps 'greeclimate @ git+https://ghfast.top/https://github.com/davo22/greeclimate.git@1.0.3'`
3. 修改 `manifest.json` 的 requirements 为 `["greeclimate==2.1.4"]`，避免 HA 每次从 GitHub 联网安装（服务器无法直连 GitHub）。
4. 中国区补丁（上游 bug，issue #12）：把 `custom_components/gree_cloud/const.py` 中 `"China Mainland": "mqtt-cn.gree.com"` 改为 `"China Mainland": "mqtt.gree.com"`（MQTT 端口固定为 1984）。
5. 重启 HA，添加集成 → Gree Climate Cloud → 输入格力+ 账号密码。
6. 中央空调（格力云控）备选：`xcy1231/Ha-GreeCentralClimate`。
7. 验收：若设备型号不被支持或插件失效，**暂停该阶段**，回到用户确认（改家庭本地主控、保留格力+ App、或红外方案）。

## 8. 统一仪表盘

1. 本项目使用 YAML 仪表盘，模板在 `templates/lovelace-unified.yaml`，注册片段在 `templates/configuration-lovelace.yaml`（注意：仪表盘 URL 路径必须包含连字符，如 `unified-dashboard`）。
2. 上线地址：`http://<服务器公网IP>:8123/lovelace/unified-dashboard`。
3. 手机 App 登录同一地址即为同一界面；可按需在 HA 界面继续编辑。
4. 可选：HACS 安装 Mushroom 卡片美化界面。
5. **爸妈模式**：`templates/lovelace-elder.yaml`，地址 `http://<服务器公网IP>:8123/lovelace/elder-mode`，大字大按钮设计（空调开关/常用温度/制冷制热/洗衣机/电视/一键全关）。
6. 给父母创建独立账号：设置 → 人员 → 添加人员 → 创建用户（不要给管理员权限），手机/平板用该账号登录后把爸妈模式设为默认仪表盘；Android 平板可用 Fully Kiosk Browser 全屏锁定到该地址。

## 9. 小爱语音（巴法云）

1. **bemfa 已配置**：格力空调（空调类）、洗衣机电源/启停/风干/夜间模式、全屋关空调脚本已同步至巴法云主题。
2. 用户剩余步骤：米家 App → 我的 → 其他平台设备 → 添加 → 巴法 → 输入巴法云私钥（32 位 UID），等设备自动同步。
3. 测试："小爱同学，打开空调 / 空调调到 26 度 / 关闭空调 / 打开全屋关空调"。
4. 注意：小米自家设备（电视、音箱等）无需走巴法云，原生支持小爱；巴法云只支持部分实体类型（开关、灯、空调等），不支持按键类型。
5. 私钥存放在 HA 配置（`.storage/core.config_entries`），如需重置请到巴法云后台更换。

## 10. 自动化场景

在 设置 → 自动化与场景 中创建：

- 一键全关空调：分别调用三家空调实体的 `climate.turn_off`。
- 离家模式：HA App 手机定位离开家 → 关空调/关灯等。
- 定时任务：如每晚 23:00 关闭所有空调。

每个自动化先手动触发测试，确认无误再启用。

## 11. 备份与恢复

1. HA 自动备份：设置 → 系统 → 备份 → 立即备份 → 下载 `.tar` 保存到本地。
2. 恢复演练：用备份 `.tar` 在临时容器恢复一次，验证可完整还原。
3. 服务器重启后容器自动拉起（`restart: always`），用 `docker ps` 确认。
4. 项目文件回退用 git；HA 运行时数据回退用 HA 备份。

## 12. 日常运维与故障排查

```bash
docker ps                                          # 容器状态
docker logs homeassistant --tail 100               # 最近日志
docker restart homeassistant                       # 重启 HA
cd /opt/smart_home && sudo docker compose down     # 停止
cd /opt/smart_home && sudo docker compose up -d    # 启动
```

- 集成不响应：设置 → 设备与服务 → 对应集成 → 重新加载，或删除后重加。
- 美的被踢下线：Midea Auto Cloud 重新登录。
- 小米授权失效：重新登录官方集成；仍失败则改用 Xiaomi Miot Auto 云模式。
- 免费实例到期：先下载备份 `.tar`，新实例按本手册重建后恢复。

## 13. 安全清单

- 强密码 + 2FA（必做）。
- 建议把 8123 改为高位端口，并同步修改 compose 与安全组。
- secrets、HA 配置目录禁止提交 git（`.gitignore` 已配置）。
- 可选加固：服务器与手机都装 Tailscale，安全组不放行 8123，通过 Tailscale 内网 IP 访问。

