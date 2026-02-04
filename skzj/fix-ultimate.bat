@echo off
setlocal
title Android SDK - Force Fix v36.1.12

echo ==========================================
echo   Android SDK - Ultimate Fix
echo ==========================================
echo.
echo This will force the use of SDK 36.1.12
echo.

cd /d "%~dp0"

REM Define exact SDK paths
set "SDK_36=C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\36.1.12\tools"
set "SDK_35=C:\Program Files\dotnet\packs\Microsoft.Android.Sdk.Windows\35.0.105\tools"
set "SDK_TO_USE="

echo Checking installed SDK versions...
echo.

REM Check for 36.1.12 (preferred)
if exist "%SDK_36%" (
    echo [OK] Found SDK 36.1.12
    set "SDK_TO_USE=%SDK_36%"
    set "SDK_VER=36.1.12"
    goto :configure
)

REM Fallback to 35.0.105
if exist "%SDK_35%" (
    echo [OK] Found SDK 35.0.105
    set "SDK_TO_USE=%SDK_35%"
    set "SDK_VER=35.0.105"
    goto :configure
)

REM No SDK found
echo [ERROR] No SDK found!
echo.
echo Expected locations:
echo   %SDK_36%
echo   %SDK_35%
echo.
echo Please install Android workload:
echo   dotnet workload install android
echo.
pause
exit /b 1

:configure
echo.
echo ==========================================
echo   Configuration
echo ==========================================
echo.
echo Using SDK version: %SDK_VER%
echo Path: %SDK_TO_USE%
echo.

REM Set environment variable
echo Setting ANDROID_HOME...
setx ANDROID_HOME "%SDK_TO_USE%" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Could not set permanent variable
    echo You may need to run as Administrator
) else (
    echo [OK] ANDROID_HOME set permanently
)

REM Set for current session
set "ANDROID_HOME=%SDK_TO_USE%"
echo [OK] Set for current session

echo.
echo Creating Directory.Build.props...

REM Create strong configuration file
(
echo ^<Project^>
echo   ^<PropertyGroup^>
echo     ^<!-- Force use of specific Android SDK version --^>
echo     ^<AndroidSdkDirectory^>%SDK_TO_USE%^</AndroidSdkDirectory^>
echo     
echo     ^<!-- Ignore invalid Java SDK from PATH --^>
echo     ^<JavaSdkDirectory^>^</JavaSdkDirectory^>
echo   ^</PropertyGroup^>
echo ^</Project^>
) > Directory.Build.props

echo [OK] Configuration file created

echo.
echo Cleaning previous build...
dotnet clean -f net9.0-android >nul 2>&1

echo Restoring packages...
dotnet restore -f net9.0-android >nul 2>&1

echo.
echo Testing build with SDK %SDK_VER%...
echo Please wait...
echo.

REM Test build with explicit SDK
dotnet build -f net9.0-android -c Release -p:AndroidSdkDirectory="%SDK_TO_USE%"

if errorlevel 1 (
    echo.
    echo ==========================================
    echo   Build Failed
    echo ==========================================
    echo.
    echo The build failed even with explicit SDK path.
    echo.
    echo Possible issues:
    echo   1. SDK installation is corrupted
    echo      Solution: dotnet workload repair
    echo.
    echo   2. Missing components
    echo      Solution: dotnet workload install android
    echo.
    echo   3. ANDROID_HOME not taking effect
    echo      Solution: Close ALL terminals and try again
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   SUCCESS!
echo ==========================================
echo.
echo Configuration complete:
echo   SDK Version: %SDK_VER%
echo   SDK Path: %SDK_TO_USE%
echo   ANDROID_HOME: Set
echo   Directory.Build.props: Created
echo   Test Build: PASSED
echo.
echo IMPORTANT NEXT STEPS:
echo   1. CLOSE this terminal window
echo   2. Open a NEW terminal
echo   3. Verify: echo %%ANDROID_HOME%%
echo   4. Run: publish-quick.bat
echo.
echo Your Android SDK is now properly configured!
echo.
pause
