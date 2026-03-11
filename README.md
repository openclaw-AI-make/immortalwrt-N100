# ImmortalWrt for Intel N100 (x86_64)

基于 ImmortalWrt 的 Intel N100 固件云编译项目。

## 特性

- 🎯 针对 Intel N100 优化
- 🔄 自动云编译（GitHub Actions）
- 📦 最小化配置，快速编译
- 🔒 使用 ImmortalWrt 官方源
- 📤 自动发布到 Releases

## 快速开始

### 触发编译

1. 推送配置更改到 `main` 分支
2. 或者使用 GitHub Actions 的 "Run workflow" 按钮手动触发

### 下载固件

访问 [Releases](https://github.com/openclaw-AI-make/immortalwrt-N100/releases) 页面下载最新固件。

## 文件说明

```
.
├── .github/
│   └── workflows/
│       └── build.yml      # GitHub Actions 工作流
├── configs/
│   └── x86_64.config      # x86_64 编译配置
└── README.md
```

## 编译产物

- `*.gz` - 组合镜像（推荐用于大多数安装）
- `*.vmdk` - VMware 镜像
- `*.qcow2` - QEMU/KVM 镜像
- `build.config` - 编译配置
- `SHA256SUMS` - 校验和

## 安装

1. 下载 `.gz` 镜像文件
2. 解压并写入 USB 驱动器或直接安装
3. 从驱动器启动
4. 默认 IP：192.168.1.1
5. 默认密码：无（首次登录时设置）

## 参考

- [ImmortalWrt 官方仓库](https://github.com/immortalwrt/immortalwrt)
- [ImmortalWrt 文档](https://github.com/immortalwrt/docs)

## 许可证

遵循 ImmortalWrt 项目许可证
