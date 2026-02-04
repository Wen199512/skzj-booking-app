@echo off
setlocal EnableDelayedExpansion

echo ==========================================
echo   GitHub 快速发布工具
echo ==========================================
echo.

REM 检查是否在 Git 仓库中
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 当前目录不是 Git 仓库！
    echo.
    echo 请先初始化 Git 仓库:
    echo   git init
    echo   git remote add origin YOUR_REPO_URL
    pause
    exit /b 1
)

REM 获取当前版本号
echo [1/6] 读取当前版本号...
for /f "tokens=2 delims=<>" %%a in ('findstr "ApplicationDisplayVersion" skzj\skzj.csproj') do (
    set CURRENT_VERSION=%%a
)
echo 当前版本: !CURRENT_VERSION!
echo.

REM 输入新版本号
set /p NEW_VERSION="请输入新版本号 (例如 1.0.1): "
if "!NEW_VERSION!"=="" (
    echo [ERROR] 版本号不能为空！
    pause
    exit /b 1
)

REM 输入更新说明
echo.
echo 请输入更新说明 (输入 END 结束):
set UPDATE_NOTES=
:input_loop
set /p line="> "
if "!line!"=="END" goto :end_input
set UPDATE_NOTES=!UPDATE_NOTES!!line!
goto :input_loop
:end_input

echo.
echo ==========================================
echo   发布信息确认
echo ==========================================
echo 当前版本: !CURRENT_VERSION!
echo 新版本:   !NEW_VERSION!
echo 更新说明: !UPDATE_NOTES!
echo.
set /p CONFIRM="确认发布? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo 已取消发布
    pause
    exit /b 0
)

REM 更新版本号
echo.
echo [2/6] 更新版本号...
powershell -Command "(Get-Content skzj\skzj.csproj) -replace '<ApplicationDisplayVersion>.*</ApplicationDisplayVersion>', '<ApplicationDisplayVersion>!NEW_VERSION!</ApplicationDisplayVersion>' | Set-Content skzj\skzj.csproj"
echo 版本号已更新

REM 提交代码
echo.
echo [3/6] 提交代码...
git add .
git commit -m "release: v!NEW_VERSION! - !UPDATE_NOTES!"
if errorlevel 1 (
    echo [WARNING] 没有需要提交的更改
)

REM 创建标签
echo.
echo [4/6] 创建版本标签...
git tag -a v!NEW_VERSION! -m "Release v!NEW_VERSION!: !UPDATE_NOTES!"
if errorlevel 1 (
    echo [ERROR] 创建标签失败！
    pause
    exit /b 1
)

REM 推送代码
echo.
echo [5/6] 推送到 GitHub...
git push origin main
if errorlevel 1 (
    echo [WARNING] 推送主分支失败，尝试推送当前分支...
    for /f "tokens=*" %%a in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%a
    git push origin !CURRENT_BRANCH!
)

REM 推送标签
echo.
echo [6/6] 推送版本标签...
git push origin v!NEW_VERSION!
if errorlevel 1 (
    echo [ERROR] 推送标签失败！
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   发布成功！
echo ==========================================
echo.
echo 版本: v!NEW_VERSION!
echo.
echo GitHub Actions 将自动构建并创建 Release
echo.
echo 查看进度:
echo https://github.com/YOUR_USERNAME/skzj-booking-app/actions
echo.
echo 发布完成后可在以下地址下载:
echo https://github.com/YOUR_USERNAME/skzj-booking-app/releases
echo.
pause
