#!/bin/bash

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.10.14/g' files/etc/uci-defaults/99-default-settings 2>/dev/null || true
# 如果 uci-defaults 不存在，改 config_generate
if [ -f files/etc/config/network ]; then
  sed -i 's/192.168.1.1/192.168.10.14/g' files/etc/config/network
fi

# 修改主机名
cat > files/etc/uci-defaults/99-custom <<'UCIEOF'
uci set system.@system[0].hostname='ImmortalWrt-x86'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 设置默认 LAN IP
uci set network.lan.ipaddr='192.168.10.14'
uci commit network
UCIEOF

chmod +x files/etc/uci-defaults/99-custom
