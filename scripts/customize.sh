#!/bin/bash
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom <<'EOF'
#!/bin/sh
uci set system.@system[0].hostname='ImmortalWrt-x86'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system
uci set network.lan.ipaddr='192.168.10.14'
uci commit network
EOF
chmod +x files/etc/uci-defaults/99-custom
