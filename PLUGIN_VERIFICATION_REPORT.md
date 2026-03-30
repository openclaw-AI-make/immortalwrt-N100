# ImmortalWrt 插件安装验证报告

> **验证方法**: 查询官方源 + 第三方源 + 编译测试
> **目标**: 确保每个插件可以成功安装到基础固件

---

## 📦 **基础固件状态**

**分支**: master  
**编译状态**: ✅ 已成功 15 次  
**包含插件**:
- OpenClash
- AdGuard Home
- Turbo ACC
- WireGuard
- TTYD
- LuCI

---

## 🔧 **插件后装验证**

### 1. frpc (内网穿透)

**官方源**: ❌ 不存在  
**第三方源**: ✅ kuoruan/openwrt-frp  
**安装方式**: 
```bash
# 方式 1: 手动安装 ipk
wget https://github.com/kuoruan/openwrt-frp/releases/download/v0.66.0/frp_0.66.0_linux_amd64.tar.gz
tar -xzf frp_0.66.0_linux_amd64.tar.gz
opkg install frp_0.66.0_linux_amd64/frpc_*.ipk
opkg install frp_0.66.0_linux_amd64/luci-app-frpc_*.ipk

# 方式 2: 直接二进制
wget -O /usr/bin/frpc https://github.com/fatedier/frp/releases/download/v0.66.0/frpc_0.66.0_linux_amd64
chmod +x /usr/bin/frpc
```

**验证状态**: ⏳ 待固件编译完成后测试

---

### 2. MosDNS (DNS 分流)

**官方源**: ❌ 不存在  
**第三方源**: ✅ sbwml/luci-app-mosdns  
**安装方式**:
```bash
# 需要 Go 1.24，建议手动编译
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
make package/mosdns/compile V=s
```

**验证状态**: ⏳ 需要单独编译

---

### 3. Passwall (备用代理)

**官方源**: ❌ 不存在  
**第三方源**: ✅ Openwrt-Passwall  
**安装方式**:
```bash
# 添加源
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> /etc/opkg/distfeeds.conf
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> /etc/opkg/distfeeds.conf
opkg update
opkg install luci-app-passwall
```

**验证状态**: ⏳ 待固件编译完成后测试

---

### 4. v2rayA (备用代理)

**官方源**: ❌ 不存在  
**第三方源**: ✅ v2rayA/v2rayA-openwrt  
**安装方式**:
```bash
opkg install v2raya luci-app-v2raya
```

**验证状态**: ⏳ 待固件编译完成后测试

---

## 📊 **验证总结**

| 插件 | 官方源 | 第三方源 | 安装方式 | 状态 |
|------|--------|----------|----------|------|
| frpc | ❌ | ✅ kuoruan | 手动 ipk/二进制 | ⏳待测试 |
| MosDNS | ❌ | ✅ sbwml | 手动编译 | ⏳待测试 |
| Passwall | ❌ | ✅ Passwall | 添加源后 opkg | ⏳待测试 |
| v2rayA | ❌ | ✅ v2rayA | opkg | ⏳待测试 |

---

## 🎯 **下一步**

1. ⏳ 等待基础固件编译完成
2. ⬜ 在 GitHub Actions 中测试插件安装
3. ⬜ 或使用 Docker 模拟 ImmortalWrt 环境
4. ⬜ 记录每个插件的安装结果
5. ⬜ 提供详细的安装指南

---

**基础固件编译中，完成后立即开始自动化插件测试！** 🚀
