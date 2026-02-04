@echo off
chcp 65001 >nul
echo ========================================
echo   SKZJ Activity Booking - Quick Publish
echo ========================================
echo.

REM Check Android SDK
echo [CHECK] Verifying Android SDK...
if "%ANDROID_HOME%"=="" (
    echo [ERROR] ANDROID_HOME environment variable not found
    echo.
    echo Please install Android SDK first:
    echo   Method 1: Run setup-android-sdk.ps1
    echo   Method 2: Run dotnet workload install android
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo [OK] Android SDK: %ANDROID_HOME%
echo.

cd /d F:\vscx\skzj\skzj

if not exist "F:\vscx\skzj\skzj\skzj.csproj" (
    echo [ERROR] Project file not found!
    echo Current directory: %CD%
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo [1/3] Cleaning project...
dotnet clean -c Release -v quiet

echo [2/3] Publishing Android APK...
echo Please wait, this may take a few minutes...
echo.
dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64 -p:AndroidPackageFormat=apk

if errorlevel 1 (
    echo.
    echo [ERROR] Publish failed!
    echo.
    echo Possible reasons:
    echo   1. Android SDK not properly installed
    echo   2. Android workload not installed
    echo   3. Build errors in the project
    echo.
    echo To fix:
    echo   - Run: dotnet workload install android
    echo   - Or run: setup-android-sdk.ps1
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo [3/3] Copying to Release directory...
if not exist "F:\vscx\skzj\Release" mkdir "F:\vscx\skzj\Release"

if exist "bin\Release\net9.0-android\android-arm64\publish\*.apk" (
    copy /Y "bin\Release\net9.0-android\android-arm64\publish\*.apk" "F:\vscx\skzj\Release\"
    echo APK copied successfully!
) else (
    echo [WARNING] APK file not found in expected location
    echo Searching for APK files...
    dir /s /b bin\Release\*.apk
)

echo.
echo ========================================
echo   Publish Complete!
echo ========================================
echo.
echo APK Location: F:\vscx\skzj\Release\
echo.

if exist "F:\vscx\skzj\Release" (
    explorer "F:\vscx\skzj\Release"
) else (
    echo Release directory not found
)

echo.
echo Press any key to exit...
pause >nul
