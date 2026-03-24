#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# kuoruan/openwrt-frp — DISABLED: pion/dtls/v2 Go module broken in frp 0.57.0
# Re-enable when upstream fixes the dependency issue.
# git clone --depth=1 https://github.com/kuoruan/openwrt-frp.git package/frp

# fw876/helloworld — SSR Plus+ (mature, stable)
git clone --depth=1 -b main https://github.com/fw876/helloworld package/helloworld

# Passwall feeds — disabled: sing-box 1.12.22 requires Go>=1.24, incompatible
# Uncomment when upstream fixes the Go version requirement.
# cat >> feeds.conf.default <<'EOF'
# src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
# src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
# EOF
