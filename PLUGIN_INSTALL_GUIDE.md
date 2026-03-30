# ImmortalWrt 插件后装指南

> **策略**: 基础固件 + 插件后装
> **优势**: 编译成功率高，插件可单独测试，故障易排查

---

## 📦 **基础固件（master 分支）**

**包含功能**:
- ✅ OpenClash (主力代理)
- ✅ AdGuard Home (去广告)
- ✅ Turbo ACC (网络加速)
- ✅ WireGuard (VPN)
- ✅ TTYD (Web 终端)
- ✅ LuCI (Web 界面)

**编译状态**: ✅ 已成功 15 次

---

## 🔧 **插件后装测试**

### 1. frpc (内网穿透)

**安装命令**:
```bash
opkg update
opkg install frp luci-app-frpc
```

**验证**:
```bash
/usr/bin/frpc --version
/etc/init.d/frpc status
```

**LuCI 路径**: 服务 → FRP

**备用方案** (如 opkg 失败):
```bash
# 下载官方二进制
wget https://github.com/fatedier/frp/releases/download/v0.66.0/frp_0.66.0_linux_amd64.tar.gz
tar -xzf frp_0.66.0_linux_amd64.tar.gz -C /tmp
cp /tmp/frp_0.66.0_linux_amd64/frpc /usr/bin/
chmod +x /usr/bin/frpc

# 下载 LuCI 前端
wget -O /usr/lib/lua/luci/controller/frpc.lua https://raw.githubusercontent.com/kuoruan/luci-app-frpc/master/controller/frpc.lua
```

---

### 2. MosDNS (DNS 分流)

**安装命令**:
```bash
opkg update
opkg install mosdns luci-app-mosdns
```

**验证**:
```bash
mosdns --version
/etc/init.d/mosdns status
```

**LuCI 路径**: 服务 → MosDNS

**注意**: MosDNS v5 需要 Go 1.24，可能需要手动编译或使用预编译二进制

---

### 3. Passwall (备用代理)

**安装命令**:
```bash
# 添加 Passwall 源
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> /etc/opkg/distfeeds.conf
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> /etc/opkg/distfeeds.conf
opkg update

# 安装
opkg install luci-app-passwall
```

**验证**:
```bash
/etc/init.d/passwall status
```

**LuCI 路径**: 服务 → PassWall

---

### 4. v2rayA (备用代理)

**安装命令**:
```bash
opkg install v2raya luci-app-v2raya
```

**验证**:
```bash
v2raya --version
/etc/init.d/v2raya status
```

**LuCI 路径**: 服务 → v2rayA

---

## 🧪 **自动化测试脚本**

**运行测试**:
```bash
chmod +x /root/plugin-install-test.sh
/root/plugin-install-test.sh
```

**脚本功能**:
1. 检查网络连接
2. 更新包列表
3. 逐个安装插件
4. 验证安装结果
5. 输出已安装插件列表

---

## 📊 **测试清单**

| 插件 | opkg 安装 | 手动安装 | LuCI 可用 | 功能正常 |
|------|----------|----------|-----------|----------|
| frpc | ⏳待测试 | ⏳待测试 | ⏳待测试 | ⏳待测试 |
| MosDNS | ⏳待测试 | ⏳待测试 | ⏳待测试 | ⏳待测试 |
| Passwall | ⏳待测试 | ⏳待测试 | ⏳待测试 | ⏳待测试 |
| v2rayA | ⏳待测试 | ⏳待测试 | ⏳待测试 | ⏳待测试 |

---

## 🎯 **下一步**

1. **等待基础固件编译完成**
2. **刷入固件到 N100**
3. **运行插件安装测试脚本**
4. **记录每个插件的安装结果**
5. **失败插件准备手动安装方案**

---

**编译完成后，我会逐个测试每个插件的安装！** 🚀
