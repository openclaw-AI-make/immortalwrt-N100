#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# MosDNS (新增功能)
# 先移除 feeds 中的冲突包
rm -rf feeds/packages/net/v2ray-geodata 2>/dev/null || true
rm -rf feeds/packages/lang/golang 2>/dev/null || true

# 更新 golang 到 1.24 (MosDNS v5 必需)
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 克隆 MosDNS 和 v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Passwall feeds (恢复 - 之前成功过)
# 在 feeds.conf.default 顶部添加 Passwall 源
sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main\nsrc-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
