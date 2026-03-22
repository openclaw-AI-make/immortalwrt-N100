#!/usr/bin/env bash
set -e

# 追加第三方软件源（不要重复添加已存在的 feed）
cat >> feeds.conf.default <<'EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home LuCI - 第三方
src-git adguardhome_luci https://github.com/rufengsuixing/luci-app-adguardhome
EOF

