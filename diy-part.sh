#!/bin/bash
# ImmortalWrt DIY Script for x86_64
# Features: OpenClash, AdGuard, MosDNS, WireGuard

# Clone custom packages
git_clone() {
    local url=$1
    local name=$2
    local branch=$3
    local path="package/$name"
    
    if [ ! -d "$path" ]; then
        if [ -n "$branch" ]; then
            git clone --depth 1 -b "$branch" "$url" "$path"
        else
            git clone --depth 1 "$url" "$path"
        fi
    fi
}

# OpenClash (core package)
git_clone https://github.com/vernesong/OpenClash.git openclash master

# AdGuard Home
git_clone https://github.com/rufengsuixing/luci-app-adguardhome.git luci-app-adguardhome master
# Fix po2lmo dependency - create wrapper script to patch Makefile after tools compile
cat > package/luci-app-adguardhome/patches/001-fix-po2lmo.patch << 'ADGPATCH'
--- a/Makefile
+++ b/Makefile
@@ -79,7 +79,11 @@ define Package/luci-app-adguardhome/install
 	cp -pR ./root/* $(1)/
 
 	install -d -m0755 $(1)/usr/lib/lua/luci/i18n
-	po2lmo ./po/zh-cn/AdGuardHome.po $(1)/usr/lib/lua/luci/i18n/AdGuardHome.zh-cn.lmo
+	# Only compile translation if po2lmo is available (may not be ready during early build)
+	if command -v po2lmo >/dev/null 2>&1; then \
+		po2lmo ./po/zh-cn/AdGuardHome.po $(1)/usr/lib/lua/luci/i18n/AdGuardHome.zh-cn.lmo; \
+	fi
 endef
 
 $(eval $(call BuildPackage,luci-app-adguardhome))
ADGPATCH

# MosDNS v5
git_clone https://github.com/sbwml/luci-app-mosdns.git package/mosdns v5

# WireGuard
git_clone https://github.com/coolsnowwolf/luci-app-wireguard.git luci-app-wireguard master

# Additional utilities
git_clone https://github.com/jerrykuku/luci-app-ttnode.git luci-app-ttnode master
git_clone https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config master

# Theme (Argon)
git_clone https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon master

# Custom settings
cat >> package/lean/default-settings/files/zzz-default-settings <<EOF
# Default hostname
uci set system.@system[0].hostname='ImmortalWrt-N100'

# Default timezone
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

# Enable SSH by default
uci set dropbear.@dropbear[0].enable='1'
uci set dropbear.@dropbear[0].Port='22'
uci set dropbear.@dropbear[0].PasswordAuth='on'

# Network defaults
uci set network.lan.ipaddr='192.168.100.1'
uci set network.lan.netmask='255.255.255.0'

# OpenClash default settings
uci set openclash.config.enable='1'
uci set openclash.config.run_in_background='1'
uci set openclash.config.core_type='meta'
uci commit
EOF

echo "DIY Script completed successfully"
