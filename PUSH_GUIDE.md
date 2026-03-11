# 推送和编译指南

## 前提条件

确保你有 GitHub 仓库 `https://github.com/openclaw-AI-make/immortalwrt-N100` 的写入权限。

## 方法一：使用 HTTPS 推送（推荐）

```bash
cd /home/freely/.openclaw/workspace/immortalwrt-N100

# 设置远程仓库为 HTTPS
git remote set-url origin https://github.com/openclaw-AI-make/immortalwrt-N100.git

# 推送（会提示输入 GitHub 用户名和 token）
git push -u origin master
```

## 方法二：使用 SSH 推送

```bash
cd /home/freely/.openclaw/workspace/immortalwrt-N100

# 确保你有 GitHub SSH 密钥
# 设置远程仓库为 SSH
git remote set-url origin git@github.com:openclaw-AI-make/immortalwrt-N100.git

# 推送
git push -u origin master
```

## 方法三：使用 GitHub Token

```bash
cd /home/freely/.openclaw/workspace/immortalwrt-N100

# 使用 token 推送（替换 YOUR_TOKEN）
git remote set-url origin https://YOUR_TOKEN@github.com/openclaw-AI-make/immortalwrt-N100.git
git push -u origin master
```

## 触发编译

推送成功后，GitHub Actions 会自动触发编译。

或者手动触发：
1. 访问 https://github.com/openclaw-AI-make/immortalwrt-N100/actions
2. 点击 "Build ImmortalWrt for x86_64" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支并点击 "Run workflow"

## 查看编译状态

- Actions 页面：https://github.com/openclaw-AI-make/immortalwrt-N100/actions
- Releases 页面：https://github.com/openclaw-AI-make/immortalwrt-N100/releases

## 编译产物

编译成功后，固件将自动上传到 Releases：
- `*.gz` - 组合镜像（推荐）
- `*.vmdk` - VMware 镜像
- `*.qcow2` - QEMU/KVM 镜像
- `build.config` - 编译配置
- `SHA256SUMS` - 校验和

## 故障排除

### 权限错误

确保你的 GitHub token 有以下权限：
- `repo` (完整控制私有仓库)
- `workflow` (更新 GitHub Actions 工作流)

### 编译失败

检查 Actions 日志，常见问题：
- 磁盘空间不足（工作流已配置清理）
- 网络问题（下载源码包）
- 配置错误（检查 configs/x86_64.config）

### 修改配置

编辑 `configs/x86_64.config` 后推送到 main 分支即可触发新的编译。
