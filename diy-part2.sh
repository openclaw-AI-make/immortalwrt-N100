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

cd "$GITHUB_WORKSPACE/openwrt"

# 用上游新版 frp 覆盖 feeds 里的旧 frp
rm -rf feeds/packages/net/frp
git clone --depth=1 --filter=blob:none --sparse https://github.com/openwrt/packages.git /tmp/openwrt-packages
cd /tmp/openwrt-packages
git sparse-checkout init --cone
git sparse-checkout set net/frp
cd "$GITHUB_WORKSPACE/openwrt"
mkdir -p feeds/packages/net
cp -a /tmp/openwrt-packages/net/frp feeds/packages/net/frp
rm -rf /tmp/openwrt-packages

# 清理 frp 旧缓存，防止反复复用 0.51.3 和旧 go 模块
rm -rf build_dir/target-*/frp-* 2>/dev/null || true
rm -rf staging_dir/target-*/pkginfo/frp.* 2>/dev/null || true
rm -rf tmp/info/.packageinfo-*frp* 2>/dev/null || true
rm -rf dl/go-mod-cache/github.com/fatedier 2>/dev/null || true
rm -rf dl/go-mod-cache/github.com/pion/dtls* 2>/dev/null || true
rm -f dl/frp-* 2>/dev/null || true
