#!/bin/bash
# ImmortalWrt 插件后装测试脚本
# 用途：在基础固件上逐个安装插件，确保可用

set -e

echo "========================================"
echo "ImmortalWrt 插件后装测试"
echo "========================================"
echo ""

# 检查是否 root
if [ "$EUID" -ne 0 ]; then 
  echo "❌ 请使用 root 权限运行"
  exit 1
fi

# 检查网络
echo "1. 检查网络连接..."
if ! ping -c 1 8.8.8.8 &>/dev/null; then
  echo "❌ 网络不可用，请先连接网络"
  exit 1
fi
echo "✅ 网络正常"
echo ""

# 更新包列表
echo "2. 更新包列表..."
opkg update
echo ""

# 测试 frpc 安装
echo "3. 测试 frpc 安装..."
if opkg install frp luci-app-frpc; then
  echo "✅ frpc 安装成功"
  /usr/bin/frpc --version || echo "⚠️  frpc 版本检查失败"
else
  echo "❌ frpc 安装失败"
fi
echo ""

# 测试 MosDNS 安装
echo "4. 测试 MosDNS 安装..."
if opkg install mosdns luci-app-mosdns; then
  echo "✅ MosDNS 安装成功"
  mosdns --version || echo "⚠️  mosdns 版本检查失败"
else
  echo "❌ MosDNS 安装失败"
fi
echo ""

# 测试 Passwall 安装
echo "5. 测试 Passwall 安装..."
if opkg install luci-app-passwall; then
  echo "✅ Passwall 安装成功"
else
  echo "❌ Passwall 安装失败"
fi
echo ""

echo "========================================"
echo "测试完成！"
echo "========================================"
echo ""
echo "已安装插件列表:"
opkg list-installed | grep -E "frp|mosdns|passwall|openclash|adguard|turboacc|wireguard|ttyd" || echo "无相关插件"
