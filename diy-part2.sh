#!/usr/bin/env bash
set -e

# 修改默认IP
sed -i 's/192.168.1.1/192.168.10.14/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-x86'/g" package/base-files/files/bin/config_generate || true

# 修正 luci-app-adguardhome 兼容性
if [ -f package/luci-app-adguardhome/Makefile ]; then
  sed -ri '/^LUCI_DEPENDS:=/s#\+(ca-certs|wget-ssl)##g' package/luci-app-adguardhome/Makefile || true
fi

# 修正 shadowsocksr-libev 找不到 pcre 库的问题：显式指定 staging 路径
if [ -f package/helloworld/shadowsocksr-libev/Makefile ]; then
  sed -i '/--enable-system-shared-lib/a\\t--with-pcre=$(STAGING_DIR)/usr' \
    package/helloworld/shadowsocksr-libev/Makefile
fi
