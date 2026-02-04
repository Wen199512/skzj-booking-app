# Android APK 发布脚本
# 使用方法: .\publish-android.ps1

param(
    [string]$Configuration = "Release",
    [string]$Architecture = "android-arm64",
    [string]$OutputPath = "F:\vscx\skzj\Release"
)

$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# 项目路径
$projectPath = "F:\vscx\skzj\skzj\skzj.csproj"
$projectDir = "F:\vscx\skzj\skzj"

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "  首矿之家活动预约系统 - Android 发布" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# 检查项目文件
if (-not (Test-Path $projectPath)) {
    Write-ColorOutput "错误: 项目文件不存在 $projectPath" "Red"
    exit 1
}

# 显示配置
Write-ColorOutput "发布配置:" "Yellow"
Write-Host "  项目: $projectPath"
Write-Host "  配置: $Configuration"
Write-Host "  架构: $Architecture"
Write-Host "  输出: $OutputPath"
Write-Host ""

# 创建输出目录
if (-not (Test-Path $OutputPath)) {
    Write-ColorOutput "创建输出目录: $OutputPath" "Yellow"
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# 步骤 1: 清理项目
Write-ColorOutput "步骤 1/4: 清理项目..." "Green"
try {
    Set-Location $projectDir
    dotnet clean -c $Configuration -v quiet
    Write-ColorOutput "  ? 清理完成" "Green"
} catch {
    Write-ColorOutput "  ? 清理失败: $_" "Red"
    exit 1
}

Write-Host ""

# 步骤 2: 恢复依赖
Write-ColorOutput "步骤 2/4: 恢复 NuGet 包..." "Green"
try {
    dotnet restore -v quiet
    Write-ColorOutput "  ? 恢复完成" "Green"
} catch {
    Write-ColorOutput "  ? 恢复失败: $_" "Red"
    exit 1
}

Write-Host ""

# 步骤 3: 发布应用
Write-ColorOutput "步骤 3/4: 发布 Android APK..." "Green"
Write-ColorOutput "  这可能需要几分钟时间，请耐心等待..." "Yellow"

try {
    $publishArgs = @(
        "publish"
        $projectPath
        "-f", "net9.0-android"
        "-c", $Configuration
        "-p:RuntimeIdentifier=$Architecture"
        "-p:AndroidPackageFormat=apk"
        "-v", "minimal"
    )
    
    & dotnet $publishArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "发布命令返回错误代码: $LASTEXITCODE"
    }
    
    Write-ColorOutput "  ? 发布完成" "Green"
} catch {
    Write-ColorOutput "  ? 发布失败: $_" "Red"
    exit 1
}

Write-Host ""

# 步骤 4: 复制文件到输出目录
Write-ColorOutput "步骤 4/4: 复制 APK 到输出目录..." "Green"

try {
    $publishDir = Join-Path $projectDir "bin\$Configuration\net9.0-android\$Architecture\publish"
    
    if (-not (Test-Path $publishDir)) {
        throw "发布目录不存在: $publishDir"
    }
    
    # 查找 APK 文件
    $apkFiles = Get-ChildItem -Path $publishDir -Filter "*.apk" -File
    
    if ($apkFiles.Count -eq 0) {
        throw "未找到 APK 文件"
    }
    
    # 复制所有 APK 文件
    foreach ($apk in $apkFiles) {
        $destFile = Join-Path $OutputPath $apk.Name
        Copy-Item $apk.FullName -Destination $destFile -Force
        Write-ColorOutput "  ? 已复制: $($apk.Name)" "Green"
    }
    
} catch {
    Write-ColorOutput "  ? 复制失败: $_" "Red"
    exit 1
}

Write-Host ""
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "  发布成功！" "Green"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# 显示输出文件信息
Write-ColorOutput "输出文件:" "Yellow"
Get-ChildItem $OutputPath -Filter *.apk | ForEach-Object {
    $sizeInMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  ?? $($_.Name)"
    Write-Host "     大小: $sizeInMB MB"
    Write-Host "     路径: $($_.FullName)"
    Write-Host ""
}

# 询问是否打开输出目录
Write-ColorOutput "是否打开输出目录? (Y/N)" "Yellow"
$response = Read-Host
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process explorer.exe $OutputPath
}

Write-ColorOutput "提示: 您可以将 APK 文件传输到 Android 设备并安装" "Cyan"
Write-Host ""
