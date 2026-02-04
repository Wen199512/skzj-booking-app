@echo off
setlocal

echo ==========================================
echo   SKZJ Activity Booking - Quick Publish
echo ==========================================
echo.

REM Navigate to script directory
cd /d "%~dp0"

echo Current directory: %CD%
echo.

REM Check if project file exists
if not exist "skzj.csproj" (
    echo [ERROR] Project file not found!
    echo Expected: %CD%\skzj.csproj
    echo.
    pause
    exit /b 1
)

REM Determine Android SDK path
set "SDK_PATH="

REM Try 36.1.12 first
if exist "C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\36.1.12\tools" (
    set "SDK_PATH=C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\36.1.12\tools"
    set "SDK_VER=36.1.12"
)

REM Fallback to 35.0.105
if not defined SDK_PATH (
    if exist "C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\35.0.105\tools" (
        set "SDK_PATH=C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\35.0.105\tools"
        set "SDK_VER=35.0.105"
    )
)

REM Fallback to ANDROID_HOME
if not defined SDK_PATH (
    if defined ANDROID_HOME (
        set "SDK_PATH=%ANDROID_HOME%"
        set "SDK_VER=from ANDROID_HOME"
    )
)

REM Check if we found SDK
if not defined SDK_PATH (
    echo [ERROR] Cannot find Android SDK!
    echo.
    echo Please run: fix-ultimate.bat
    echo.
    pause
    exit /b 1
)

echo [CHECK] Android SDK...
echo   Version: %SDK_VER%
echo   Path: %SDK_PATH%
echo.

echo [1/4] Cleaning project...
dotnet clean -f net9.0-android -c Release -v minimal

echo.
echo [2/4] Restoring packages...
dotnet restore -f net9.0-android

echo.
echo [3/4] Publishing Android APK...
echo This may take several minutes, please wait...
echo.

REM Publish with explicit SDK path
dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64 -p:AndroidPackageFormat=apk -p:AndroidSdkDirectory="%SDK_PATH%"

if errorlevel 1 (
    echo.
    echo [ERROR] Publish failed!
    echo.
    echo Try the following:
    echo   1. Run: fix-ultimate.bat
    echo   2. Close all terminals
    echo   3. Open new terminal
    echo   4. Run this script again
    echo.
    pause
    exit /b 1
)

echo.
echo [4/4] Copying APK to Release folder...

REM Create Release directory
set "RELEASE_DIR=%~dp0..\Release"
if not exist "%RELEASE_DIR%" mkdir "%RELEASE_DIR%"

REM Find and copy APK files
set "APK_FOUND=0"
for /r "bin\Release" %%F in (*.apk) do (
    echo Found: %%~nxF
    echo Copying to: %RELEASE_DIR%
    copy /Y "%%F" "%RELEASE_DIR%\" >nul
    set "APK_FOUND=1"
)

if "%APK_FOUND%"=="0" (
    echo [ERROR] No APK files found!
    echo.
    echo Searching...
    dir /s /b bin\*.apk 2>nul
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   Success!
echo ==========================================
echo.
echo APK Location: %RELEASE_DIR%
echo.

REM List generated files
echo Generated files:
dir /b "%RELEASE_DIR%\*.apk" 2>nul

echo.
echo Opening output directory...
start "" explorer "%RELEASE_DIR%"

echo.
echo Press any key to exit...
pause >nul
exit /b 0
