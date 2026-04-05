#!/bin/bash
# 在 diy-part.sh 后执行，修改 AdGuard Home Makefile 使其在 po2lmo 不可用时跳过翻译编译

# 读取 AdGuard Home Makefile 并修改
cat > /tmp/fix-adguard-makefile.patch << 'PATCH'
--- a/Makefile
+++ b/Makefile
@@ -79,7 +79,10 @@ define Package/luci-app-adguardhome/install
 	cp -pR ./root/* $(1)/
 
 	install -d -m0755 $(1)/usr/lib/lua/luci/i18n
-	po2lmo ./po/zh-cn/AdGuardHome.po $(1)/usr/lib/lua/luci/i18n/AdGuardHome.zh-cn.lmo
+	# Only compile translation if po2lmo is available
+	if command -v po2lmo >/dev/null 2>&1; then \
+		po2lmo ./po/zh-cn/AdGuardHome.po $(1)/usr/lib/lua/luci/i18n/AdGuardHome.zh-cn.lmo; \
+	fi
 endef
 
 $(eval $(call BuildPackage,luci-app-adguardhome))
PATCH

echo "Patch created"
