#!/usr/bin/env bash
set -e

# 追加第三方软件源
cat >> feeds.conf.default <<'EOF'

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash

# Turbo ACC  
src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci

# AdGuard Home feeds
src-git packages https://github.com/immortalwrt/packages
src-git luci https://github.com/immortalwrt/luci
EOF

