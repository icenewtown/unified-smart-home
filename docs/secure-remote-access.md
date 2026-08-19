# 安全远程访问方案

Home Assistant 的 8123 端口不应长期以明文 HTTP 暴露在公网。强密码和 2FA 仍然重要，但不能替代 HTTPS 或私有网络。

## 方案 A：Tailscale（推荐）

适合仅自己和家人使用，不需要域名，也不需要把 HA 暴露在公网。

1. 在服务器安装并登录 Tailscale：

   ~~~bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up
   ~~~

2. 在手机、电脑安装 Tailscale，登录同一 tailnet。
3. 确认 HA 可通过 Tailscale IP 或 MagicDNS 主机名访问。
4. 在阿里云安全组删除公网 TCP 8123 规则，再从手机移动网络验证仍可控制。
5. 将 HA App 的内部/外部地址都改为 Tailscale 地址；先保留原公网访问路径，确认 24 小时稳定后再彻底关闭。

优点：攻击面最小，维护成本低。限制：没有安装 Tailscale 的设备无法访问。

## 方案 B：HTTPS 反向代理

适合需要浏览器直接访问或对外提供受控访问。需要自己的域名及 DNS 控制权。

1. 用 Caddy 或 Nginx Proxy Manager 将域名的 HTTPS（443）反向代理到 homeassistant:8123。
2. 在 Home Assistant 的 configuration.yaml 中配置 http.use_x_forwarded_for: true 和可信代理网段。
3. 安全组只开放 443（及证书签发所需的 80），关闭公网 8123。
4. HA App 的外部地址使用 HTTPS 域名，并在移动网络下验证。

注意：反向代理配置错误可能造成登录循环或客户端 IP 信任问题，变更前先完成 HA 备份，并保留服务器 SSH 通道。

## 变更检查表

- [ ] 已完成 HA 完整备份并下载到本地。
- [ ] 已在第二台设备验证新访问地址。
- [ ] 手机 HA App 已更新地址。
- [ ] 云厂商安全组不再允许公网 8123。
- [ ] 从移动网络验证控制、通知和米家云集成均正常。
