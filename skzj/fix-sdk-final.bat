@echo off
echo ==========================================
echo   Android SDK Path - Final Fix
echo ==========================================
echo.

REM Find the actual SDK path
set "SDK_BASE=%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows"

echo Searching for Android SDK...
echo.

if not exist "%SDK_BASE%" (
    echo [ERROR] Microsoft.Android.Sdk.Windows not found!
    echo Location: %SDK_BASE%
    echo.
    echo Please run: dotnet workload install android
    echo.
    pause
    exit /b 1
)

echo Found SDK base directory.
echo Versions available:
dir /b /ad "%SDK_BASE%"

echo.
echo Looking for the latest version with tools...
echo.

REM Find the latest version with tools directory
set "FOUND_SDK="
for /f "delims=" %%V in ('dir /b /ad /o-n "%SDK_BASE%" 2^>nul') do (
    if exist "%SDK_BASE%\%%V\tools" (
        set "FOUND_SDK=%SDK_BASE%\%%V\tools"
        echo [OK] Found: %%V\tools
        goto :configure
    )
)

:configure
if not defined FOUND_SDK (
    echo [ERROR] No SDK version with tools directory found!
    echo.
    echo Try running: dotnet workload repair
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   Configuration
echo ==========================================
echo.
echo SDK Path: %FOUND_SDK%
echo.

REM Set environment variable
echo Setting ANDROID_HOME...
setx ANDROID_HOME "%FOUND_SDK%"

if errorlevel 1 (
    echo [ERROR] Failed to set ANDROID_HOME
    echo Try running as Administrator
    pause
    exit /b 1
)

echo [OK] ANDROID_HOME set successfully
echo.

REM Also set for current session
set "ANDROID_HOME=%FOUND_SDK%"

REM Update Directory.Build.props
echo Creating Directory.Build.props...
cd /d "%~dp0"

(
echo ^<Project^>
echo   ^<PropertyGroup^>
echo     ^<AndroidSdkDirectory^>%FOUND_SDK%^</AndroidSdkDirectory^>
echo   ^</PropertyGroup^>
echo ^</Project^>
) > Directory.Build.props

echo [OK] Directory.Build.props created
echo.

echo ==========================================
echo   Success!
echo ==========================================
echo.
echo Configuration complete:
echo   ANDROID_HOME: %FOUND_SDK%
echo   Directory.Build.props: Created
echo.
echo IMPORTANT:
echo   1. CLOSE this terminal
echo   2. Open a NEW terminal
echo   3. Run: publish-quick.bat
echo.

pause
