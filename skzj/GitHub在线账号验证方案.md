# ?? 从 GitHub 在线验证账号方案

## ?? 方案说明

### 现有方式（嵌入式）
- ? zh.txt 打包在 APK 中
- ? 更新账号需要重新发布 APK
- ? 用户需要下载新版本

### 新方式（在线验证）
- ? zh.txt 存储在 GitHub
- ? APP 启动时从 GitHub 读取
- ? 更新账号只需修改 GitHub 文件
- ? 所有用户自动使用新账号
- ? 无需重新发布 APP

---

## ?? 实现步骤

### 步骤 1: 上传 zh.txt 到 GitHub

在 GitHub Desktop 中：

1. **确保 zh.txt 未被忽略**
   - 打开 `.gitignore`
   - 确认 `zh.txt` 行被注释掉：
     ```gitignore
     # zh.txt  ← 这样 zh.txt 会被提交
     ```

2. **提交并推送**
   - 在 GitHub Desktop 中会看到 `zh.txt` 变更
   - 输入提交信息："添加账号文件"
   - 点击 "Commit to main"
   - 点击 "Push origin"

3. **获取原始文件 URL**
   - 访问：https://github.com/Wen199512/skzj-booking-app
   - 找到并点击 `skzj/zh.txt`
   - 点击 "Raw" 按钮
   - 复制 URL，格式如下：
     ```
     https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt
     ```

---

## ?? 代码实现

### 方案 A: 完全在线（推荐）

APP 每次启动时从 GitHub 下载最新账号列表。

**优点**：
- ? 账号始终最新
- ? 更新账号无需发布新版本
- ? 管理员可以随时增删账号

**缺点**：
- ?? 需要网络连接

### 方案 B: 混合模式（推荐作为备选）

优先从 GitHub 下载，如果失败则使用内嵌的 zh.txt。

**优点**：
- ? 账号可在线更新
- ? 无网络时也能使用
- ? 最佳用户体验

---

## ?? 代码修改

### 1. 创建在线账号服务

文件：`skzj/Services/OnlineAccountService.cs`

```csharp
using System.Net.Http;
using System.Text;
using skzj.Models;

namespace skzj.Services;

/// <summary>
/// 在线账号服务 - 从 GitHub 读取账号文件
/// </summary>
public class OnlineAccountService
{
    // GitHub 原始文件 URL
    private const string GitHubRawUrl = "https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt";
    
    private readonly HttpClient _httpClient;
    private readonly BookingService _bookingService;

    public OnlineAccountService()
    {
        _httpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(10)
        };
        _bookingService = new BookingService();
    }

    /// <summary>
    /// 从 GitHub 加载账号列表
    /// </summary>
    public async Task<List<Account>> LoadAccountsFromGitHubAsync()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine($"从 GitHub 下载账号文件: {GitHubRawUrl}");
            
            // 下载文件内容
            var content = await _httpClient.GetStringAsync(GitHubRawUrl);
            
            if (string.IsNullOrWhiteSpace(content))
            {
                System.Diagnostics.Debug.WriteLine("GitHub 账号文件为空");
                return new List<Account>();
            }

            // 解析账号
            var accounts = ParseAccounts(content);
            System.Diagnostics.Debug.WriteLine($"从 GitHub 加载了 {accounts.Count} 个账号");
            
            return accounts;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"从 GitHub 加载账号失败: {ex.Message}");
            throw;
        }
    }

    /// <summary>
    /// 加载账号（混合模式：优先在线，失败则使用本地）
    /// </summary>
    public async Task<(List<Account> Accounts, bool FromGitHub)> LoadAccountsAsync()
    {
        // 1. 尝试从 GitHub 加载
        try
        {
            var accounts = await LoadAccountsFromGitHubAsync();
            if (accounts.Count > 0)
            {
                return (accounts, true);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"从 GitHub 加载失败，尝试使用本地文件: {ex.Message}");
        }

        // 2. 从本地嵌入式资源加载（备用）
        try
        {
            var filePath = await Helpers.EmbeddedResourceHelper.ExtractEmbeddedResourceAsync("zh.txt");
            var accounts = await _bookingService.LoadAccountsFromFileAsync(filePath);
            return (accounts, false);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"从本地加载也失败: {ex.Message}");
            return (new List<Account>(), false);
        }
    }

    /// <summary>
    /// 解析账号文件内容
    /// </summary>
    private List<Account> ParseAccounts(string content)
    {
        var accounts = new List<Account>();
        var lines = content.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line))
                continue;

            var parts = line.Trim().Split(new[] { ',', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 4)
            {
                // 格式: 姓名,验证码,账号ID,密码
                accounts.Add(new Account(parts[0], parts[1], parts[2], parts[3]));
            }
        }

        return accounts;
    }
}
```

