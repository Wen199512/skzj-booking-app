using Microsoft.Maui.Controls;
using skzj.Models;
using skzj.Services;
using skzj.Helpers;

namespace skzj;

public partial class LoginPage : ContentPage
{
    private readonly BookingService _bookingService;
    private List<Account> _accounts = new();

    public LoginPage()
    {
        InitializeComponent();
        _bookingService = new BookingService();
        _ = LoadAccountsAsync();
    }

    private async Task LoadAccountsAsync()
    {
        try
        {
            // 从嵌入式资源提取 zh.txt 到应用数据目录
            var filePath = await EmbeddedResourceHelper.ExtractEmbeddedResourceAsync("zh.txt");
            
            // 加载账号
            _accounts = await _bookingService.LoadAccountsFromFileAsync(filePath);
            
            if (_accounts.Count > 0)
            {
                lblAccountStatus.Text = $"已连接";
                lblAccountStatus.TextColor = Colors.Green;
                lblAccountStatus.IsVisible = true;
            }
            else
            {
                lblAccountStatus.Text = "连接失败";
                lblAccountStatus.TextColor = Colors.Orange;
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

        // 验证码直接从文件读取（第二列）
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
