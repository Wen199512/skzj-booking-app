@echo off
setlocal

echo ==========================================
echo   Clean Build and Publish APK
echo ==========================================
echo.

cd /d "%~dp0"

echo [1/5] Cleaning project...
dotnet clean -c Release

echo.
echo [2/5] Deleting bin and obj folders...
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"

echo.
echo [3/5] Restoring packages...
dotnet restore -f net9.0-android

echo.
echo [4/5] Building Android Release...
dotnet build -f net9.0-android -c Release

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [5/5] Publishing APK...
dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64 -p:AndroidPackageFormat=apk

if errorlevel 1 (
    echo.
    echo [ERROR] Publish failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   Success!
echo ==========================================
echo.
echo APK Location:
echo bin\Release\net9.0-android\android-arm64\publish\com.skzj.booking-Signed.apk
echo.
echo Opening folder...
start "" explorer "bin\Release\net9.0-android\android-arm64\publish\"

echo.
pause
