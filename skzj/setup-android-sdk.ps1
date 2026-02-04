# Android SDK 自动安装和配置脚本
# 使用管理员权限运行此脚本

param(
    [switch]$SkipInstall = $false
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "  Android SDK 自动配置工具" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# 检查管理员权限
if (-not (Test-Administrator)) {
    Write-ColorOutput "警告: 建议以管理员身份运行此脚本" "Yellow"
    Write-ColorOutput "某些操作可能需要管理员权限" "Yellow"
    Write-Host ""
}

# 步骤 1: 检查当前状态
Write-ColorOutput "步骤 1/4: 检查当前配置..." "Green"

$androidHome = $env:ANDROID_HOME
$androidSdkRoot = $env:ANDROID_SDK_ROOT

Write-Host "  ANDROID_HOME: $androidHome"
Write-Host "  ANDROID_SDK_ROOT: $androidSdkRoot"

# 检查常见 SDK 位置
$commonPaths = @(
    "C:\Android",
    "C:\Program Files (x86)\Android\android-sdk",
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk"
)

$foundSdk = $false
foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-ColorOutput "  找到 Android SDK: $path" "Green"
        $foundSdk = $true
        $androidHome = $path
        break
    }
}

Write-Host ""

# 步骤 2: 检查 .NET 工作负载
Write-ColorOutput "步骤 2/4: 检查 .NET 工作负载..." "Green"

try {
    $workloads = dotnet workload list 2>&1 | Out-String
    
    if ($workloads -match "android") {
        Write-ColorOutput "  ? Android 工作负载已安装" "Green"
        $androidWorkloadInstalled = $true
    } else {
        Write-ColorOutput "  ? Android 工作负载未安装" "Yellow"
        $androidWorkloadInstalled = $false
    }
    
    if ($workloads -match "maui-android") {
        Write-ColorOutput "  ? MAUI Android 工作负载已安装" "Green"
    } else {
        Write-ColorOutput "  ? MAUI Android 工作负载未安装" "Yellow"
    }
} catch {
    Write-ColorOutput "  ? 无法检查工作负载: $_" "Red"
    $androidWorkloadInstalled = $false
}

Write-Host ""

# 步骤 3: 安装或配置
if (-not $SkipInstall -and -not $androidWorkloadInstalled) {
    Write-ColorOutput "步骤 3/4: 安装 Android 工作负载..." "Green"
    Write-ColorOutput "  这可能需要 10-30 分钟，请耐心等待..." "Yellow"
    Write-Host ""
    
    try {
        # 先更新工作负载
        Write-Host "  更新工作负载..."
        dotnet workload update
        
        # 安装 Android 工作负载
        Write-Host "  安装 Android 工作负载..."
        dotnet workload install android
        
        Write-ColorOutput "  ? 安装完成" "Green"
        $androidWorkloadInstalled = $true
    } catch {
        Write-ColorOutput "  ? 安装失败: $_" "Red"
        Write-ColorOutput "  请尝试手动运行: dotnet workload install android" "Yellow"
    }
} elseif ($androidWorkloadInstalled) {
    Write-ColorOutput "步骤 3/4: 跳过安装（已安装）" "Green"
} else {
    Write-ColorOutput "步骤 3/4: 跳过安装（使用 -SkipInstall 参数）" "Yellow"
}

Write-Host ""

# 步骤 4: 配置环境变量
Write-ColorOutput "步骤 4/4: 配置环境变量..." "Green"

if ($foundSdk -or $androidWorkloadInstalled) {
    # 尝试找到 SDK 路径
    if (-not $foundSdk) {
        # 检查工作负载安装的 SDK 路径
        $dotnetSdkPath = "$env:USERPROFILE\.dotnet\sdk"
        if (Test-Path $dotnetSdkPath) {
            # .NET 工作负载通常安装在用户目录
            $possiblePath = "$env:LOCALAPPDATA\Android\Sdk"
            if (Test-Path $possiblePath) {
                $androidHome = $possiblePath
                $foundSdk = $true
            }
        }
    }
    
    if ($foundSdk) {
        Write-Host "  设置 ANDROID_HOME: $androidHome"
        
        # 设置用户环境变量
        [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidHome, "User")
        [System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidHome, "User")
        
        # 设置当前会话环境变量
        $env:ANDROID_HOME = $androidHome
        $env:ANDROID_SDK_ROOT = $androidHome
        
        # 更新 PATH
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $platformTools = Join-Path $androidHome "platform-tools"
        
        if ($currentPath -notlike "*$platformTools*") {
            Write-Host "  添加 platform-tools 到 PATH"
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$platformTools", "User")
            $env:Path += ";$platformTools"
        }
        
        Write-ColorOutput "  ? 环境变量已配置" "Green"
    } else {
        Write-ColorOutput "  ? 未找到 SDK 路径，请手动设置 ANDROID_HOME" "Yellow"
    }
} else {
    Write-ColorOutput "  ? 跳过环境变量配置" "Yellow"
}

Write-Host ""

# 验证配置
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "  验证配置" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

Write-Host "环境变量:"
Write-Host "  ANDROID_HOME: $env:ANDROID_HOME"
Write-Host "  ANDROID_SDK_ROOT: $env:ANDROID_SDK_ROOT"
Write-Host ""

Write-Host ".NET 工作负载:"
try {
    dotnet workload list | Select-String "android"
} catch {
    Write-ColorOutput "  无法列出工作负载" "Red"
}

Write-Host ""

# 测试 ADB
if ($env:ANDROID_HOME) {
    $adbPath = Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"
    if (Test-Path $adbPath) {
        Write-Host "ADB 版本:"
        & $adbPath version
    }
}

Write-Host ""

# 提供建议
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "  后续步骤" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

if ($androidWorkloadInstalled) {
    Write-ColorOutput "? Android 工作负载已安装" "Green"
    Write-Host ""
    Write-Host "您现在可以:"
    Write-Host "  1. 重启 PowerShell 或 Visual Studio"
    Write-Host "  2. 运行发布命令:"
    Write-Host "     cd F:\vscx\skzj\skzj"
    Write-Host "     dotnet publish -f net9.0-android -c Release"
    Write-Host ""
    Write-Host "  或者直接运行快速发布脚本:"
    Write-Host "     .\快速发布.bat"
} else {
    Write-ColorOutput "? Android 工作负载未安装" "Yellow"
    Write-Host ""
    Write-Host "请手动运行以下命令安装:"
    Write-ColorOutput "  dotnet workload install android" "Cyan"
    Write-Host ""
    Write-Host "或者安装完整的 MAUI 工作负载:"
    Write-ColorOutput "  dotnet workload install maui-android" "Cyan"
}

Write-Host ""
Write-ColorOutput "提示: 配置完成后，请重启 PowerShell 以使环境变量生效" "Yellow"
Write-Host ""
