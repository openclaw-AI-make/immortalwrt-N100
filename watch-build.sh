#!/bin/bash
# 持续监控构建直到完成
set -e
cd /home/freely/immortalwrt-N100

TOKEN=$(cat /home/freely/.gh_token.txt)
REPO="openclaw-AI-make/immortalwrt-N100"
MAX_CHECKS=20

echo "=== 开始监控构建 ==="
echo "最大检查次数：$MAX_CHECKS"
echo "检查间隔：180 秒"
echo ""

for i in $(seq 1 $MAX_CHECKS); do
    # 获取最新运行
    curl -sL -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/actions/runs?per_page=1" \
        -o /tmp/run_status.json
    
    # 解析状态
    eval $(python3 << 'PYEOF'
import json
with open("/tmp/run_status.json") as f:
    d = json.load(f)
r = d["workflow_runs"][0]
print(f"RUN_STATUS={r['status']}")
print(f"RUN_CONCLUSION={r.get('conclusion', 'null')}")
print(f"RUN_NUMBER={r['run_number']}")
print(f"RUN_ID={r['id']}")
PYEOF
)
    
    echo "[$i/$MAX_CHECKS] Run #$RUN_NUMBER (ID: $RUN_ID)"
    echo "  状态：$RUN_STATUS"
    echo "  结论：$RUN_CONCLUSION"
    
    if [ "$RUN_STATUS" != "in_progress" ]; then
        echo ""
        if [ "$RUN_CONCLUSION" = "success" ]; then
            echo "✓ 构建成功！"
            echo "BUILD_STATUS=success" > /tmp/build_result.txt
            exit 0
        else
            echo "✗ 构建失败，开始分析..."
            echo "BUILD_STATUS=failed" > /tmp/build_result.txt
            echo "RUN_ID=$RUN_ID" >> /tmp/build_result.txt
            
            # 获取 Job 列表
            curl -sL -H "Authorization: token $TOKEN" \
                "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/jobs" \
                -o /tmp/failed_jobs.json
            
            # 获取失败 Job ID
            JOB_ID=$(python3 << PYEOF
import json
with open("/tmp/failed_jobs.json") as f:
    d = json.load(f)
for job in d.get("jobs", []):
    if job.get("conclusion") == "failure":
        print(job["id"])
        break
PYEOF
)
            
            if [ -n "$JOB_ID" ]; then
                echo "失败 Job ID: $JOB_ID"
                
                # 获取日志
                curl -sL -H "Authorization: token $TOKEN" \
                    "https://api.github.com/repos/$REPO/actions/jobs/$JOB_ID/logs" \
                    -o /tmp/failed_job.log
                
                # 分析错误
                ERROR_TYPE="unknown"
                if grep -qi "po2lmo.*not found" /tmp/failed_job.log; then
                    ERROR_TYPE="po2lmo_missing"
                    echo "错误类型：po2lmo 命令未找到"
                elif grep -qi "luci-base.*not found" /tmp/failed_job.log; then
                    ERROR_TYPE="luci_deps_missing"
                    echo "错误类型：luci-base 依赖缺失"
                elif grep -qi "feeds.*not found" /tmp/failed_job.log; then
                    ERROR_TYPE="feeds_missing"
                    echo "错误类型：feeds 未安装"
                elif grep -qi "dependency.*not found" /tmp/failed_job.log; then
                    ERROR_TYPE="pkg_dependency"
                    echo "错误类型：包依赖问题"
                else
                    echo "错误类型：未知"
                    echo "日志末尾 50 行:"
                    tail -50 /tmp/failed_job.log
                fi
                
                # 保存错误日志
                cp /tmp/failed_job.log "/home/freely/immortalwrt-N100/build-error-$(date +%Y%m%d-%H%M%S).log"
                
                # 尝试自动修复
                if [ "$ERROR_TYPE" = "po2lmo_missing" ] || [ "$ERROR_TYPE" = "luci_deps_missing" ] || [ "$ERROR_TYPE" = "feeds_missing" ]; then
                    echo ""
                    echo "尝试自动修复..."
                    
                    WORKFLOW_FILE=".github/workflows/build-immortalwrt.yml"
                    
                    # 检查 workflow 是否有 feeds install
                    if ! grep -q "scripts/feeds install -a" "$WORKFLOW_FILE"; then
                        echo "添加 feeds install 步骤到 workflow..."
                        sed -i 's|scripts/feeds update -a|scripts/feeds update -a\n          ./scripts/feeds install -a|g' "$WORKFLOW_FILE"
                        
                        # 提交推送
                        git add .
                        GIT_EDITOR=true git commit -m "fix: auto-fix $ERROR_TYPE"
                        git remote set-url origin "https://$TOKEN@github.com/$REPO.git"
                        git push
                        
                        echo "✓ 修复已提交推送，新构建将自动触发"
                    else
                        echo "workflow 已有 feeds install，检查 diy-part.sh..."
                    fi
                else
                    echo "错误类型 $ERROR_TYPE 无法自动修复"
                fi
                
                exit 1
            fi
            exit 1
        fi
    fi
    
    echo "  → 构建进行中，等待 180 秒..."
    echo ""
    sleep 180
done

echo "监控超时 (达到最大检查次数)"
echo "BUILD_STATUS=timeout" > /tmp/build_result.txt
exit 2
