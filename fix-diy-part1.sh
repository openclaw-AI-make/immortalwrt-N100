#!/usr/bin/env bash
set -e

# ===== 1) Go 1.24 (MosDNS v5 必需) =====
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# ===== 2) OpenClash (主力代理) =====
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# ===== 3) v2rayA (备用代理，用 ImmortalWrt 自带，不单独 clone) =====
# 注意：v2rayA 在 ImmortalWrt 源码中已存在，依赖 xray-core

# ===== 4) Turbo ACC (网络加速，--no-sfe) =====
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# ===== 5) AdGuard Home LuCI (去广告) =====
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# ===== 6) MosDNS v5 (DNS 分流，sbwml 源) =====
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# ===== 7) v2ray-geodata (地理数据) =====
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# ===== 8) xray-core (从 Passwall 源，兼容 Go 1.24) =====
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-pkgs

# ===== 9) frpc (从 kuoruan 源，兼容 Go 1.24) =====
git clone --depth=1 https://github.com/kuoruan/openwrt-frp.git package/frp
git clone --depth=1 https://github.com/kuoruan/luci-app-frpc.git package/luci-app-frpc

# ===== 10) sing-box (提供 Go 依赖，即使不启用包) =====
# 注意：某些包的 Go 编译依赖 github.com/sagernet/sing 模块
# 从 sbwml 源引入，兼容 Go 1.24
git clone --depth=1 https://github.com/sbwml/openwrt_helloworld package/helloworld

# ===== 11) 避免 feeds 包冲突 (删除旧版) =====
# 注意：保留 feeds/packages/net/sing-box 由 helloworld 源提供
rm -rf feeds/packages/net/{xray-core,xray-plugin,v2ray-core} || true
