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

# Passwall 包处理 (在 feeds install 之后执行)
# 移除 openwrt feeds 自带的冲突包
rm -rf feeds/packages/net/{geoview,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,shadow-tls} 2>/dev/null || true

# 克隆 Passwall 官方包
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages 2>/dev/null || true

# 移除过时的 luci 版本并克隆新版
rm -rf feeds/luci/applications/luci-app-passwall 2>/dev/null || true
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci 2>/dev/null || true
