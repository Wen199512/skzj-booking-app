# ?? 通过 GitHub 进行 APP 更新和发布指南

## ?? 目录

1. [GitHub 仓库设置](#github-仓库设置)
2. [版本管理](#版本管理)
3. [自动构建和发布](#自动构建和发布)
4. [应用内更新检测](#应用内更新检测)
5. [发布流程](#发布流程)

---

## ?? GitHub 仓库设置

### 步骤 1: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 创建新仓库：
   - 仓库名：`skzj-booking-app`
   - 描述：`首矿之家活动预约系统`
   - 可见性：`Private`（推荐）或 `Public`
3. 点击 "Create repository"

### 步骤 2: 初始化本地 Git 仓库

```bash
cd C:\Users\14564\source\repos\skzj

# 初始化 Git 仓库
git init

# 创建 .gitignore
echo "bin/" > .gitignore
echo "obj/" >> .gitignore
echo "*.user" >> .gitignore
echo "*.apk" >> .gitignore
echo ".vs/" >> .gitignore

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: 首矿之家活动预约系统"

# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/YOUR_USERNAME/skzj-booking-app.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

---

## ?? 版本管理

### 版本号规则

使用语义化版本：`主版本.次版本.修订版本`

- **主版本**：重大功能变更
- **次版本**：新功能添加
- **修订版本**：Bug 修复

### 更新版本号

编辑 `skzj/skzj.csproj`：

```xml
<PropertyGroup>
    <!-- 版本号 -->
    <ApplicationDisplayVersion>1.0.0</ApplicationDisplayVersion>
    <ApplicationVersion>1</ApplicationVersion>
</PropertyGroup>
```

**说明**：
- `ApplicationDisplayVersion`: 显示给用户的版本号（如 1.0.0）
- `ApplicationVersion`: 内部版本号（整数，每次递增）

---

## ?? 自动构建和发布

### 方法 1: GitHub Actions（推荐）

创建 `.github/workflows/build-and-release.yml`：

```yaml
name: Build and Release Android APK

on:
  push:
    tags:
      - 'v*.*.*'  # 当推送版本标签时触发，如 v1.0.0

jobs:
  build:
    runs-on: windows-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '9.0.x'
    
    - name: Install .NET MAUI workload
      run: dotnet workload install maui
    
    - name: Restore dependencies
      run: dotnet restore skzj/skzj.csproj
    
    - name: Build Android APK
      run: |
        cd skzj
        dotnet publish -f net9.0-android -c Release -p:AndroidPackageFormat=apk -p:RuntimeIdentifier=android-arm64
    
    - name: Find APK file
      id: find-apk
      shell: pwsh
      run: |
        $apk = Get-ChildItem -Path "skzj/bin/Release/net9.0-android/android-arm64/publish/*.apk" -Recurse | Select-Object -First 1
        echo "APK_PATH=$($apk.FullName)" >> $env:GITHUB_OUTPUT
        echo "APK_NAME=$($apk.Name)" >> $env:GITHUB_OUTPUT
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: ${{ steps.find-apk.outputs.APK_PATH }}
        name: Release ${{ github.ref_name }}
        body: |
          ## 首矿之家活动预约系统 ${{ github.ref_name }}
          
          ### 更新内容
          - 请在此添加更新说明
          
          ### 下载
          - [下载 APK](${{ steps.find-apk.outputs.APK_NAME }})
          
          ### 安装说明
          1. 下载 APK 文件
          2. 在 Android 设备上安装
          3. 允许安装未知来源应用
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 使用 GitHub Actions 发布

```bash
# 1. 更新版本号（在 skzj.csproj 中）
# 2. 提交更改
git add .
git commit -m "Bump version to 1.0.1"

# 3. 创建版本标签
git tag -a v1.0.1 -m "Release version 1.0.1"

# 4. 推送代码和标签
git push origin main
git push origin v1.0.1

# GitHub Actions 将自动构建并创建 Release
```

---

### 方法 2: 手动发布到 GitHub Releases

#### 步骤 1: 构建 APK

```cmd
cd C:\Users\14564\source\repos\skzj\skzj
clean-build-publish.bat
```

#### 步骤 2: 创建 Release

1. 访问您的 GitHub 仓库
2. 点击 "Releases" → "Create a new release"
3. 填写信息：
   - **Tag**: `v1.0.0`
   - **Title**: `首矿之家活动预约系统 v1.0.0`
   - **Description**: 更新说明
4. 上传 APK 文件：
   - 拖拽 `com.skzj.booking-Signed.apk` 到附件区域
5. 点击 "Publish release"

---

## ?? 应用内更新检测

### 创建版本检测服务

创建 `skzj/Services/UpdateService.cs`：

```csharp
using System.Net.Http.Json;

namespace skzj.Services;

public class UpdateService
{
    private const string GitHubApiUrl = "https://api.github.com/repos/YOUR_USERNAME/skzj-booking-app/releases/latest";
    private readonly HttpClient _httpClient;

    public UpdateService()
    {
        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("SKZJ-Booking-App");
    }

    public async Task<UpdateInfo?> CheckForUpdatesAsync()
    {
        try
        {
            var response = await _httpClient.GetFromJsonAsync<GitHubRelease>(GitHubApiUrl);
            if (response == null) return null;

            var latestVersion = response.TagName?.TrimStart('v');
            var currentVersion = AppInfo.Current.VersionString;

            if (IsNewerVersion(latestVersion, currentVersion))
            {
                return new UpdateInfo
                {
                    LatestVersion = latestVersion,
                    CurrentVersion = currentVersion,
                    DownloadUrl = response.Assets?.FirstOrDefault()?.BrowserDownloadUrl,
                    ReleaseNotes = response.Body,
                    PublishedAt = response.PublishedAt
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"检查更新失败: {ex.Message}");
            return null;
        }
    }

    private bool IsNewerVersion(string? latest, string? current)
    {
        if (string.IsNullOrWhiteSpace(latest) || string.IsNullOrWhiteSpace(current))
            return false;

        var latestParts = latest.Split('.').Select(int.Parse).ToArray();
        var currentParts = current.Split('.').Select(int.Parse).ToArray();

        for (int i = 0; i < Math.Min(latestParts.Length, currentParts.Length); i++)
        {
            if (latestParts[i] > currentParts[i]) return true;
            if (latestParts[i] < currentParts[i]) return false;
        }

        return latestParts.Length > currentParts.Length;
    }
}

public class UpdateInfo
{
    public string? LatestVersion { get; set; }
    public string? CurrentVersion { get; set; }
    public string? DownloadUrl { get; set; }
    public string? ReleaseNotes { get; set; }
    public DateTime? PublishedAt { get; set; }
}

public class GitHubRelease
{
    public string? TagName { get; set; }
    public string? Name { get; set; }
    public string? Body { get; set; }
    public DateTime? PublishedAt { get; set; }
    public List<GitHubAsset>? Assets { get; set; }
}

public class GitHubAsset
{
    public string? Name { get; set; }
    public string? BrowserDownloadUrl { get; set; }
}
```

### 在登录页面添加更新检测

修改 `LoginPage.xaml.cs`：

```csharp
public partial class LoginPage : ContentPage
{
    private readonly BookingService _bookingService;
    private readonly UpdateService _updateService;
    private List<Account> _accounts = new();

    public LoginPage()
    {
        InitializeComponent();
        _bookingService = new BookingService();
        _updateService = new UpdateService();
        
        _ = LoadAccountsAsync();
        _ = CheckForUpdatesAsync();
    }

    private async Task CheckForUpdatesAsync()
    {
        try
        {
            var updateInfo = await _updateService.CheckForUpdatesAsync();
            if (updateInfo != null)
            {
                var result = await DisplayAlert(
                    "发现新版本",
                    $"当前版本: {updateInfo.CurrentVersion}\n" +
                    $"最新版本: {updateInfo.LatestVersion}\n\n" +
                    $"更新内容:\n{updateInfo.ReleaseNotes}\n\n" +
                    $"是否立即更新？",
                    "更新",
                    "稍后");

                if (result && !string.IsNullOrWhiteSpace(updateInfo.DownloadUrl))
                {
                    await Launcher.OpenAsync(new Uri(updateInfo.DownloadUrl));
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"检查更新失败: {ex.Message}");
        }
    }

    // ...existing code...
}
```

---

## ?? 完整发布流程

### 发布新版本的步骤

#### 1. 开发和测试

```bash
# 在本地开发和测试新功能
# 确保应用正常运行
```

#### 2. 更新版本号

编辑 `skzj/skzj.csproj`：

```xml
<!-- 从 1.0.0 更新到 1.0.1 -->
<ApplicationDisplayVersion>1.0.1</ApplicationDisplayVersion>
<ApplicationVersion>2</ApplicationVersion>
```

#### 3. 提交代码

```bash
git add .
git commit -m "Release v1.0.1: 添加验证码登录功能"
```

#### 4. 创建版本标签

```bash
git tag -a v1.0.1 -m "Release version 1.0.1

更新内容:
- ? 添加验证码登录
- ? 优化多线程性能
- ? 修复已知 Bug
"
```

#### 5. 推送到 GitHub

```bash
git push origin main
git push origin v1.0.1
```

#### 6. 自动构建（如果配置了 GitHub Actions）

GitHub Actions 会自动：
- 构建 APK
- 创建 Release
- 上传 APK

#### 7. 手动发布（如果没有 GitHub Actions）

```cmd
# 构建 APK
cd C:\Users\14564\source\repos\skzj\skzj
clean-build-publish.bat

# 然后在 GitHub 网站上手动创建 Release 并上传 APK
```

---

## ?? 用户更新流程

### 自动更新（推荐）

1. 用户打开 APP
2. APP 自动检测新版本
3. 显示更新提示
4. 用户点击"更新"
5. 跳转到下载页面
6. 下载并安装新版本

### 手动更新

1. 访问 GitHub Release 页面
2. 下载最新 APK
3. 在手机上安装

---

## ?? 安全建议

### 1. 保护敏感文件

创建 `.gitignore`：

```gitignore
# 构建输出
bin/
obj/
*.apk
*.aab

# 用户特定文件
*.user
*.suo
.vs/

# 敏感文件（不要提交到 GitHub）
zh.txt
*.pfx
*.keystore

# 临时文件
*.log
*.tmp
```

### 2. 使用私有仓库

如果应用包含敏感信息，建议使用 Private 仓库。

### 3. 环境变量

对于敏感配置，使用 GitHub Secrets：

```yaml
# .github/workflows/build-and-release.yml
env:
  SECRET_KEY: ${{ secrets.SECRET_KEY }}
```

---

## ?? 版本管理最佳实践

### 分支策略

```
main (主分支，生产版本)
  ├─ develop (开发分支)
  │   ├─ feature/验证码登录
  │   ├─ feature/多线程优化
  │   └─ bugfix/修复登录问题
  └─ hotfix/紧急修复
```

### 提交信息规范

```bash
# 功能
git commit -m "feat: 添加验证码登录功能"

# 修复
git commit -m "fix: 修复验证码验证错误"

# 优化
git commit -m "perf: 优化多线程性能"

# 文档
git commit -m "docs: 更新 README"

# 发布
git commit -m "release: v1.0.1"
```

---

## ?? 快速参考命令

### 发布新版本

```bash
# 1. 更新版本号
# 编辑 skzj/skzj.csproj

# 2. 提交
git add .
git commit -m "release: v1.0.1"

# 3. 标签
git tag -a v1.0.1 -m "Release v1.0.1"

# 4. 推送
git push origin main --tags
```

### 查看版本历史

```bash
# 查看所有标签
git tag

# 查看特定版本
git show v1.0.0

# 查看提交历史
git log --oneline --graph --all
```

### 回滚版本

```bash
# 回滚到之前的版本
git checkout v1.0.0

# 创建新分支
git checkout -b rollback-to-1.0.0
```

---

## ?? Release 模板

创建 `.github/RELEASE_TEMPLATE.md`：

```markdown
## 首矿之家活动预约系统 vX.X.X

### ? 新功能
- [ ] 功能1
- [ ] 功能2

### ?? Bug 修复
- [ ] 修复1
- [ ] 修复2

### ?? 性能优化
- [ ] 优化1
- [ ] 优化2

### ?? 下载
- [下载 APK](链接)

### ?? 系统要求
- Android 5.0 (API 21) 或更高版本
- ARM64 架构

### ?? 技术支持
- 如有问题，请联系管理员
```

---

## ?? 总结

### 推荐方案：GitHub Actions + 自动更新

1. ? **GitHub Actions** - 自动构建和发布
2. ? **GitHub Releases** - 版本管理
3. ? **应用内更新检测** - 自动提醒用户更新
4. ? **语义化版本** - 清晰的版本管理

### 优势

- ?? **自动化** - 推送标签即可自动发布
- ?? **版本管理** - 清晰的版本历史
- ?? **便捷更新** - 用户一键更新
- ?? **安全可靠** - GitHub 托管

---

**现在您可以开始使用 GitHub 管理应用更新和发布了！** ??
