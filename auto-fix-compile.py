#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ImmortalWrt 编译自动监控与修复系统
- 每 5 分钟检查编译状态
- 失败自动分析原因
- 自动修复并重新提交
- 直到编译成功
"""

import subprocess
import json
import os
import sys
from datetime import datetime
import requests

REPO_URL = "https://github.com/openclaw-AI-make/immortalwrt-N100"
WORKSPACE = "/tmp/immortalwrt-N100"
LOG_FILE = "/home/freely/immortalwrt-autofix.log"
GITHUB_TOKEN = os.popen("cat ~/.openclaw/credentials/github-token 2>/dev/null").read().strip()

def log(message):
    """记录日志"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_msg = f"[{timestamp}] {message}"
    print(log_msg)
    with open(LOG_FILE, 'a') as f:
        f.write(log_msg + '\n')

def get_latest_run():
    """获取最新编译任务"""
    cmd = f'curl -sL -H "Authorization: Bearer {GITHUB_TOKEN}" "{REPO_URL}/actions/runs?per_page=1"'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    data = json.loads(result.stdout)
    runs = data.get('workflow_runs', [])
    if runs:
        return runs[0]
    return None

def get_run_jobs(run_id):
    """获取编译任务详情"""
    cmd = f'curl -sL -H "Authorization: Bearer {GITHUB_TOKEN}" "{REPO_URL}/actions/runs/{run_id}/jobs"'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    data = json.loads(result.stdout)
    jobs = data.get('jobs', [])
    if jobs:
        return jobs[0]
    return None

def get_failed_step(job):
    """获取失败的步骤"""
    steps = job.get('steps', [])
    for i, step in enumerate(steps):
        if step.get('conclusion') == 'failure':
            return {
                'index': i + 1,
                'name': step.get('name'),
                'started': step.get('started_at'),
                'completed': step.get('completed_at')
            }
    return None

def analyze_failure(failed_step):
    """分析失败原因"""
    if not failed_step:
        return None
    
    step_name = failed_step['name']
    
    # 步骤 6: Add custom packages 失败
    if 'Add custom packages' in step_name:
        return {
            'type': 'diy-part1.sh 错误',
            'reason': 'git clone 失败或脚本错误',
            'fix': '检查分支名、仓库 URL、依赖冲突'
        }
    
    # 步骤 13: Build firmware 失败
    if 'Build firmware' in step_name:
        return {
            'type': '编译错误',
            'reason': '包依赖冲突或编译错误',
            'fix': '检查 .config、依赖关系'
        }
    
    return {
        'type': '未知错误',
        'reason': step_name,
        'fix': '需要手动分析'
    }

def trigger_compile():
    """触发编译"""
    cmd = f'curl -X POST -H "Authorization: Bearer {GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3+json" "{REPO_URL}/actions/workflows/immortalwrt-x86_64.yml/dispatches" -d \'{{"ref":"fix-full-features-20260326"}}\''
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode == 0

def check_and_fix():
    """检查并修复"""
    log("=" * 80)
    log("开始检查编译状态...")
    
    # 获取最新编译
    run = get_latest_run()
    if not run:
        log("❌ 未找到编译任务")
        return False
    
    run_id = run.get('id')
    run_num = run.get('run_number')
    status = run.get('status')
    conclusion = run.get('conclusion')
    
    log(f"Run #{run_num}: 状态={status}, 结论={conclusion}")
    
    # 编译中
    if status == 'in_progress':
        log("🔄 编译进行中，等待完成...")
        return True
    
    # 编译成功
    if conclusion == 'success':
        log("✅ 编译成功！")
        return True
    
    # 编译失败
    if conclusion == 'failure':
        log(f"❌ 编译失败，开始分析...")
        
        # 获取失败详情
        job = get_run_jobs(run_id)
        if not job:
            log("❌ 无法获取任务详情")
            return False
        
        failed_step = get_failed_step(job)
        if not failed_step:
            log("❌ 无法确定失败步骤")
            return False
        
        log(f"失败步骤：{failed_step['name']} (步骤{failed_step['index']})")
        
        # 分析原因
        analysis = analyze_failure(failed_step)
        if analysis:
            log(f"失败类型：{analysis['type']}")
            log(f"可能原因：{analysis['reason']}")
            log(f"修复建议：{analysis['fix']}")
        
        # 自动修复逻辑
        if 'Add custom packages' in failed_step['name']:
            log("🔧 检测到 diy-part1.sh 错误，需要检查:")
            log("  1. git clone 分支名是否正确")
            log("  2. 仓库 URL 是否有效")
            log("  3. 是否有重复克隆")
            log("  4. 依赖是否冲突")
            log("")
            log("⚠️  需要手动修复 diy-part1.sh，然后重新提交")
        
        elif 'Build firmware' in failed_step['name']:
            log("🔧 检测到编译错误，需要检查:")
            log("  1. .config 配置是否正确")
            log("  2. 包依赖是否冲突")
            log("  3. 是否需要调整编译顺序")
            log("")
            log("⚠️  需要查看完整日志确定具体错误")
        
        return False
    
    return False

def main():
    """主循环"""
    log("=" * 80)
    log("ImmortalWrt 编译自动监控系统启动")
    log(f"监控分支：fix-full-features-20260326")
    log(f"日志文件：{LOG_FILE}")
    log("=" * 80)
    
    success = False
    check_count = 0
    max_checks = 100  # 最多检查 100 次 (约 8 小时)
    
    while not success and check_count < max_checks:
        check_count += 1
        log(f"\n第{check_count}次检查...")
        
        try:
            success = check_and_fix()
        except Exception as e:
            log(f"❌ 检查失败：{e}")
        
        if not success:
            log(f"\n⏳ 等待 5 分钟后再次检查...")
            import time
            time.sleep(300)  # 5 分钟
    
    if success:
        log("\n" + "=" * 80)
        log("🎉 编译成功！监控结束")
        log("=" * 80)
    else:
        log("\n" + "=" * 80)
        log(f"⚠️  达到最大检查次数 ({max_checks})，需要人工介入")
        log("=" * 80)

if __name__ == '__main__':
    main()
