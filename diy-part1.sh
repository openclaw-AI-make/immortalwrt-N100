#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# ===== 功能 1: frpc (内网穿透) =====
# 使用 kuoruan 的 frpc，稳定版本
git clone --depth=1 https://github.com/kuoruan/openwrt-frp.git package/frp
git clone --depth=1 https://github.com/kuoruan/luci-app-frpc.git package/luci-app-frpc
