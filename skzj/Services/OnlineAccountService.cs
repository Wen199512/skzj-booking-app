using System.Net.Http;
using System.Text;
using skzj.Models;

namespace skzj.Services;

/// <summary>
/// 在线账号服务 - 从 GitHub 读取账号文件
/// </summary>
public class OnlineAccountService
{
    // GitHub 原始文件 URL - 替换为您的仓库地址
    private const string GitHubRawUrl = "https://raw.githubusercontent.com/Wen199512/skzj-booking-app/main/skzj/zh.txt";
    
    private readonly HttpClient _httpClient;
    private readonly BookingService _bookingService;

    public OnlineAccountService()
    {
        _httpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(10)
        };
        _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("SKZJ-Booking-App/1.0");
        
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
        catch (HttpRequestException ex)
        {
            System.Diagnostics.Debug.WriteLine($"从 GitHub 下载失败 (网络错误): {ex.Message}");
            throw;
        }
        catch (TaskCanceledException ex)
        {
            System.Diagnostics.Debug.WriteLine($"从 GitHub 下载超时: {ex.Message}");
            throw;
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
    /// <returns>账号列表和来源（true=GitHub, false=本地）</returns>
    public async Task<(List<Account> Accounts, bool FromGitHub)> LoadAccountsAsync()
    {
        // 1. 尝试从 GitHub 加载
        try
        {
            var accounts = await LoadAccountsFromGitHubAsync();
            if (accounts.Count > 0)
            {
                System.Diagnostics.Debug.WriteLine($"? 从 GitHub 成功加载 {accounts.Count} 个账号");
                return (accounts, true);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"?? 从 GitHub 加载失败，尝试使用本地文件: {ex.Message}");
        }

        // 2. 从本地嵌入式资源加载（备用）
        try
        {
            var filePath = await Helpers.EmbeddedResourceHelper.ExtractEmbeddedResourceAsync("zh.txt");
            var accounts = await _bookingService.LoadAccountsFromFileAsync(filePath);
            
            if (accounts.Count > 0)
            {
                System.Diagnostics.Debug.WriteLine($"? 从本地备用文件加载 {accounts.Count} 个账号");
                return (accounts, false);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"? 从本地加载也失败: {ex.Message}");
        }

        // 3. 完全失败
        System.Diagnostics.Debug.WriteLine("? 无法加载账号文件");
        return (new List<Account>(), false);
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

            // 忽略注释行
            if (line.TrimStart().StartsWith("#"))
                continue;

            var parts = line.Trim().Split(new[] { ',', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 4)
            {
                try
                {
                    // 格式: 姓名,验证码,账号ID,密码
                    var account = new Account(
                        parts[0].Trim(),
                        parts[1].Trim(),
                        parts[2].Trim(),
                        parts[3].Trim()
                    );
                    accounts.Add(account);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"解析账号行失败: {line}, 错误: {ex.Message}");
                }
            }
        }

        return accounts;
    }

    /// <summary>
    /// 检查 GitHub 连接
    /// </summary>
    public async Task<bool> TestGitHubConnectionAsync()
    {
        try
        {
            var accounts = await LoadAccountsFromGitHubAsync();
            return accounts.Count > 0;
        }
        catch
        {
            return false;
        }
    }
}
