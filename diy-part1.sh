#!/usr/bin/env bash
set -e

# ===== 1) Go 1.23 (sbwml 推荐版本，兼容所有包) =====
# 注意：不要用 Go 1.24，pion/dtls 等包有兼容性问题
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# MosDNS v5 (DNS 分流) - 需要 Go 1.23
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# kuoruan/openwrt-frp — DISABLED: pion/dtls/v2 Go module broken in frp 0.57.0
# Re-enable when upstream fixes the dependency issue.
# git clone --depth=1 https://github.com/kuoruan/openwrt-frp.git package/frp

# fw876/helloworld — SSR Plus+ (mature, stable)
# git clone --depth=1 -b main https://github.com/fw876/helloworld package/helloworld  # disabled: pcre dep broken package/helloworld

# Passwall feeds — disabled: sing-box 1.12.22 requires Go>=1.24, incompatible
# Uncomment when upstream fixes the Go version requirement.
# cat >> feeds.conf.default <<'EOF'
# src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
# src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
# EOF
