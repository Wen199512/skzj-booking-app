# Android SDK 安装和配置指南

## 问题说明

错误 `XA5300` 表示找不到 Android SDK 目录。这是因为：
1. Android SDK 未安装
2. Android SDK 路径未正确配置
3. 环境变量未设置

---

## 解决方案

### 方案一：通过 Visual Studio 安装（推荐 - 最简单）

#### 步骤：

1. **打开 Visual Studio Installer**
   - 开始菜单搜索 "Visual Studio Installer"
   - 或从 Visual Studio 菜单：工具 → 获取工具和功能

2. **修改 Visual Studio 安装**
   - 点击 "修改"
   - 选择 "工作负载" 选项卡

3. **安装 .NET MAUI 工作负载**
   - 勾选 ".NET Multi-platform App UI 开发"
   - 这会自动安装 Android SDK、NDK 和其他必需组件

4. **确认安装组件**
   在右侧面板确认包含：
   - ? Android SDK 安装管理器
   - ? Android SDK 平台 API 级别（至少 API 33）
   - ? Android 模拟器
   - ? .NET MAUI SDK

5. **点击修改并等待安装完成**
   - 下载和安装可能需要 30 分钟到 1 小时
   - 需要约 10-15 GB 磁盘空间

6. **重启 Visual Studio**

---

### 方案二：通过命令行安装（快速）

```bash
# 安装 .NET MAUI 工作负载（包含 Android SDK）
dotnet workload install maui-android

# 或者只安装 Android 工作负载
dotnet workload install android
```

**注意**: 首次运行可能需要下载多个 GB 的数据

---

### 方案三：手动安装并配置 Android SDK

#### 1. 下载 Android SDK Command-line Tools

访问: https://developer.android.com/studio#command-tools

下载 "Command line tools only" for Windows

#### 2. 解压到固定位置

建议路径:
```
C:\Android\cmdline-tools\latest\
```

#### 3. 安装必需的 SDK 组件

```bash
# 打开 PowerShell，进入 cmdline-tools 目录
cd C:\Android\cmdline-tools\latest\bin

# 安装平台工具
.\sdkmanager.bat "platform-tools"

# 安装构建工具
.\sdkmanager.bat "build-tools;34.0.0"

# 安装平台 SDK（根据需要选择版本）
.\sdkmanager.bat "platforms;android-34"
.\sdkmanager.bat "platforms;android-33"

# 安装其他必需组件
.\sdkmanager.bat "ndk;26.1.10909125"
.\sdkmanager.bat "cmake;3.22.1"
```

#### 4. 设置环境变量

**方法 1: 系统环境变量（推荐）**

1. 右键 "此电脑" → "属性" → "高级系统设置"
2. 点击 "环境变量"
3. 在 "系统变量" 中，点击 "新建"：
   - 变量名: `ANDROID_HOME`
   - 变量值: `C:\Android`
4. 编辑 `Path` 变量，添加：
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\cmdline-tools\latest\bin`
5. 点击 "确定" 保存

**方法 2: 仅为当前用户设置**

在 PowerShell 中执行：
```powershell
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android", "User")
$path = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("Path", "$path;C:\Android\platform-tools;C:\Android\cmdline-tools\latest\bin", "User")
```

---

### 方案四：在项目中直接指定 SDK 路径

如果您已经有 Android SDK 但路径不正确，可以在项目中指定。

#### 方法 1: 通过环境变量（临时）

在 PowerShell 中运行发布前设置：
```powershell
$env:ANDROID_HOME = "C:\Android"
$env:ANDROID_SDK_ROOT = "C:\Android"

# 然后运行发布
dotnet publish -f net9.0-android -c Release
```

#### 方法 2: 修改项目文件

在 `skzj.csproj` 中添加：

```xml
<PropertyGroup>
  <!-- 指定 Android SDK 路径 -->
  <AndroidSdkDirectory>C:\Android</AndroidSdkDirectory>
</PropertyGroup>
```

#### 方法 3: 创建发布配置文件

创建 `Directory.Build.props` 文件（在解决方案根目录）：

```xml
<Project>
  <PropertyGroup>
    <AndroidSdkDirectory>C:\Android</AndroidSdkDirectory>
  </PropertyGroup>
</Project>
```

---

## 验证安装

### 检查 Android SDK 是否安装成功

```bash
# 检查 .NET 工作负载
dotnet workload list

# 应该看到类似输出：
# android         [Version]
# maui-android    [Version]

