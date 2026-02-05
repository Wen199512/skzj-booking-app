using Microsoft.Maui.Controls;
using skzj.Models;
using skzj.Services;
using skzj.Helpers;
using System.Reflection;

namespace skzj;

public partial class LoginPage : ContentPage
{
    private readonly BookingService _bookingService;
    private readonly UpdateService _updateService;
    private List<Account> _accounts = new();
    
    // 保存姓名的 Key
    private const string LastLoginNameKey = "LastLoginName";

    public LoginPage()
    {
        InitializeComponent();
        _bookingService = new BookingService();
        _updateService = new UpdateService();
        
        _ = LoadAccountsAsync();
        
        // 显示当前版本
        DisplayCurrentVersion();
        
        // 加载上次登录的姓名
        LoadLastLoginName();
    }

    /// <summary>
    /// 显示当前版本号
    /// </summary>
    private void DisplayCurrentVersion()
    {
        try
        {
            var version = AppInfo.Current.VersionString;
            lblVersion.Text = $"版本 {version}";
            lblVersion.IsVisible = true;
        }
        catch
        {
            lblVersion.IsVisible = false;
        }
    }
    
    /// <summary>
    /// 加载上次登录的姓名
    /// </summary>
    private void LoadLastLoginName()
    {
        try
        {
            var lastLoginName = Preferences.Get(LastLoginNameKey, string.Empty);
            if (!string.IsNullOrWhiteSpace(lastLoginName))
            {
                txtName.Text = lastLoginName;
                System.Diagnostics.Debug.WriteLine($"已加载上次登录姓名: {lastLoginName}");
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"加载上次登录姓名失败: {ex.Message}");
        }
    }
    
