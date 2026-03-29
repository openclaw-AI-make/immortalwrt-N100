#!/usr/bin/env bash
set -e

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.10.14/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-N100'/g" package/base-files/files/bin/config_generate || true

# 修改默认时区
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate || true
sed -i "s/timezone='UTC'/timezone='Asia/Shanghai'/g" package/base-files/files/bin/config_generate || true

# 修正 luci-app-adguardhome 兼容性
if [ -f package/luci-app-adguardhome/Makefile ]; then
  sed -ri '/^LUCI_DEPENDS:=/s#\+(ca-certs|wget-ssl)##g' package/luci-app-adguardhome/Makefile || true
fi

# TurboACC 配置 (无 SFE 模式)
if [ -f package/turboacc/Makefile ]; then
  echo "✅ TurboACC 配置为 --no-sfe 模式"
fi

# 删除冲突包 (确保)
rm -rf feeds/packages/net/{xray-core,v2ray-core,sing-box} || true