# 检查 Android SDK
adb version

# 应该显示 Android Debug Bridge version
```

### 检查环境变量

```powershell
# PowerShell
echo $env:ANDROID_HOME
echo $env:ANDROID_SDK_ROOT

# 应该输出 SDK 路径，如: C:\Android
```

### 测试构建

```bash
# 清理项目
dotnet clean

# 尝试构建
dotnet build -f net9.0-android
```

---

## 常见问题排查

### 问题 1: 工作负载安装失败

**解决方案**:
```bash
# 清理工作负载缓存
dotnet workload clean

# 更新 .NET SDK
dotnet --version

# 如果版本过旧，下载最新版本
# https://dotnet.microsoft.com/download
```

### 问题 2: SDK 安装后仍提示找不到

**解决方案**:
1. 重启 PowerShell/CMD
2. 重启 Visual Studio
3. 重启电脑（确保环境变量生效）

### 问题 3: 多个 Android SDK 路径冲突

**解决方案**:
```powershell
# 检查所有可能的 SDK 路径
echo $env:ANDROID_HOME
echo $env:ANDROID_SDK_ROOT
Get-ChildItem Env: | Where-Object { $_.Name -like "*ANDROID*" }

# 确保只设置一个正确的路径
```

### 问题 4: 权限不足

**解决方案**:
- 以管理员身份运行 PowerShell
- 确保 SDK 目录有读写权限

---

## 推荐配置

### 标准 Android SDK 目录结构

```
C:\Android\
├── cmdline-tools\
│   └── latest\
│       └── bin\
├── platform-tools\
├── platforms\
│   ├── android-33\
│   └── android-34\
├── build-tools\
│   └── 34.0.0\
└── ndk\
    └── 26.1.10909125\
```

### 所需的最小组件

对于基本的 .NET MAUI Android 开发：
- ? Platform Tools
- ? Build Tools 34.0.0+
- ? Android Platform SDK 33 或 34
- ? NDK (可选，但推荐)

---

## 快速开始脚本

创建 `setup-android-sdk.ps1`:

```powershell
# Android SDK 自动配置脚本
$ErrorActionPreference = "Stop"

Write-Host "检查 Android SDK..." -ForegroundColor Green

# 检查是否已安装
$androidHome = $env:ANDROID_HOME

if ($null -eq $androidHome -or -not (Test-Path $androidHome)) {
    Write-Host "Android SDK 未找到，开始安装..." -ForegroundColor Yellow
    
    # 安装 .NET MAUI 工作负载（包含 Android SDK）
    Write-Host "安装 .NET MAUI Android 工作负载..." -ForegroundColor Yellow
    dotnet workload install maui-android
    
    Write-Host "安装完成！" -ForegroundColor Green
} else {
    Write-Host "Android SDK 已安装: $androidHome" -ForegroundColor Green
}

# 验证
Write-Host "`n验证安装..." -ForegroundColor Green
dotnet workload list | Select-String "android"

Write-Host "`n完成！" -ForegroundColor Green
```

运行:
```powershell
.\setup-android-sdk.ps1
```

---

## 针对您的项目的建议

### 最快的解决方案（推荐）

1. **安装 Android 工作负载**:
   ```bash
   dotnet workload install android
   ```

2. **等待安装完成**（可能需要 10-30 分钟）

3. **重新运行发布**:
   ```bash
   cd F:\vscx\skzj\skzj
   dotnet publish -f net9.0-android -c Release
   ```

### 如果只想发布 Windows 版本

如果暂时不需要 Android 版本，可以只构建 Windows：

```bash
dotnet publish -f net9.0-windows10.0.19041.0 -c Release
```

或修改 `skzj.csproj`，暂时移除 Android 目标：

```xml
<PropertyGroup>
  <!-- 只针对 Windows -->
  <TargetFrameworks>net9.0-windows10.0.19041.0</TargetFrameworks>
</PropertyGroup>
```

---

## 总结

**最推荐的解决方案**（按优先级）：

1. ? **方案二（命令行）** - 最快速
   ```bash
   dotnet workload install android
   ```

2. ? **方案一（Visual Studio）** - 最完整
   - 通过 Visual Studio Installer 安装 .NET MAUI 工作负载

3. ?? **方案四（暂时跳过 Android）** - 如果只需要 Windows
   - 修改项目只针对 Windows 平台

选择适合您的方案，如有问题请告诉我！
