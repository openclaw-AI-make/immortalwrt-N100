#!/usr/bin/env bash
set -e

# OpenClash (主力代理)
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# v2rayA (备用代理)
git clone --depth=1 https://github.com/v2rayA/v2rayA-openwrt.git package/v2rayA-openwrt

# Turbo ACC (网络加速，--no-sfe)
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI (去广告)
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# MosDNS v5 (DNS 分流)
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# v2ray-geodata (地理数据)
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Go 1.24 (MosDNS v5 必需)
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 避免 geodata 冲突
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box} || true
