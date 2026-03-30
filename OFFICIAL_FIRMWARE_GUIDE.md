# ImmortalWrt 官方固件 + 第三方插件 安装指南

> **适用固件**: ImmortalWrt 24.10.5 x86-64 (官方纯净固件)  
> **插件包**: GitHub Actions 编译的 IPK 包

---

## 📋 **准备工作**

### 1. 下载官方固件
- **网址**: https://firmware-selector.immortalwrt.org/
- **搜索**: `x86 64`
- **版本**: `24.10.5`
- **文件**: `generic-squashfs-combined-efi.img.gz` (约 18MB)

### 2. 下载第三方 IPK 包
- **网址**: https://github.com/openclaw-AI-make/immortalwrt-N100/actions/workflows/build-ipks.yml
- **操作**: 点击 "Run workflow" → 等待完成 → 下载 IPK 包

### 3. 准备 U 盘
- 使用 Rufus / Etcher 写入固件到 U 盘
- 或直接用 `dd` 命令写入

---

## 🔧 **安装步骤**

### 步骤 1: 刷入官方固件

```bash
# 解压固件
gunzip generic-squashfs-combined-efi.img.gz

# 写入 U 盘 (假设 U 盘是 /dev/sdX)
sudo dd if=generic-squashfs-combined-efi.img of=/dev/sdX bs=4M status=progress

# 安全移除
sync
sudo eject /dev/sdX
```

### 步骤 2: 启动路由器

1. 插入 U 盘到 N100
2. 开机从 U 盘启动
3. 等待系统启动完成 (约 2 分钟)

### 步骤 3: 登录 LuCI

- **网址**: http://192.168.1.1
- **用户名**: `root`
- **密码**: (空，首次登录设置)

### 步骤 4: 上传 IPK 包

1. 登录 LuCI
2. 进入 "系统" → "软件包"
3. 点击 "上传软件包..."
4. 选择所有 IPK 包
5. 点击 "安装"

### 步骤 5: SSH 安装 (推荐)

```bash
# SSH 登录
ssh root@192.168.1.1
# 首次登录需要设置密码

# 上传 IPK 包到 /tmp
scp *.ipk root@192.168.1.1:/tmp/

# SSH 登录路由器
ssh root@192.168.1.1

# 更新软件源
opkg update

# 安装核心插件
opkg install /tmp/luci-app-openclash_*.ipk
opkg install /tmp/luci-app-adguardhome_*.ipk
opkg install /tmp/luci-app-turboacc_*.ipk

# 安装可选插件
opkg install /tmp/mosdns_*.ipk
opkg install /tmp/luci-app-mosdns_*.ipk
opkg install /tmp/v2ray-geoip_*.ipk
opkg install /tmp/v2ray-geosite_*.ipk
opkg install /tmp/frpc_*.ipk
opkg install /tmp/luci-app-frpc_*.ipk
opkg install /tmp/luci-i18n-frpc-zh-cn_*.ipk

# 重启 LuCI
/etc/init.d/uhttpd restart

# 或重启路由器
reboot
```

---

## 📦 **插件清单**

### 核心插件 (必装)

| 插件 | 文件 | 用途 |
|------|------|------|
| **OpenClash** | luci-app-openclash_*.ipk | 代理客户端 |
| **AdGuard Home** | luci-app-adguardhome_*.ipk | DNS 去广告 |
| **Turbo ACC** | luci-app-turboacc_*.ipk | 网络加速 |

### 推荐插件 (选装)

| 插件 | 文件 | 用途 |
|------|------|------|
| **MosDNS** | mosdns_*.ipk, luci-app-mosdns_*.ipk | DNS 分流 |
| **地理数据** | v2ray-geoip_*.ipk, v2ray-geosite_*.ipk | OpenClash 规则 |
| **frpc** | frpc_*.ipk, luci-app-frpc_*.ipk | 内网穿透 |
| **中文界面** | luci-i18n-frpc-zh-cn_*.ipk | frpc 中文 |

---

## ⚙️ **配置建议**

### 网络设置

```bash
# 修改 LAN IP (避免冲突)
uci set network.lan.ipaddr='192.168.10.1'
uci commit network
/etc/init.d/network restart

# 重新登录新 IP
ssh root@192.168.10.1
```

### 安装后验证

```bash
# 检查插件是否安装成功
opkg list-installed | grep -E "openclash|adguard|turboacc|mosdns|frpc"

# 检查 LuCI 菜单
# 访问 http://192.168.10.1
# 应该看到：
# - 服务 → OpenClash
# - 服务 → AdGuard Home
# - 网络 → Turbo ACC
# - 服务 → MosDNS (如果安装)
# - 服务 → FRP 客户端 (如果安装)
```

---

## 🔧 **故障排除**

### 问题 1: IPK 安装失败

```bash
# 检查固件版本
cat /etc/openwrt_release

# 检查依赖
opkg install /tmp/xxx.ipk --force-depends

# 查看错误日志
logread | grep opkg
```

### 问题 2: LuCI 菜单不显示

```bash
# 重启 LuCI
/etc/init.d/uhttpd restart

# 清除缓存
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart

# 或重启路由器
reboot
```

### 问题 3: 插件无法启动

```bash
# 检查服务状态
/etc/init.d/openclash status
/etc/init.d/AdGuardHome status
/etc/init.d/turboacc status

# 查看日志
logread | grep openclash
logread | grep AdGuardHome
```

---

## 📊 **优势对比**

| 方案 | 固件大小 | 编译时间 | 灵活性 | 维护成本 |
|------|----------|----------|--------|----------|
| **官方固件 + IPK** | 18MB | 30 分钟 | 中等 | 低 |
| **完整定制固件** | 26MB | 2-3 小时 | 高 | 中 |

---

## 🎯 **总结**

**官方固件 + IPK 方案优势**:
1. ✅ **快速部署** - 官方固件 20 分钟下载完成
2. ✅ **灵活更新** - 插件可单独升级
3. ✅ **官方支持** - 享受官方固件稳定性
4. ✅ **易于维护** - 插件问题不影响系统

**适用场景**:
- ✅ 快速部署测试环境
- ✅ 需要官方固件稳定性
- ✅ 经常更新第三方插件

---

## 🔗 **相关链接**

- **官方固件选择器**: https://firmware-selector.immortalwrt.org/
- **IPK 编译工作流**: https://github.com/openclaw-AI-make/immortalwrt-N100/actions/workflows/build-ipks.yml
- **项目主页**: https://github.com/openclaw-AI-make/immortalwrt-N100
- **问题反馈**: https://github.com/openclaw-AI-make/immortalwrt-N100/issues

---

**最后更新**: 2026-03-30  
**适用版本**: ImmortalWrt 24.10.5 x86-64
