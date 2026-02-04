@echo off
echo ==========================================
echo   GitHub 仓库初始化工具
echo ==========================================
echo.

REM 检查 Git 是否已安装
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git 未安装！
    echo.
    echo 请先安装 Git:
    echo https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [1/5] 检查 Git 配置...
git config user.name >nul 2>&1
if errorlevel 1 (
    echo.
    set /p GIT_NAME="请输入您的 Git 用户名: "
    git config --global user.name "!GIT_NAME!"
)

git config user.email >nul 2>&1
if errorlevel 1 (
    echo.
    set /p GIT_EMAIL="请输入您的 Git 邮箱: "
    git config --global user.email "!GIT_EMAIL!"
)

echo Git 用户: 
git config user.name
echo Git 邮箱: 
git config user.email
echo.

REM 检查是否已初始化
if exist ".git" (
    echo [INFO] Git 仓库已初始化
    git remote -v
    echo.
    set /p REINIT="是否重新初始化? (y/n): "
    if /i not "!REINIT!"=="y" (
        echo 已取消
        pause
        exit /b 0
    )
    rmdir /s /q .git
)

echo [2/5] 初始化 Git 仓库...
git init
git branch -M main

echo.
echo [3/5] 创建 .gitignore...
if not exist ".gitignore" (
    echo 已创建 .gitignore
) else (
    echo .gitignore 已存在
)

echo.
echo [4/5] 添加文件...
git add .
git commit -m "Initial commit: 首矿之家活动预约系统"

echo.
echo [5/5] 配置远程仓库...
echo.
echo 请访问 GitHub 创建新仓库:
echo https://github.com/new
echo.
echo 创建完成后，复制仓库 URL (例如: https://github.com/username/repo.git)
echo.
set /p REPO_URL="请输入仓库 URL: "

if "!REPO_URL!"=="" (
    echo [WARNING] 未输入仓库 URL，跳过远程配置
    echo.
    echo 稍后可以手动添加:
    echo   git remote add origin YOUR_REPO_URL
    echo   git push -u origin main
) else (
    git remote add origin !REPO_URL!
    
    echo.
    echo 推送到 GitHub...
    git push -u origin main
    
    if errorlevel 1 (
        echo [ERROR] 推送失败！
        echo.
        echo 可能需要配置 GitHub 认证
        echo 请参考: https://docs.github.com/zh/authentication
    ) else (
        echo.
        echo ==========================================
        echo   初始化成功！
        echo ==========================================
        echo.
        echo 仓库地址: !REPO_URL!
        echo.
        echo 下一步:
        echo 1. 配置 GitHub Actions (已包含在项目中)
        echo 2. 使用 github-release.bat 发布新版本
        echo.
    )
)

pause
