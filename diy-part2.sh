#!/usr/bin/env bash
set -e

# 可选：改默认IP
sed -i 's/192.168.1.1/192.168.10.4/g' package/base-files/files/bin/config_generate

# 可选：主机名
sed -i "s/hostname='ImmortalWrt'/hostname='ImmortalWrt-x86'/g" package/base-files/files/bin/config_generate || true
