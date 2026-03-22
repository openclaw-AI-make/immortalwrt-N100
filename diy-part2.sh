#!/usr/bin/env bash
set -e

# 修改默认IP
sed -i 's/192.168.1.1/192.168.10.4/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/hostname='ImmortalWrt'/hostname='ImmortalWrt-x86'/g' package/base-files/files/bin/config_generate || true

# 克隆 AdGuard Home LuCI 到 feeds
cd feeds/luci/applications
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git 2>/dev/null || true
cd ../../../../

