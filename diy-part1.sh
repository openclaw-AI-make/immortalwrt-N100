#!/usr/bin/env bash
set -e

# OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash

# Turbo ACC
git clone --depth=1 -b luci https://github.com/chenmozhijin/turboacc.git package/turboacc

# AdGuard Home LuCI
git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

# 禁用 geoview (编译失败)
# geoview 是 OpenClash 的可选依赖，但编译经常失败
mkdir -p package/feeds/packages/geoview
cat > package/feeds/packages/geoview/Makefile << 'MAKEFILE'
define Package/geoview
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GeoView (disabled)
  DEPENDS:=@BROKEN
endef

define Build/Compile
endef

$(eval $(call BuildPackage,geoview))
MAKEFILE

# kuoruan/openwrt-frp — DISABLED
# git clone --depth=1 https://github.com/kuoruan/openwrt-frp.git package/frp

# fw876/helloworld — SSR Plus+ — DISABLED
# git clone --depth=1 -b main https://github.com/fw876/helloworld package/helloworld

# Passwall feeds — disabled
