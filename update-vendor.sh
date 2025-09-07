#!/bin/bash

# 更新vscode-linux-build-agent子树的脚本

set -e

echo "正在更新vscode-linux-build-agent子树..."

# 拉取最新的vscode-linux-build-agent代码
git subtree pull --prefix=vendor/vscode-linux-build-agent https://github.com/microsoft/vscode-linux-build-agent.git main --squash

echo "子树更新完成！"

# 显示更新后的状态
echo "当前子树状态："
git log --oneline -1 vendor/vscode-linux-build-agent

echo ""
echo "如果需要提交更改，请运行："
echo "git add vendor/vscode-linux-build-agent"
echo "git commit -m 'Update vscode-linux-build-agent subtree'"
