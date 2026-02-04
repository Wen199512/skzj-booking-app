@echo off
setlocal enabledelayedexpansion

REM 设置代码页为 UTF-8
chcp 65001 >nul 2>&1

echo ========================================
echo   首矿之家活动预约 - 快速发布
echo ========================================
echo.

REM 检查 Android SDK
echo [检查] 验证 Android SDK...
if not defined ANDROID_HOME (
    echo [错误] 未找到 ANDROID_HOME 环境变量
    echo.
    echo 请先安装 Android SDK:
    echo   方法1: 双击运行 安装AndroidSDK.bat
    echo   方法2: 运行命令 dotnet workload install android
    echo.
    goto :error_exit
)

echo [成功] Android SDK: %ANDROID_HOME%
echo.

REM 切换到项目目录
cd /d "%~dp0"
if not exist "skzj.csproj" (
    echo [错误] 未找到项目文件！
    echo 当前目录: %CD%
    echo 脚本位置: %~dp0
    echo.
    goto :error_exit
)

echo [1/4] 清理项目...
call dotnet clean -c Release -v quiet
if errorlevel 1 (
    echo [警告] 清理失败，继续执行...
)

echo.
echo [2/4] 还原 NuGet 包...
call dotnet restore
if errorlevel 1 (
    echo [错误] NuGet 包还原失败！
    goto :error_exit
)

echo.
echo [3/4] 发布 Android APK...
echo 请稍候，这可能需要几分钟...
echo.

call dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64 -p:AndroidPackageFormat=apk

if errorlevel 1 (
    echo.
    echo [错误] 发布失败！
    echo.
    echo 可能的原因:
    echo   1. Android SDK 未正确安装
    echo   2. Android 工作负载未安装
    echo   3. 项目存在编译错误
    echo.
    echo 解决方案:
    echo   - 运行: dotnet workload install android
    echo   - 或双击运行: 安装AndroidSDK.bat
    echo   - 检查项目是否可以正常构建
    echo.
    goto :error_exit
)

echo.
echo [4/4] 复制到 Release 目录...

REM 创建输出目录
set "OUTPUT_DIR=%~dp0..\Release"
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
)

REM 查找并复制 APK 文件
set "APK_FOUND=0"
for %%F in ("bin\Release\net9.0-android\android-arm64\publish\*.apk") do (
    echo 复制: %%~nxF
    copy /Y "%%F" "%OUTPUT_DIR%\" >nul
    set "APK_FOUND=1"
)

if "%APK_FOUND%"=="0" (
    echo [警告] 未在预期位置找到 APK 文件
    echo 搜索所有 APK 文件...
    dir /s /b "bin\Release\*.apk" 2>nul
    
    REM 尝试其他可能的位置
    for /r "bin\Release" %%F in (*.apk) do (
        echo 找到: %%F
        echo 复制: %%~nxF
        copy /Y "%%F" "%OUTPUT_DIR%\" >nul
        set "APK_FOUND=1"
    )
)

if "%APK_FOUND%"=="0" (
    echo [错误] 未找到任何 APK 文件！
    goto :error_exit
)

echo.
echo ========================================
echo   发布完成！
echo ========================================
echo.
echo APK 位置: %OUTPUT_DIR%
echo.

REM 显示 APK 文件信息
echo 生成的文件:
dir "%OUTPUT_DIR%\*.apk" /b 2>nul
echo.

REM 打开输出目录
if exist "%OUTPUT_DIR%" (
    start "" explorer "%OUTPUT_DIR%"
)

echo 按任意键退出...
pause >nul
exit /b 0

:error_exit
echo.
echo 按任意键退出...
pause >nul
exit /b 1
