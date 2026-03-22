#!/usr/bin/env bash
set -e

# 追加第三方软件源
cat >> feeds.conf.default <<'FEEDS_EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home - 使用 immortalwrt 官方 feed
src-git packages https://github.com/immortalwrt/packages
src-git luci https://github.com/immortalwrt/luci
FEEDS_EOF

# 克隆 AdGuard Home 相关包
cd feeds/luci/applications
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git 2>/dev/null || true
cd ../../../
