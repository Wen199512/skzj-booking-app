@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   Android SDK Path Finder and Fixer
echo ==========================================
echo.

echo Checking Android workload installation...
dotnet workload list 2>nul | findstr "android"
if errorlevel 1 (
    echo [WARNING] Android workload may not be installed
    echo Run 'install-android-sdk.bat' first
    echo.
) else (
    echo [OK] Android workload is installed
    echo.
)

echo Searching for Android SDK locations...
echo Please wait...
echo.

REM Common Android SDK locations
set "SDK_FOUND=0"
set "ANDROID_SDK_PATH="

echo Checking possible SDK locations:
echo.

REM Location 1: .NET MAUI workload location (most common)
echo [1] Checking .NET SDK packs...
set "DOTNET_PACKS=%ProgramFiles%\dotnet\packs\Microsoft.Android.Sdk.Windows"

if exist "%DOTNET_PACKS%" (
    echo    Found: %DOTNET_PACKS%
    
    REM Find the latest version
    for /f "delims=" %%D in ('dir /b /ad "%DOTNET_PACKS%" 2^>nul ^| sort /r') do (
        if exist "%DOTNET_PACKS%\%%D\tools" (
            set "ANDROID_SDK_PATH=%DOTNET_PACKS%\%%D\tools"
            set "SDK_FOUND=1"
            echo    [OK] SDK found at: !ANDROID_SDK_PATH!
            goto :sdk_found
        )
    )
) else (
    echo    [Not Found]
)

REM Location 2: User profile AppData
echo [2] Checking user AppData...
set "USER_SDK=%LOCALAPPDATA%\Android\Sdk"
if exist "%USER_SDK%" (
    set "ANDROID_SDK_PATH=%USER_SDK%"
    set "SDK_FOUND=1"
    echo    [OK] SDK found at: %USER_SDK%
    goto :sdk_found
) else (
    echo    [Not Found]
)

REM Location 3: Program Files
echo [3] Checking Program Files...
set "PROGRAM_SDK=%ProgramFiles(x86)%\Android\android-sdk"
if exist "%PROGRAM_SDK%" (
    set "ANDROID_SDK_PATH=%PROGRAM_SDK%"
    set "SDK_FOUND=1"
    echo    [OK] SDK found at: %PROGRAM_SDK%
    goto :sdk_found
) else (
    echo    [Not Found]
)

:sdk_found

REM Location 4: Check current ANDROID_HOME
echo.
echo [4] Checking current ANDROID_HOME...
if defined ANDROID_HOME (
    echo    Current value: %ANDROID_HOME%
    if exist "%ANDROID_HOME%" (
        echo    [OK] Path exists
    ) else (
        echo    [ERROR] Path does NOT exist!
    )
) else (
    echo    [Not Set]
)

echo.
echo ==========================================
echo   Results
echo ==========================================
echo.

if "%SDK_FOUND%"=="1" (
    echo Android SDK found at:
    echo %ANDROID_SDK_PATH%
    echo.
    
    echo Do you want to set ANDROID_HOME to this path?
    echo Type Y and press Enter to continue, or N to cancel:
    set /p CHOICE=
    
    if /i "!CHOICE!"=="Y" (
        echo.
        echo Setting ANDROID_HOME environment variable...
        echo.
        
        REM Set for current session
        set "ANDROID_HOME=!ANDROID_SDK_PATH!"
        
        REM Set permanently for user
        setx ANDROID_HOME "!ANDROID_SDK_PATH!" >nul 2>&1
        
        if errorlevel 1 (
            echo [ERROR] Failed to set environment variable
            echo You may need to run as Administrator
        ) else (
            echo [OK] ANDROID_HOME set to:
            echo !ANDROID_SDK_PATH!
            echo.
            echo IMPORTANT: You must restart your terminal for changes to take effect!
        )
        
        echo.
        echo Creating/Updating Directory.Build.props...
        
        REM Navigate to script directory
        cd /d "%~dp0"
        
        if exist "Directory.Build.props" (
            echo [INFO] Directory.Build.props already exists
            echo You may need to manually verify AndroidSdkDirectory property
        ) else (
            (
                echo ^<Project^>
                echo   ^<PropertyGroup^>
                echo     ^<!-- Android SDK Directory --^>
                echo     ^<AndroidSdkDirectory^>!ANDROID_SDK_PATH!^</AndroidSdkDirectory^>
                echo   ^</PropertyGroup^>
                echo ^</Project^>
            ) > Directory.Build.props
            
            echo [OK] Created Directory.Build.props
        )
        
        echo.
        echo ==========================================
        echo   Configuration Complete
        echo ==========================================
        echo.
        echo Next steps:
        echo   1. CLOSE this terminal window
        echo   2. Open a NEW terminal
        echo   3. Run: publish-quick.bat
        echo.
    ) else (
        echo.
        echo [INFO] Operation cancelled by user
        echo.
    )
) else (
    echo [ERROR] Could not find Android SDK automatically
    echo.
    echo Possible solutions:
    echo.
    echo 1. Install Android workload:
    echo    dotnet workload install android
    echo.
    echo 2. Repair existing workload:
    echo    dotnet workload repair
    echo.
    echo 3. Install Android SDK manually from:
    echo    https://developer.android.com/studio
    echo.
    echo 4. If you know the SDK path, set it manually:
    echo    setx ANDROID_HOME "path\to\android\sdk"
    echo.
)

echo ==========================================
echo   Current Environment Status
echo ==========================================
echo.

if defined ANDROID_HOME (
    echo ANDROID_HOME: %ANDROID_HOME%
    
    if exist "%ANDROID_HOME%" (
        echo Status: [OK] Set and exists
    ) else (
        echo Status: [ERROR] Set but path does not exist
    )
) else (
    echo ANDROID_HOME: [Not Set]
    echo.
    echo To manually set:
    echo   setx ANDROID_HOME "path\to\sdk"
    echo.
    echo Or use Directory.Build.props (see documentation)
)

echo.
echo Press any key to exit...
pause >nul
exit /b 0
