@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   Publish Troubleshooting Diagnostic
echo ==========================================
echo.
echo This script will help diagnose publish issues
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo Script location: %SCRIPT_DIR%
echo Current directory: %CD%
echo.

REM Check 1: Project file
echo [1] Checking project file...
if exist "skzj.csproj" (
    echo [OK] Project file found: skzj.csproj
) else (
    echo [ERROR] Project file NOT found!
    echo Expected location: %CD%\skzj.csproj
)
echo.

REM Check 2: .NET SDK
echo [2] Checking .NET SDK...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] dotnet command not found!
    echo Please install .NET SDK from: https://dotnet.microsoft.com/download
) else (
    echo [OK] .NET SDK version:
    dotnet --version
)
echo.

REM Check 3: Android workload
echo [3] Checking Android workload...
echo Running: dotnet workload list
echo.
dotnet workload list 2>nul | findstr /C:"android"
if errorlevel 1 (
    echo.
    echo [ERROR] Android workload NOT installed
    echo.
    echo To install:
    echo   Method 1: Run install-android-sdk.bat
    echo   Method 2: dotnet workload install android
) else (
    echo.
    echo [OK] Android workload is installed
)
echo.

REM Check 4: Environment variables
echo [4] Checking environment variables...
if defined ANDROID_HOME (
    echo [OK] ANDROID_HOME: %ANDROID_HOME%
    if exist "%ANDROID_HOME%" (
        echo [OK] Directory exists
        
        REM Check for platform-tools
        if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
            echo [OK] ADB found
        ) else (
            echo [WARNING] ADB not found in platform-tools
        )
    ) else (
        echo [ERROR] Directory does NOT exist!
    )
) else (
    echo [WARNING] ANDROID_HOME not set
    echo This is optional if Android workload is installed
)
echo.

if defined ANDROID_SDK_ROOT (
    echo [INFO] ANDROID_SDK_ROOT: %ANDROID_SDK_ROOT%
) else (
    echo [INFO] ANDROID_SDK_ROOT not set (optional)
)
echo.

REM Check 5: Java SDK (optional)
echo [5] Checking Java SDK...
if defined JAVA_HOME (
    echo [OK] JAVA_HOME: %JAVA_HOME%
) else (
    echo [INFO] JAVA_HOME not set (will use bundled JDK)
)
echo.

REM Check 6: Project can build
echo [6] Testing project build (Debug)...
echo Running: dotnet build -f net9.0-android -c Debug
echo.
dotnet build -f net9.0-android -c Debug -v minimal
if errorlevel 1 (
    echo.
    echo [ERROR] Project build FAILED!
    echo Please fix compilation errors first
) else (
    echo.
    echo [OK] Project builds successfully
)
echo.

REM Check 7: zh.txt file
echo [7] Checking zh.txt file...
if exist "zh.txt" (
    echo [OK] zh.txt found
    for %%A in ("zh.txt") do echo File size: %%~zA bytes
    
    REM Count lines
    set "LINE_COUNT=0"
    for /f %%a in ('type "zh.txt" ^| find /c /v ""') do set "LINE_COUNT=%%a"
    echo Accounts: !LINE_COUNT!
) else (
    echo [WARNING] zh.txt not found
)
echo.

REM Check 8: Release directory
echo [8] Checking output directories...
if exist "bin\Release\net9.0-android" (
    echo [OK] Previous build artifacts found
    
    REM Check for APK files
    dir /s /b "bin\Release\*.apk" 2>nul | findstr /C:".apk" >nul
    if errorlevel 1 (
        echo [INFO] No APK files from previous builds
    ) else (
        echo [INFO] Found previous APK files:
        dir /s /b "bin\Release\*.apk" 2>nul
    )
) else (
    echo [INFO] No previous build artifacts
)
echo.

REM Summary
echo ==========================================
echo   Diagnostic Summary
echo ==========================================
echo.

set "CRITICAL_ISSUES=0"
set "WARNINGS=0"

if not exist "skzj.csproj" (
    echo [!] CRITICAL: Project file missing
    set /a CRITICAL_ISSUES+=1
)

dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [!] CRITICAL: .NET SDK not found
    set /a CRITICAL_ISSUES+=1
)

dotnet workload list 2>nul | findstr /C:"android" >nul
if errorlevel 1 (
    echo [!] CRITICAL: Android workload not installed
    set /a CRITICAL_ISSUES+=1
)

if not defined ANDROID_HOME (
    dotnet workload list 2>nul | findstr /C:"android" >nul
    if errorlevel 1 (
        echo [!] WARNING: ANDROID_HOME not set and workload missing
        set /a WARNINGS+=1
    )
)

echo.
if %CRITICAL_ISSUES% EQU 0 (
    echo [OK] No critical issues found!
    echo.
    if %WARNINGS% GTR 0 (
        echo Found %WARNINGS% warning(s) - you may still be able to publish.
    ) else (
        echo Your environment is ready to publish.
    )
    echo.
    echo Next steps:
    echo   1. Run: publish-quick.bat
    echo   2. Or run: dotnet publish -f net9.0-android -c Release
) else (
    echo Found %CRITICAL_ISSUES% critical issue(s) that must be fixed.
    echo.
    echo Required actions:
    echo.
    if not exist "skzj.csproj" (
        echo   [!] Ensure you run this script from the project folder
    )
    
    dotnet --version >nul 2>&1
    if errorlevel 1 (
        echo   [!] Install .NET SDK from: https://dotnet.microsoft.com
    )
    
    dotnet workload list 2>nul | findstr /C:"android" >nul
    if errorlevel 1 (
        echo   [!] Run: install-android-sdk.bat
        echo       Or: dotnet workload install android
    )
)

echo.
echo ==========================================
echo.
echo For detailed help, see: XA5300´íÎóÐÞ¸´.md
echo.
echo Press any key to exit...
pause >nul
