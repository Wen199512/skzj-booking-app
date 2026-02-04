@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   Android SDK Installation Guide
echo ==========================================
echo.
echo This will install the .NET Android workload
echo which includes the Android SDK.
echo.
echo Estimated time: 10-30 minutes
echo Download size: 1-3 GB
echo.

pause

echo.
echo Step 1/3: Updating workloads...
dotnet workload update

if errorlevel 1 (
    echo [WARNING] Workload update failed, continuing...
)

echo.
echo Step 2/3: Installing Android workload...
echo This will take several minutes, please wait...
echo.

dotnet workload install android

if errorlevel 1 (
    echo.
    echo [ERROR] Installation failed!
    echo.
    echo Possible solutions:
    echo   1. Run this script as Administrator
    echo   2. Check your internet connection
    echo   3. Try: dotnet workload clean
    echo   4. Then run this script again
    echo.
    pause
    exit /b 1
)

echo.
echo Step 3/3: Verifying installation...
dotnet workload list | findstr "android"

echo.
echo ==========================================
echo   Installation Complete!
echo ==========================================
echo.
echo IMPORTANT: Please restart your terminal or Visual Studio
echo for the changes to take effect.
echo.
echo After restarting, you can run:
echo   - publish-quick.bat (to publish)
echo   - diagnose.bat (to verify setup)
echo.

pause
