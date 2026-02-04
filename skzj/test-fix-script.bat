@echo off
echo ==========================================
echo   Testing fix-android-path.bat
echo ==========================================
echo.

echo This script will help diagnose why fix-android-path.bat crashes
echo.

pause

echo.
echo Test 1: Checking dotnet command...
dotnet --version
if errorlevel 1 (
    echo [ERROR] dotnet command failed
) else (
    echo [OK] dotnet works
)

echo.
echo Test 2: Checking workload list...
dotnet workload list
if errorlevel 1 (
    echo [ERROR] workload list failed
) else (
    echo [OK] workload list works
)

echo.
echo Test 3: Checking for Android SDK directory...
if exist "%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows" (
    echo [OK] Microsoft.Android.Sdk.Windows exists
    echo.
    echo Versions:
    dir /b /ad "%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows"
) else (
    echo [ERROR] Microsoft.Android.Sdk.Windows not found
)

echo.
echo Test 4: Checking environment variables...
echo ANDROID_HOME: %ANDROID_HOME%
echo LOCALAPPDATA: %LOCALAPPDATA%
echo ProgramFiles: %ProgramFiles%

echo.
echo Test 5: Checking setx command...
echo This will attempt to set a test variable...
setx TEST_VAR "test_value" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] setx command failed (may need Administrator)
) else (
    echo [OK] setx works
    REM Clean up
    reg delete "HKCU\Environment" /v TEST_VAR /f >nul 2>&1
)

echo.
echo ==========================================
echo   Test Results
echo ==========================================
echo.
echo If any tests failed, that may be why fix-android-path.bat crashes.
echo.
echo Recommended action:
echo   1. If Android SDK not found: Run install-android-sdk.bat
echo   2. If setx failed: Run as Administrator
echo   3. Use fix-path-simple.bat as alternative
echo.

pause
