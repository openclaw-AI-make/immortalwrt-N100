#!/bin/bash
set -e

cd /home/freely/immortalwrt-N100

# 获取最新运行状态
curl -sL -H "Authorization: token $(cat /home/freely/.gh_token.txt)" \
    "https://api.github.com/repos/openclaw-AI-make/immortalwrt-N100/actions/runs?per_page=3" \
    > /tmp/latest_runs.json

# 解析最新运行 ID 和状态
python3 << 'PYEOF'
import json
with open('/tmp/latest_runs.json') as f:
    data = json.load(f)
runs = data.get('workflow_runs', [])
if runs:
    latest = runs[0]
    print(f"RUN_ID={latest['id']}")
    print(f"STATUS={latest['status']}")
    print(f"CONCLUSION={latest.get('conclusion', 'null')}")
    print(f"RUN_NUMBER={latest['run_number']}")
PYEOF

# 如果运行中，退出等待下次检查
if [ "$STATUS" = "in_progress" ]; then
    echo "Run $RUN_NUMBER 正在运行中，等待下次检查..."
    exit 0
fi

# 如果成功，退出
if [ "$CONCLUSION" = "success" ]; then
    echo "Run $RUN_NUMBER 构建成功！"
    exit 0
fi

# 失败则获取日志分析
echo "Run $RUN_NUMBER 失败，获取日志分析错误..."
curl -sL -H "Authorization: token $(cat /home/freely/.gh_token.txt)" \
    "https://api.github.com/repos/openclaw-AI-make/immortalwrt-N100/actions/runs/$RUN_ID/jobs" \
    > /tmp/failed_jobs.json

# 提取第一个失败的 Job ID
JOB_ID=$(python3 -c "
import json
with open('/tmp/failed_jobs.json') as f:
    data = json.load(f)
for job in data.get('jobs', []):
    if job.get('conclusion') == 'failure':
        print(job['id'])
        break
")

if [ -n "$JOB_ID" ]; then
    curl -sL -H "Authorization: token $(cat /home/freely/.gh_token.txt)" \
        "https://api.github.com/repos/openclaw-AI-make/immortalwrt-N100/actions/jobs/$JOB_ID/logs" \
        > /tmp/failed_job.log
    
    # 分析错误类型
    echo "分析错误日志..."
    if grep -q "po2lmo.*command not found" /tmp/failed_job.log; then
        echo "错误类型：po2lmo 未找到"
        # 修复 po2lmo 问题
        echo "自动修复 po2lmo 依赖..."
    elif grep -q "luci-base.*not found" /tmp/failed_job.log; then
        echo "错误类型：luci-base 依赖缺失"
        # 修复 feeds install 问题
        echo "自动修复 feeds install..."
    elif grep -q "dependency.*not found" /tmp/failed_job.log; then
        echo "错误类型：包依赖缺失"
        # 尝试移除冲突包
        echo "自动修复依赖冲突..."
    else
        echo "未知错误类型，查看日志末尾..."
        tail -100 /tmp/failed_job.log
    fi
fi

echo "监控完成"
