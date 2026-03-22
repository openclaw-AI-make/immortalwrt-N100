#!/usr/bin/env bash
set -e

# 追加第三方软件源
cat >> feeds.conf.default <<'EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home LuCI（本体 adguardhome 走官方包，这里只补 LuCI）
src-git adguardhome_luci https://github.com/rufengsuixing/luci-app-adguardhome
EOF

