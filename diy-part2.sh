#!/usr/bin/env bash
set -e

# ===== 1) 修改默认 IP =====
sed -i 's/192.168.1.1/192.168.10.14/g' package/base-files/files/bin/config_generate

# ===== 2) 修改主机名 =====
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-N100'/g" package/base-files/files/bin/config_generate || true

# ===== 3) 修改默认时区 =====
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate || true
sed -i "s/timezone='UTC'/timezone='Asia/Shanghai'/g" package/base-files/files/bin/config_generate || true

# ===== 4) 修正 luci-app-adguardhome 兼容性 =====
if [ -f package/luci-app-adguardhome/Makefile ]; then
  sed -ri '/^LUCI_DEPENDS:=/s#\+(ca-certs|wget-ssl)##g' package/luci-app-adguardhome/Makefile || true
fi

# ===== 5) TurboACC 配置 (无 SFE 模式) =====
if [ -f package/turboacc/Makefile ]; then
  echo "✅ TurboACC 配置为 --no-sfe 模式"
fi

# ===== 6) 确认 xray-core 已正确引入 =====
if [ -d package/passwall-pkgs/xray-core ]; then
  echo "✅ xray-core 已从 Passwall 源引入"
  cp -r package/passwall-pkgs/xray-core package/xray-core || true
  cp -r package/passwall-pkgs/xray-plugin package/xray-plugin || true
fi

# ===== 7) 确认 frpc 已正确引入 =====
if [ -d package/frp ]; then
  echo "✅ frpc 已从 kuoruan 源引入"
fi

# ===== 8) 清理冲突包 (确保) =====
rm -rf feeds/packages/net/{xray-core,xray-plugin,v2ray-core,sing-box} || true
rm -rf package/feeds/packages/{xray-core,xray-plugin,sing-box} || true
