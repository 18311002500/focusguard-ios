#!/bin/bash
# 上传到 GitHub 脚本
# 使用方法：在本地运行此脚本

echo "================================"
echo "FocusGuard GitHub 上传脚本"
echo "================================"
echo ""

# 检查是否安装了 git
if ! command -v git &> /dev/null; then
    echo "❌ 错误：未安装 git"
    echo "请访问 https://git-scm.com/downloads 安装"
    exit 1
fi

# 仓库地址
REPO_URL="https://github.com/18311002500/focusguard-ios.git"

echo "📦 准备上传代码到: $REPO_URL"
echo ""

# 提示用户输入
read -p "代码文件夹路径 (默认: 当前目录): " CODE_PATH
CODE_PATH=${CODE_PATH:-.}

read -p "GitHub 用户名: " USERNAME
read -sp "GitHub 密码或 Token: " PASSWORD
echo ""

echo ""
echo "🚀 开始上传..."
echo ""

# 进入代码目录
cd "$CODE_PATH" || exit 1

# 初始化 git
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# 添加远程仓库
git remote remove origin 2>/dev/null
git remote add origin "https://$USERNAME:$PASSWORD@github.com/18311002500/focusguard-ios.git"

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: FocusGuard iOS App

- ScreenTime tracking
- Focus mode with timer
- StoreKit in-app purchase
- Widget support
- GitHub Actions CI/CD"

# 推送
git push -u origin main --force

echo ""
if [ $? -eq 0 ]; then
    echo "✅ 上传成功！"
    echo ""
    echo "📋 下一步："
    echo "1. 访问 https://github.com/18311002500/focusguard-ios"
    echo "2. 检查代码是否正确上传"
    echo "3. 查看 Actions 标签页"
    echo "4. 按照 GitHubSetupGuide.md 配置 Secrets"
else
    echo "❌ 上传失败，请检查用户名密码"
fi

echo ""
echo "================================"