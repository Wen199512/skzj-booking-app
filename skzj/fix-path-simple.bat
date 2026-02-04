@echo off
setlocal

echo ==========================================
echo   Simple Android SDK Path Fix
echo ==========================================
echo.

REM Navigate to script directory
cd /d "%~dp0"

echo Step 1: Checking for Android SDK...
echo.

REM Try to find SDK in .NET packs
set "SDK_PATH="
set "BASE_PATH=%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows"

if exist "%BASE_PATH%" (
    echo Found Microsoft.Android.Sdk.Windows directory
    echo.
    echo Versions found:
    dir /b /ad "%BASE_PATH%" 2>nul
    echo.
    
    REM Get the first (latest when sorted) version
    for /f "delims=" %%V in ('dir /b /ad "%BASE_PATH%" 2^>nul ^| sort /r') do (
        if exist "%BASE_PATH%\%%V\tools" (
            set "SDK_PATH=%BASE_PATH%\%%V\tools"
            echo Selected: %%V
            echo Full path: !SDK_PATH!
            goto :found
        )
    )
) else (
    echo [ERROR] Microsoft.Android.Sdk.Windows not found
    echo.
    echo Please install Android workload:
    echo   dotnet workload install android
    echo.
    goto :error
)

:found
echo.
echo ==========================================
echo.

if defined SDK_PATH (
    echo Android SDK found at:
    echo %SDK_PATH%
    echo.
    echo Do you want to set ANDROID_HOME? (Y/N)
    set /p CONFIRM=
    
    if /i "%CONFIRM%"=="Y" (
        echo.
        echo Setting ANDROID_HOME...
        setx ANDROID_HOME "%SDK_PATH%"
        
        echo.
        echo [OK] ANDROID_HOME has been set
        echo.
        echo IMPORTANT: Please restart your terminal!
        echo.
        goto :success
    ) else (
        echo Operation cancelled
        goto :end
    )
) else (
    echo [ERROR] Could not locate Android SDK
    goto :error
)

:success
echo ==========================================
echo   Success!
echo ==========================================
echo.
echo ANDROID_HOME is now: %SDK_PATH%
echo.
echo Next steps:
echo   1. Close this window
echo   2. Open a new terminal
echo   3. Run: publish-quick.bat
echo.
goto :end

:error
echo ==========================================
echo   Error
echo ==========================================
echo.
echo Could not automatically configure Android SDK
echo.
echo Manual steps:
echo   1. Run: dotnet workload install android
echo   2. Run this script again
echo.
goto :end

:end
echo Press any key to exit...
pause >nul
