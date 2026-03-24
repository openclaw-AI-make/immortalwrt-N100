#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# Passwall feeds — disabled: sing-box 1.12.22 in dependency chain
# requires Go>=1.24, incompatible with openwrt-24.10 toolchain (Go 1.23).
# Uncomment when upstream fixes the Go version requirement.
# cat >> feeds.conf.default <<'EOF'
#
# src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
# src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
# EOF
