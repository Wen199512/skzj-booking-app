@echo off
setlocal
title Android SDK - Complete Fix

echo ========================================
echo   Complete Android SDK Fix
echo ========================================
echo.
echo This will:
echo   1. Find your Android SDK
echo   2. Set ANDROID_HOME
echo   3. Update project configuration
echo   4. Test the build
echo.
pause

cd /d "%~dp0"

REM Step 1: Find SDK
echo.
echo Step 1/4: Finding Android SDK...
echo.

set "SDK_BASE=%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows"
set "SDK_PATH="

if not exist "%SDK_BASE%" (
    echo [ERROR] SDK base directory not found!
    echo Please install: dotnet workload install android
    goto :error
)

REM Find latest version
for /f "delims=" %%V in ('dir /b /ad /o-n "%SDK_BASE%" 2^>nul') do (
    if exist "%SDK_BASE%\%%V\tools" (
        set "SDK_PATH=%SDK_BASE%\%%V\tools"
        set "SDK_VERSION=%%V"
        goto :found
    )
)

:found
if not defined SDK_PATH (
    echo [ERROR] No valid SDK found!
    goto :error
)

echo [OK] Found SDK version: %SDK_VERSION%
echo [OK] Path: %SDK_PATH%

REM Step 2: Set environment variable
echo.
echo Step 2/4: Setting ANDROID_HOME...
echo.

setx ANDROID_HOME "%SDK_PATH%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Could not set permanent variable (may need Admin)
    echo Setting for current session only...
) else (
    echo [OK] ANDROID_HOME set permanently
)

set "ANDROID_HOME=%SDK_PATH%"
echo Current session: %ANDROID_HOME%

REM Step 3: Update project config
echo.
echo Step 3/4: Updating Directory.Build.props...
echo.

(
echo ^<Project^>
echo   ^<PropertyGroup^>
echo     ^<AndroidSdkDirectory^>%SDK_PATH%^</AndroidSdkDirectory^>
echo   ^</PropertyGroup^>
echo ^</Project^>
) > Directory.Build.props

echo [OK] Configuration file updated

REM Step 4: Test build
echo.
echo Step 4/4: Testing build...
echo.

dotnet clean -f net9.0-android >nul 2>&1
dotnet restore -f net9.0-android >nul 2>&1

echo Running test build (this may take a minute)...
dotnet build -f net9.0-android -c Release -v quiet

if errorlevel 1 (
    echo.
    echo [ERROR] Test build failed!
    echo.
    echo Try the following:
    echo   1. Close this window
    echo   2. Open a new terminal
    echo   3. Run: dotnet build -f net9.0-android
    echo.
    goto :error
)

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Android SDK is now configured:
echo   Version: %SDK_VERSION%
echo   Path: %SDK_PATH%
echo   Test build: PASSED
echo.
echo Next steps:
echo   1. Close this terminal
echo   2. Open a new terminal
echo   3. Run: publish-quick.bat
echo.
echo Your app is ready to publish!
echo.
pause
exit /b 0

:error
echo.
echo ========================================
echo   ERROR
echo ========================================
echo.
echo Could not complete setup.
echo.
echo Manual steps:
echo   1. Run: dotnet workload install android
echo   2. Wait for completion
echo   3. Run this script again
echo.
pause
exit /b 1
