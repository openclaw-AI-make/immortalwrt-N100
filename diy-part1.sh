#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# Passwall feeds (先添加源)
# 在 feeds.conf.default 顶部添加 Passwall 源
if [ -f feeds.conf.default ]; then
  # 创建临时文件
  cat > /tmp/passwall_feeds.tmp << 'EOF'
src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
EOF
  # 合并文件
  cat /tmp/passwall_feeds.tmp feeds.conf.default > feeds.conf.default.new
  mv feeds.conf.default.new feeds.conf.default
  rm -f /tmp/passwall_feeds.tmp
  echo "✅ Passwall feeds 已添加"
else
  echo "❌ feeds.conf.default 不存在"
  exit 1
fi

# MosDNS (新增功能)
# 注意：v2ray-geodata 由 MosDNS 提供，Passwall 共用
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# 更新 golang 到 1.24 (MosDNS v5 必需)
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
