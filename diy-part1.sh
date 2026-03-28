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

# 更新 golang 到 1.24 (MosDNS v5 必需)
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# Passwall feeds
# 注意：在 openwrt 根目录执行，feeds.conf.default 已存在
# 此步骤将在 diy-part2.sh 中执行
