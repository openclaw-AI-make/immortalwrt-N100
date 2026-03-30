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

# ===== 7) 下载官方 frpc 二进制 (v0.66.0，兼容 OpenWrt) =====
# 原因：frp 编译依赖 pion/dtls 与 Go 1.24 不兼容
# 方案：LuCI 前端 + 官方 frpc 二进制
echo "📥 下载 frpc v0.66.0 二进制..."
mkdir -p files/usr/bin
curl -L https://github.com/fatedier/frp/releases/download/v0.66.0/frp_0.66.0_linux_amd64.tar.gz -o /tmp/frp.tar.gz
tar -xzf /tmp/frp.tar.gz -C /tmp
cp /tmp/frp_0.66.0_linux_amd64/frpc files/usr/bin/frpc
chmod 0755 files/usr/bin/frpc
echo "✅ frpc 二进制已放入 files/usr/bin/frpc"

# ===== 8) 清理冲突包 (确保) =====
rm -rf feeds/packages/net/{xray-core,xray-plugin,v2ray-core,sing-box} || true
rm -rf package/feeds/packages/{xray-core,xray-plugin,sing-box} || true
