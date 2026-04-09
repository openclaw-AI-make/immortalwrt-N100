#!/bin/bash
# ImmortalWrt 构建自动监控修复脚本
# 每 3 分钟检查一次，失败时自动分析并修复

set -e
cd /home/freely/immortalwrt-N100

TOKEN=$(cat /home/freely/.gh_token.txt)
REPO="openclaw-AI-make/immortalwrt-N100"

# 获取最新运行
curl -sL -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/runs?per_page=3" \
    > /tmp/latest_runs.json

# 解析运行信息
eval $(python3 << 'PYEOF'
import json
with open('/tmp/latest_runs.json') as f:
    data = json.load(f)
runs = data.get('workflow_runs', [])
if not runs:
    print("RUN_ID=0")
    print("STATUS=none")
    print("CONCLUSION=none")
    print("RUN_NUMBER=0")
else:
    latest = runs[0]
    print(f"RUN_ID={latest['id']}")
    print(f"STATUS={latest['status']}")
    print(f"CONCLUSION={latest.get('conclusion', 'null')}")
    print(f"RUN_NUMBER={latest['run_number']}")
PYEOF
)

echo "=== 构建监控 ==="
echo "Run #$RUN_NUMBER (ID: $RUN_ID)"
echo "状态：$STATUS"
echo "结论：$CONCLUSION"

# 运行中则退出
if [ "$STATUS" = "in_progress" ]; then
    echo "→ 构建进行中，3 分钟后再次检查"
    exit 0
fi

# 成功则退出
if [ "$CONCLUSION" = "success" ]; then
    echo "✓ 构建成功！固件已发布"
    exit 0
fi

# 失败则处理
echo "✗ 构建失败，开始分析..."

# 获取 Job 列表
curl -sL -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/jobs" \
    > /tmp/failed_jobs.json

# 提取失败 Job ID
JOB_ID=$(python3 -c "
import json
with open('/tmp/failed_jobs.json') as f:
    data = json.load(f)
for job in data.get('jobs', []):
    if job.get('conclusion') == 'failure':
        print(job['id'])
        break
")

if [ -z "$JOB_ID" ]; then
    echo "未找到失败 Job，检查 workflow 日志"
    exit 1
fi

echo "失败 Job ID: $JOB_ID"

# 获取日志
curl -sL -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/actions/jobs/$JOB_ID/logs" \
    > /tmp/failed_job.log

LINES=$(wc -l < /tmp/failed_job.log)
echo "日志行数：$LINES"

# 分析错误
ERROR_TYPE="unknown"
if grep -qi "po2lmo.*not found" /tmp/failed_job.log; then
    ERROR_TYPE="po2lmo_missing"
    echo "错误：po2lmo 命令未找到"
elif grep -qi "luci-base.*not found" /tmp/failed_job.log; then
    ERROR_TYPE="luci_deps_missing"
    echo "错误：luci-base 依赖缺失"
elif grep -qi "feeds.*not found" /tmp/failed_job.log; then
    ERROR_TYPE="feeds_missing"
    echo "错误：feeds 未安装"
elif grep -qi "dependency.*not found" /tmp/failed_job.log; then
    ERROR_TYPE="pkg_dependency"
    echo "错误：包依赖问题"
elif grep -qi "make.*Error" /tmp/failed_job.log; then
    ERROR_TYPE="make_error"
    echo "错误：编译错误"
fi

# 根据错误类型修复
case $ERROR_TYPE in
    po2lmo_missing)
        echo "修复方案：确保 feeds install 在 luci 编译前执行"
        # 检查 workflow 是否已有 feeds install
        if ! grep -q "scripts/feeds install -a" .github/workflows/build-immortalwrt.yml; then
            echo "添加 feeds install 步骤..."
            # 这里需要具体修改 workflow
        fi
        ;;
    luci_deps_missing)
        echo "修复方案：添加 feeds install 步骤"
        ;;
    feeds_missing)
        echo "修复方案：检查 feeds update/install 顺序"
        ;;
    pkg_dependency)
        echo "修复方案：检查 diy-part.sh 包依赖"
        ;;
    *)
        echo "未知错误，查看日志末尾 50 行："
        tail -50 /tmp/failed_job.log
        ;;
esac

echo "=== 监控完成 ==="
