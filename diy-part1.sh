#!/usr/bin/env bash
set -e

# 追加第三方软件源
cat >> feeds.conf.default <<'EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home - 使用 immortalwrt 官方
src-git packages https://github.com/immortalwrt/packages

# AdGuard Home LuCI - 第三方
src-git adguardhome_luci https://github.com/rufengsuixing/luci-app-adguardhome
EOF

