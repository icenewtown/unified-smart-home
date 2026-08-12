# 上游 Issue 反馈草稿

## 1. Gree Climate Cloud（davo22/homeassistant-gree-cloud）

- 状态：已有 issue #12（open），建议在其评论区补充以下内容，不要重复建 issue。
- 评论草稿（英文）：

```
Confirmed on Home Assistant 2026.8.1 with HA running on a cloud server in mainland China (Aliyun).

- `mqtt-cn.gree.com` does not resolve (NXDOMAIN) on Aliyun DNS or Alibaba public DNS.
- After changing `const.py`:
  `"China Mainland": "mqtt-cn.gree.com"` -> `"China Mainland": "mqtt.gree.com"`
- The integration then connected successfully to `mqtt.gree.com:1984` (TLS) and discovered the device (climate + panel light / quiet / fresh air / XFan entities).
- Additional note for mainland China Docker setups: HA container cannot reach github.com reliably, so we pinned `manifest.json` requirements to `greeclimate==2.1.4` (the installed cloud fork reports version 2.1.4) to avoid HA re-installing from GitHub on every setup.
```

## 2. Xiaomi Home 官方集成（XiaoMi/ha_xiaomi_home）

- 已有相关 issue：#8（closed）、#1569（closed），但“云服务器部署无法授权”场景建议新开一条。
- 新建 issue 草稿（中文）：

```
标题: [Bug/Feature] OAuth2 回调地址硬编码为 homeassistant.local，云服务器部署无法完成授权

## 问题描述
在阿里云服务器（非家庭局域网）上以 Docker 部署 Home Assistant 时，添加“Xiaomi Home”集成后：
1. 配置页显示 OAuth2 认证跳转地址为 http://homeassistant.local:8123（miot/const.py 中 OAUTH_REDIRECT_URL 硬编码，且表单 vol.In([OAUTH_REDIRECT_URL]) 只允许该值）。
2. 小米登录完成后浏览器跳转到 http://homeassistant.local:8123/api/webhook/...，该主机名在公网不可解析，授权必然失败。
3. 已在 configuration.yaml 中设置 external_url / internal_url 为公网地址，仍无效。

## 建议
- 允许用户配置 OAuth2 跳转地址（如增加配置项，或从 external_url 推导）；
- 或将 OAUTH_REDIRECT_URL 改为可配置，而不是写死 homeassistant.local。

## 相关 issue
#8、#1569

## 环境
- HA Core 2026.8.1（Docker）
- 服务器：中国大陆云服务器（Ubuntu 26.04 LTS）
```
## 提交结果（2026-08-12）

- 小米官方集成新 issue：https://github.com/XiaoMi/ha_xiaomi_home/issues/1769
- 格力云 issue #12 补充评论：https://github.com/davo22/homeassistant-gree-cloud/issues/12#issuecomment-5268785647
- 本项目仓库：https://github.com/icenewtown/unified-smart-home （公开，内容已去除隐私信息）
