#!/bin/bash
# 等待构建完成并报告结果
TOKEN=$(cat /home/freely/.gh_token.txt)
REPO="openclaw-AI-make/immortalwrt-N100"
RUN_ID="24263060626"

echo "=== 监控构建 #64 ==="
echo "Run ID: $RUN_ID"
echo "开始时间：$(date)"

MAX_WAIT=7200  # 2 小时超时
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
    curl -sL -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID" \
        > /tmp/run_status.json
    
    STATUS=$(python3 -c "import json; print(json.load(open('/tmp/run_status.json'))['status'])")
    CONCLUSION=$(python3 -c "import json; print(json.load(open('/tmp/run_status.json')).get('conclusion', 'N/A'))")
    
    echo "[$(date +%H:%M:%S)] 状态：$STATUS, 结论：$CONCLUSION"
    
    if [ "$STATUS" = "completed" ]; then
        if [ "$CONCLUSION" = "success" ]; then
            echo "✓ 构建成功！"
            exit 0
        else
            echo "✗ 构建失败，结论：$CONCLUSION"
            # 获取失败日志
            curl -sL -H "Authorization: token $TOKEN" \
                "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/jobs" \
                > /tmp/jobs.json
            JOB_ID=$(python3 -c "import json; jobs=json.load(open('/tmp/jobs.json'))['jobs']; print(jobs[0]['id'] if jobs else 'N/A')")
            echo "Job ID: $JOB_ID"
            # 保存错误日志
            cp /tmp/run_status.json /home/freely/immortalwrt-N100/build-error-$(date +%Y%m%d-%H%M%S).log
            echo "错误日志已保存"
            exit 1
        fi
    fi
    
    sleep 180  # 每 3 分钟检查一次
    ELAPSED=$((ELAPSED + 180))
done

echo "超时，构建仍未完成"
exit 1
