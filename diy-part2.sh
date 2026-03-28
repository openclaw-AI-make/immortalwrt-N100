#!/usr/bin/env bash
set -e

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.10.14/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-x86'/g" package/base-files/files/bin/config_generate || true

# 修正 luci-app-adguardhome 兼容性
if [ -f package/luci-app-adguardhome/Makefile ]; then
  sed -ri '/^LUCI_DEPENDS:=/s#\+(ca-certs|wget-ssl)##g' package/luci-app-adguardhome/Makefile || true
fi

# 修正 shadowsocksr-libev 找不到 pcre 库的问题
if [ -f package/helloworld/shadowsocksr-libev/Makefile ]; then
  sed -i 's|--enable-system-shared-lib|--enable-system-shared-lib --with-pcre=$(STAGING_DIR)/usr|' \
    package/helloworld/shadowsocksr-libev/Makefile
fi

# Passwall feeds (在 feeds.conf.default 存在后添加)
if [ -f feeds.conf.default ]; then
  # 创建临时文件
  cat > /tmp/passwall_feeds.tmp << 'EOF'
src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main
src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main
EOF
  # 合并文件（Passwall 源在顶部）
  cat /tmp/passwall_feeds.tmp feeds.conf.default > feeds.conf.default.new
  mv feeds.conf.default.new feeds.conf.default
  rm -f /tmp/passwall_feeds.tmp
  echo "✅ Passwall feeds 已添加"
else
  echo "❌ feeds.conf.default 不存在"
  exit 1
fi

# 处理 v2ray-geodata 冲突
# Passwall 和 MosDNS 都依赖 v2ray-geodata，只保留一份
if [ -d "package/mosdns/v2ray-geodata" ]; then
  echo "✅ MosDNS 已包含 v2ray-geodata，删除 Passwall 的重复包"
  rm -rf package/passwall-packages/net/v2ray-geodata
fi