---

### 2. 修改 LoginPage.xaml.cs

```csharp
using Microsoft.Maui.Controls;
using skzj.Models;
using skzj.Services;

namespace skzj;

public partial class LoginPage : ContentPage
{
    private readonly OnlineAccountService _onlineAccountService;
    private List<Account> _accounts = new();
    private bool _fromGitHub = false;

    public LoginPage()
    {
        InitializeComponent();
        _onlineAccountService = new OnlineAccountService();
        _ = LoadAccountsAsync();
    }

    private async Task LoadAccountsAsync()
    {
        try
        {
            lblAccountStatus.Text = "正在连接服务器...";
            lblAccountStatus.TextColor = Colors.Orange;
            lblAccountStatus.IsVisible = true;

            // 从 GitHub 或本地加载账号
            var result = await _onlineAccountService.LoadAccountsAsync();
            _accounts = result.Accounts;
            _fromGitHub = result.FromGitHub;
            
            if (_accounts.Count > 0)
            {
                if (_fromGitHub)
                {
                    lblAccountStatus.Text = $"已连接 (在线 {_accounts.Count} 个账号)";
                    lblAccountStatus.TextColor = Colors.Green;
                }
                else
                {
                    lblAccountStatus.Text = $"已连接 (离线 {_accounts.Count} 个账号)";
                    lblAccountStatus.TextColor = Colors.Orange;
                }
                lblAccountStatus.IsVisible = true;
            }
            else
            {
                lblAccountStatus.Text = "连接失败";
                lblAccountStatus.TextColor = Colors.Red;
                lblAccountStatus.IsVisible = true;
            }
        }
        catch (Exception ex)
        {
            lblAccountStatus.Text = "连接失败";
            lblAccountStatus.TextColor = Colors.Red;
            lblAccountStatus.IsVisible = true;
            
            System.Diagnostics.Debug.WriteLine($"加载账号失败: {ex.Message}");
        }
    }

    private async void OnLoginClicked(object? sender, EventArgs e)
    {
        var name = txtName.Text?.Trim();
        var code = txtCode.Text?.Trim();

        if (string.IsNullOrWhiteSpace(name))
        {
            ShowError("请输入姓名");
            return;
        }

        if (string.IsNullOrWhiteSpace(code))
        {
            ShowError("请输入验证码");
            return;
        }

        if (code.Length != 4 || !code.All(char.IsDigit))
        {
            ShowError("验证码必须是4位数字");
            return;
        }

        if (_accounts == null || _accounts.Count == 0)
        {
            ShowError("系统未连接，请稍后重试");
            return;
        }

        // 查找匹配的账号
        var account = _accounts.FirstOrDefault(a => 
            a.Name.Equals(name, StringComparison.OrdinalIgnoreCase));

        if (account == null)
        {
            ShowError("请联系管理员");
            return;
        }

        // 验证码验证
        if (!code.Equals(account.VerificationCode))
        {
            ShowError("验证码错误");
            return;
        }

        await NavigateToMainPage(account);
    }

    private void ShowError(string message)
    {
        lblError.Text = message;
        lblError.IsVisible = true;

        Dispatcher.StartTimer(TimeSpan.FromSeconds(3), () =>
        {
            MainThread.BeginInvokeOnMainThread(() =>
            {
                lblError.IsVisible = false;
            });
            return false;
        });
    }

    private async Task NavigateToMainPage(Account account)
    {
        try
        {
            loadingIndicator.IsVisible = true;
            loadingIndicator.IsRunning = true;
            btnLogin.IsEnabled = false;

            var mainPage = new MainPage(account);
            await Navigation.PushAsync(mainPage);

            txtName.Text = string.Empty;
            txtCode.Text = string.Empty;
        }
        catch (Exception ex)
        {
            await DisplayAlert("错误", $"跳转失败: {ex.Message}", "确定");
        }
        finally
        {
            loadingIndicator.IsVisible = false;
            loadingIndicator.IsRunning = false;
            btnLogin.IsEnabled = true;
        }
    }
}
```

