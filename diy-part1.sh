#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# MosDNS (新增功能)
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# v2ray-geodata (MosDNS 依赖)
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Passwall feeds (恢复 - 之前成功过)
# 在 feeds.conf.default 顶部添加 Passwall 源
sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main\nsrc-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
