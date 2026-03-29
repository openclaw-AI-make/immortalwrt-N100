# ImmortalWrt 编译错误历史记录

## 错误记录模板

```markdown
### 第 N 次编译 - YYYY-MM-DD HH:mm

**分支**: xxx
**提交**: xxx
**状态**: ❌ 失败 / ✅ 成功

**错误类型**: Go 编译错误 / 依赖冲突 / 下载失败 / 其他

**错误日志**:
```
[粘贴关键错误信息]
```

**根本原因**:
[分析原因]

**解决方案**:
[具体修复步骤]

**修复提交**: [链接]
```

---

## 历史错误

### 第 2 次编译 - 2026-03-30 04:43 (Run #55)

**分支**: fix-full-features-20260326
**提交**: 1d14aa7
**状态**: ❌ 失败

**错误类型**: Go 编译错误 (依赖缺失)

**错误日志**:
```
no required module provides package github.com/sagernet/sing/common/auth
no required module provides package github.com/sagernet/sing/common/debug
no required module provides package github.com/pion/dtls/v2/pkg/crypto/signature
no required module provides package github.com/pion/dtls/v2/pkg/crypto/clientcertificate
no required module provides package github.com/pion/dtls/v2/internal/util
no required module provides package github.com/pion/dtls/v2/internal/ciphersuite/types
```

**根本原因**: 
v2rayA 依赖 xray-core，xray-core 的 Go 编译需要 `github.com/sagernet/sing` 和 `github.com/pion/dtls` 模块。虽然 diy-part1.sh 引入了 sbwml/openwrt_helloworld 源提供 sing-box，但 workflow 在 "Load custom config" 步骤中删除了 sing-box 包（`rm -rf feeds/packages/net/sing-box`），导致 Go 模块依赖链断裂。

**解决方案**:
1. 禁用 v2rayA 和 xray-core（CONFIG_PACKAGE_*=n）
2. 保留 OpenClash 作为唯一代理解决方案
3. 后续如需备用代理，可寻找不依赖 sing-box 的替代方案

**修复提交**: https://github.com/openclaw-AI-make/immortalwrt-N100/commit/b642ec3d50

---

### 第 1 次编译 - 2026-03-29 22:54

**分支**: fix-full-features-20260326
**提交**: 249d5b9
**状态**: ❌ 失败

**错误类型**: Go 编译错误

**错误日志**:
```
- undefined: Position (多处)
- t.isFinal undefined (type *Transformer has no field or method isFinal)
- undefined: AliasType / undefined: AliasTypeUnknown
```

**根本原因**: 
Go 1.24 与 feeds 旧版 xray-core/frp 包源不兼容。MosDNS v5 要求 Go 1.24+，但 xray-core 和 frp 仍使用旧版 feeds 源，这些旧包是为 Go 1.23 设计的。

**解决方案**:
1. xray-core: 从 Openwrt-Passwall/openwrt-passwall-packages 引入（兼容 Go 1.24）
2. frpc: 从 kuoruan/openwrt-frp 引入（兼容 Go 1.24）
3. v2rayA: 改用 ImmortalWrt 自带版本，不单独 clone
4. 删除 feeds 中的旧版冲突包

**修复提交**: https://github.com/openclaw-AI-make/immortalwrt-N100/commit/84cb385ad8

---

## 自动修复规则

### 规则 1: Go 编译错误
**识别**: 错误包含 `undefined:`, `has no field or method`, Go 包导入失败
**处理**:
1. 检查哪个包需要特定 Go 版本
2. 查找兼容的包源（sbwml, kuoruan, Passwall 等）
3. 替换冲突包源
4. 限制：同一包最多尝试 3 个不同源

### 规则 2: 依赖冲突
**识别**: 错误包含 `Package xxx depends on yyy`, `Conflicting dependencies`
**处理**:
1. 检查 .config 中该包的配置
2. 确认依赖链（哪个包需要它）
3. 要么启用依赖，要么禁用需求方
4. 限制：不删除核心功能（OpenClash, v2rayA, AdGuard, MosDNS）

### 规则 3: 下载失败
**识别**: 错误包含 `Failed to download`, `404`, `Connection timeout`
**处理**:
1. 检查源地址是否正确
2. 尝试替代源（GitHub mirror, Gitee mirror）
3. 如果是地理数据，检查是否已有本地副本
4. 限制：重试最多 2 次

### 规则 4: 重复错误检测
**机制**:
1. 每次失败后提取错误指纹（错误类型 + 关键包名）
2. 与历史记录比对
3. 如果同一错误出现 2 次 → 通知用户手动处理
4. 如果同一错误出现 3 次 → 停止自动修复，等待用户指示

---

## 当前状态

**最新分支**: fix-full-features-20260326
**最新提交**: b642ec3d50 (禁用 v2rayA+xray-core)
**当前编译**: Run #56 - 🟡 队列中 (queued)
**修复次数**: 2
**自动修复剩余次数**: 0 (同一错误最多 2 次，已达上限)

**核心功能清单** (调整为 7 项):
- [x] OpenClash - 主力代理
- [ ] v2rayA/Passwall - 备用代理（移除，Go 依赖问题）
- [x] AdGuard Home
- [x] MosDNS
- [x] Turbo ACC
- [x] WireGuard
- [x] TTYD
- [x] frpc

---

## 监控配置

**Cron 任务**: ImmortalWrt 编译监控 (自动修复)
**检查间隔**: 18 分钟 (1080000ms)
**失败处理**:
1. 分析错误日志
2. 检查历史避免重复错误
3. 自动修复并提交
4. 重新触发编译
5. 通知用户修复方案

**编译链接**: https://github.com/openclaw-AI-make/immortalwrt-N100/actions/runs/23718690896

_Last updated: 2026-03-30 04:47_
