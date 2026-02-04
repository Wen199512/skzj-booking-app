@echo off
echo ==========================================
echo   修复 Git 仓库并推送到 GitHub
echo ==========================================
echo.

REM 切换到正确的目录
cd /d "%~dp0.."

echo 当前目录:
cd
echo.

REM 检查是否有 .git 目录
if exist ".git" (
    echo [INFO] Git 仓库已存在
) else (
    echo [1/5] 初始化 Git 仓库...
    git init
    git branch -M main
)

REM 检查远程仓库
echo.
echo [2/5] 配置远程仓库...
git remote remove origin 2>nul
git remote add origin https://github.com/Wen199512/skzj-booking-app.git

echo 远程仓库配置:
git remote -v
echo.

REM 添加所有文件
echo [3/5] 添加文件...
git add .

REM 提交
echo.
echo [4/5] 提交代码...
git commit -m "Initial commit: 首矿之家活动预约系统" 2>nul
if errorlevel 1 (
    echo [INFO] 没有新的更改需要提交，或已提交
)

REM 推送到 GitHub
echo.
echo [5/5] 推送到 GitHub...
echo.
echo 注意: 如果这是第一次推送，可能需要登录 GitHub
echo.
git push -u origin main

if errorlevel 1 (
    echo.
    echo ==========================================
    echo   推送失败！
    echo ==========================================
    echo.
    echo 可能的原因:
    echo 1. 需要 GitHub 身份验证
    echo 2. 仓库不存在或没有权限
    echo.
    echo 解决方法:
    echo.
    echo 方法 1: 使用 GitHub CLI 登录
    echo   gh auth login
    echo.
    echo 方法 2: 使用个人访问令牌
    echo   1. 访问: https://github.com/settings/tokens
    echo   2. 创建新的 Personal Access Token
    echo   3. 使用令牌作为密码
    echo.
    echo 方法 3: 使用 SSH
    echo   1. 生成 SSH 密钥: ssh-keygen
    echo   2. 添加到 GitHub: https://github.com/settings/keys
    echo   3. 修改远程地址: git remote set-url origin git@github.com:Wen199512/skzj-booking-app.git
    echo.
) else (
    echo.
    echo ==========================================
    echo   推送成功！
    echo ==========================================
    echo.
    echo 仓库地址: https://github.com/Wen199512/skzj-booking-app
    echo.
    echo 下一步:
    echo 1. 访问仓库查看文件
    echo 2. 配置 GitHub Actions
    echo 3. 使用 github-release.bat 发布版本
    echo.
)

pause
