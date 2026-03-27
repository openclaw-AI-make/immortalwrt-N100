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

# 处理 v2ray-geodata 冲突
# Passwall 和 MosDNS 都依赖 v2ray-geodata，只保留一份
# 如果 MosDNS 已经克隆了 v2ray-geodata，删除 Passwall 的
if [ -d "package/mosdns/v2ray-geodata" ]; then
  echo "✅ MosDNS 已包含 v2ray-geodata，删除 Passwall 的重复包"
  rm -rf package/passwall-packages/net/v2ray-geodata
fi

# 如果手动克隆了 v2ray-geodata，确保 Passwall 不重复
if [ -d "package/v2ray-geodata" ]; then
  echo "✅ 检测到独立 v2ray-geodata，删除 Passwall 的重复包"
  rm -rf package/passwall-packages/net/v2ray-geodata
fi