    /// <summary>
    /// 保存登录成功的姓名
    /// </summary>
    private void SaveLastLoginName(string name)
    {
        try
        {
            Preferences.Set(LastLoginNameKey, name);
            System.Diagnostics.Debug.WriteLine($"已保存登录姓名: {name}");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"保存登录姓名失败: {ex.Message}");
        }
    }

    private async Task LoadAccountsAsync()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine("===== 开始加载账号 =====");
            
            // 1. 列出所有嵌入式资源
            var assembly = Assembly.GetExecutingAssembly();
            var allResources = assembly.GetManifestResourceNames();
            System.Diagnostics.Debug.WriteLine($"找到 {allResources.Length} 个嵌入式资源:");
            foreach (var res in allResources)
            {
                System.Diagnostics.Debug.WriteLine($"  - {res}");
            }
            
            // 2. 检查 zh.txt 是否存在
            var resourceName = "skzj.zh.txt";
            bool exists = allResources.Contains(resourceName);
            System.Diagnostics.Debug.WriteLine($"\nzh.txt 存在: {exists}");
            
            if (!exists)
            {
                // 尝试其他可能的名称
                var possibleNames = allResources.Where(r => r.Contains("zh")).ToArray();
                if (possibleNames.Length > 0)
                {
                    System.Diagnostics.Debug.WriteLine("可能的 zh 资源:");
                    foreach (var name in possibleNames)
                    {
                        System.Diagnostics.Debug.WriteLine($"  - {name}");
                    }
                    resourceName = possibleNames[0];
                }
                else
                {
                    throw new FileNotFoundException("未找到 zh.txt 嵌入式资源");
                }
            }
            
            // 3. 直接从嵌入式资源读取
            System.Diagnostics.Debug.WriteLine($"\n正在读取资源: {resourceName}");
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream == null)
            {
                throw new Exception($"无法打开资源流: {resourceName}");
            }
            
            using var reader = new StreamReader(stream);
            var content = await reader.ReadToEndAsync();
            System.Diagnostics.Debug.WriteLine($"读取到 {content.Length} 字符");
            System.Diagnostics.Debug.WriteLine($"前100字符: {content.Substring(0, Math.Min(100, content.Length))}");
            
            // 4. 解析账号
            System.Diagnostics.Debug.WriteLine("\n开始解析账号...");
            var accounts = new List<Account>();
            var lines = content.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            System.Diagnostics.Debug.WriteLine($"共 {lines.Length} 行");
            
            int lineNum = 0;
            foreach (var line in lines)
            {
                lineNum++;
                if (string.IsNullOrWhiteSpace(line))
                {
                    System.Diagnostics.Debug.WriteLine($"  第 {lineNum} 行: 空行，跳过");
                    continue;
                }
                
                var parts = line.Trim().Split(new[] { ',', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                System.Diagnostics.Debug.WriteLine($"  第 {lineNum} 行: {parts.Length} 个字段");
                
                if (parts.Length >= 4)
                {
                    var account = new Account(parts[0].Trim(), parts[1].Trim(), parts[2].Trim(), parts[3].Trim());
                    accounts.Add(account);
                    System.Diagnostics.Debug.WriteLine($"    ? 添加账号: {parts[0]}");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"    ? 字段不足，需要4个，实际{parts.Length}个");
                }
            }
            
            _accounts = accounts;
            System.Diagnostics.Debug.WriteLine($"\n最终加载了 {_accounts.Count} 个账号");
            System.Diagnostics.Debug.WriteLine("===== 加载完成 =====\n");
            
            // 5. 更新 UI - 只显示"已成功加载"
            if (_accounts.Count > 0)
            {
                lblAccountStatus.Text = "已成功加载";
                lblAccountStatus.TextColor = Colors.Green;
                lblAccountStatus.IsVisible = true;
            }
            else
            {
                lblAccountStatus.Text = "未找到账号";
                lblAccountStatus.TextColor = Colors.Orange;
                lblAccountStatus.IsVisible = true;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("===== 加载账号失败 =====");
            System.Diagnostics.Debug.WriteLine($"错误类型: {ex.GetType().Name}");
            System.Diagnostics.Debug.WriteLine($"错误消息: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"堆栈跟踪:\n{ex.StackTrace}");
            System.Diagnostics.Debug.WriteLine("========================\n");
            
            lblAccountStatus.Text = "账号加载失败";
            lblAccountStatus.TextColor = Colors.Red;
            lblAccountStatus.IsVisible = true;
            
            // 显示详细错误给用户
            await DisplayAlert("加载失败", $"账号加载失败:\n{ex.Message}\n\n请查看调试日志获取详细信息", "确定");
        }
    }

    /// <summary>
    /// 手动检查 APP 版本更新
    /// </summary>
    private async void OnCheckUpdateClicked(object? sender, EventArgs e)
    {
        try
        {
            // 禁用按钮，防止重复点击
            btnCheckUpdate.IsEnabled = false;
            btnCheckUpdate.Text = "正在检查...";

            var updateInfo = await _updateService.CheckForUpdatesAsync();
            
            if (updateInfo != null)
            {
                // 发现新版本 - 改进的提示
                var message = $"当前版本: {updateInfo.CurrentVersion}\n" +
                             $"最新版本: {updateInfo.LatestVersion}\n\n";
                
                // 简化更新说明（只显示前200字符）
                if (!string.IsNullOrWhiteSpace(updateInfo.ReleaseNotes))
                {
                    var notes = updateInfo.ReleaseNotes.Length > 200 
                        ? updateInfo.ReleaseNotes.Substring(0, 200) + "..." 
                        : updateInfo.ReleaseNotes;
                    message += $"更新内容:\n{notes}\n\n";
                }
                
                message += "是否立即下载更新？\n\n" +
                          "注意：将从蓝奏云下载（国内高速）";
                
                var result = await DisplayAlert(
                    "发现新版本",
                    message,
                    "立即下载",
                    "稍后");

                if (result && !string.IsNullOrWhiteSpace(updateInfo.DownloadUrl))
                {
                    try
                    {
                        // 尝试打开蓝奏云下载链接
                        var opened = await Launcher.TryOpenAsync(new Uri(updateInfo.DownloadUrl));
                        
                        if (!opened)
                        {
                            // 如果无法打开，显示下载地址让用户手动复制
                            await DisplayAlert(
                                "无法打开浏览器",
                                $"请手动复制以下链接到浏览器下载：\n\n{updateInfo.DownloadUrl}\n\n" +
                                "蓝奏云下载，国内高速访问",
                                "确定");
                        }
                        else
                        {
                            // 成功打开，给用户提示
                            await DisplayAlert(
                                "下载提示",
                                "已打开蓝奏云下载页面\n\n" +
                                "1. 在页面中找到最新版本 APK\n" +
                                "2. 点击下载按钮\n" +
                                "3. 下载完成后点击安装\n" +
                                "4. 选择\"覆盖安装\"保留数据",
                                "知道了");
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"打开链接失败: {ex.Message}");
                        
                        // 打开失败，显示链接让用户复制
                        await DisplayAlert(
                            "无法打开下载页面",
                            $"请复制以下地址到浏览器下载：\n\n{updateInfo.DownloadUrl}\n\n" +
                            "蓝奏云下载，国内高速访问",
                            "确定");
                    }
                }
            }
            else
            {
                // 已是最新版本
                await DisplayAlert(
                    "检查更新",
                    $"当前已是最新版本 {AppInfo.Current.VersionString}",
                    "确定");
            }
        }
        catch (Exception ex)
        {
            // 检查更新失败
            System.Diagnostics.Debug.WriteLine($"检查更新失败: {ex.Message}");
            
            await DisplayAlert(
                "检查更新",
                "检查更新失败，请稍后再试\n\n可能原因：\n- 网络连接问题\n- 无法连接到更新服务器",
                "确定");
        }
        finally
        {
            // 恢复按钮状态
            btnCheckUpdate.IsEnabled = true;
            btnCheckUpdate.Text = "检查更新";
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
            ShowError("未授权用户");
            return;
        }

        // 验证码验证
        if (!code.Equals(account.VerificationCode))
        {
            ShowError("验证码错误");
            return;
        }

        // 登录成功，保存姓名
        SaveLastLoginName(name);
        
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

            // 清空验证码，但保留姓名（已自动保存）
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
