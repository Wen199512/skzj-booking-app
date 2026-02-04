@echo off
echo ==========================================
echo   上传 zh.txt 到 GitHub
echo ==========================================
echo.

cd /d "%~dp0.."

echo [1/4] 检查 zh.txt 文件...
if not exist "skzj\zh.txt" (
    echo [ERROR] 找不到 zh.txt 文件！
    echo 位置: skzj\zh.txt
    pause
    exit /b 1
)

echo ? zh.txt 文件存在
echo.

echo [2/4] 查看 zh.txt 内容（前5行）:
type skzj\zh.txt | more /n +1

echo.
echo [3/4] 添加到 Git...
git add skzj\zh.txt
git add .gitignore

echo.
echo [4/4] 提交到 Git...
git commit -m "添加账号文件 zh.txt 用于在线验证"

if errorlevel 1 (
    echo.
    echo [INFO] 没有新的更改需要提交
) else (
    echo.
    echo ? 提交成功
)

echo.
echo ==========================================
echo   准备推送到 GitHub
echo ==========================================
echo.
echo 推送后，APP 将从以下地址读取账号:
echo https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt
echo.
set /p CONFIRM="是否立即推送到 GitHub? (y/n): "

if /i "%CONFIRM%"=="y" (
    echo.
    echo 正在推送到 GitHub...
    git push origin main
    
    if errorlevel 1 (
        echo.
        echo [ERROR] 推送失败！
        echo.
        echo 可能的原因:
        echo 1. 需要先在 GitHub Desktop 中登录
        echo 2. 仓库不存在
        echo 3. 没有网络连接
        echo.
        echo 建议: 使用 GitHub Desktop 进行推送
        pause
        exit /b 1
    ) else (
        echo.
        echo ==========================================
        echo   上传成功！
        echo ==========================================
        echo.
        echo ? zh.txt 已上传到 GitHub
        echo.
        echo 在线地址:
        echo https://github.com/Wen199512/skzj-booking-app/blob/main/skzj/zh.txt
        echo.
        echo 原始文件地址（APP 使用）:
        echo https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt
        echo.
        echo 下一步:
        echo 1. 构建新的 APK
        echo 2. APP 将自动从 GitHub 读取账号
        echo 3. 以后修改账号只需上传新的 zh.txt
        echo.
    )
) else (
    echo.
    echo 已取消推送
    echo.
    echo 稍后可以手动推送:
    echo   git push origin main
    echo.
    echo 或在 GitHub Desktop 中点击 "Push origin"
)

pause
