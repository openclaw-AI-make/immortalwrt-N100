#!/usr/bin/env bash
set -e

# 修改默认IP
sed -i 's/192.168.1.1/192.168.10.14/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-x86'/g" package/base-files/files/bin/config_generate || true

# 修正 luci-app-adguardhome 兼容性
if [ -f package/luci-app-adguardhome/Makefile ]; then
  sed -ri '/^LUCI_DEPENDS:=/s#\+(ca-certs|wget-ssl)##g' package/luci-app-adguardhome/Makefile || true
fi

# NOTE: frp 0.66.0 / sing-box 1.12.22 都需要 Go>=1.24，
# 而 ImmortalWrt 24.10 工具链仅 Go 1.23.x，已在 .config 和 diy-part1 中禁用相关包和 feeds。