---

## ?? Android 网络权限

确保 `skzj/Platforms/Android/AndroidManifest.xml` 包含网络权限：

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:allowBackup="true" android:icon="@mipmap/appicon" android:roundIcon="@mipmap/appicon_round" android:supportsRtl="true"></application>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

---

## ?? 更新账号流程

### 以后添加新账号：

1. **在本地修改 zh.txt**
   ```
   添加新行：
   新用户,1234,ABCD1234...,PASSWORD...
   ```

2. **在 GitHub Desktop 中**
   - 会自动检测到 zh.txt 变更
   - 输入提交信息："添加新账号"
   - 点击 "Commit to main"
   - 点击 "Push origin"

3. **完成！**
   - 所有用户下次打开 APP 时会自动获取新账号
   - 无需重新发布 APK

---

## ?? 使用场景

### 场景 1: 有网络连接
```
用户打开 APP
   ↓
从 GitHub 下载最新 zh.txt
   ↓
显示"已连接 (在线 X 个账号)"
   ↓
用户登录
```

### 场景 2: 无网络连接
```
用户打开 APP
   ↓
GitHub 下载失败
   ↓
使用内嵌的 zh.txt（备用）
   ↓
显示"已连接 (离线 X 个账号)"
   ↓
用户登录
```

---

## ?? 安全建议

### 方案 1: Private 仓库（推荐）

- ? 仓库设置为 Private
- ? zh.txt 只有您能看到
- ? 使用 GitHub Token 访问

修改 URL：
```csharp
// 使用 Personal Access Token
private const string GitHubRawUrl = "https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt";
// 在 HTTP 请求中添加 Token
_httpClient.DefaultRequestHeaders.Authorization = 
    new AuthenticationHeaderValue("Bearer", "ghp_your_token_here");
```

### 方案 2: Public 仓库 + 加密

如果必须使用 Public 仓库：

1. **加密 zh.txt**
2. **APP 下载后解密**
3. **使用 AES 或 RSA 加密**

---

## ?? 方案对比

| 特性 | 嵌入式 | 完全在线 | 混合模式 |
|------|--------|---------|---------|
| **更新便利** | ? 需要发布新版 | ? 随时更新 | ? 随时更新 |
| **离线可用** | ? 完全离线 | ? 需要网络 | ? 有备用 |
| **安全性** | ?? 可被提取 | ? 可加密传输 | ? 可加密 |
| **推荐度** | ?? | ???? | ????? |

**推荐：混合模式**

---

## ?? 常见问题

### Q1: GitHub 下载速度慢怎么办？

**解决**：
- 使用 CDN 加速
- 或使用国内 Git 托管（Gitee）

### Q2: 如何保护账号安全？

**解决**：
1. 使用 Private 仓库
2. 使用 Personal Access Token
3. 加密传输

### Q3: 如何测试在线加载？

**步骤**：
1. 在 GitHub 上修改 zh.txt
2. 卸载并重新安装 APP
3. 检查是否显示"在线 X 个账号"
4. 尝试新账号登录

---

## ?? 实施清单

- [ ] 创建 `OnlineAccountService.cs`
- [ ] 修改 `LoginPage.xaml.cs`
- [ ] 检查 `AndroidManifest.xml` 网络权限
- [ ] 修改 `.gitignore`（确保 zh.txt 被提交）
- [ ] 在 GitHub Desktop 提交 zh.txt
- [ ] 获取 GitHub Raw URL
- [ ] 更新代码中的 URL
- [ ] 构建并测试 APK
- [ ] 验证在线加载功能

---

## ?? 优势总结

### 对管理员：
- ? 随时添加/删除账号
- ? 只需修改 GitHub 文件
- ? 无需重新发布 APP
- ? 所有用户自动更新

### 对用户：
- ? 无需下载新版本
- ? 始终使用最新账号
- ? 无网络时仍可使用
- ? 体验流畅

---

**这个方案让账号管理变得非常简单！** ??

修改 GitHub 文件 → 所有用户自动更新 → 完成！
