#!/usr/bin/env bash
set -e

cat >> feeds.conf.default <<'EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home LuCI
src-git adguardhome_luci https://github.com/rufengsuixing/luci-app-adguardhome

# Passwall
src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
EOF
