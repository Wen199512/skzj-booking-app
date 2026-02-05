using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace skzj.Services;

/// <summary>
/// 应用更新检测服务
/// </summary>
public class UpdateService
{
    // GitHub API 地址（用于检查版本）
    private const string GitHubApiUrl = "https://api.github.com/repos/Wen199512/skzj-booking-app/releases/latest";
    
    // 蓝奏云下载地址（实际下载地址）
    private const string LanzouDownloadUrl = "https://wwbqz.lanzouu.com/b019vnsnuh";
    
    private readonly HttpClient _httpClient;

    public UpdateService()
    {
        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("SKZJ-Booking-App");
        _httpClient.Timeout = TimeSpan.FromSeconds(10);
    }

    /// <summary>
    /// 检查是否有新版本
    /// </summary>
    public async Task<UpdateInfo?> CheckForUpdatesAsync()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine($"开始检查更新，API: {GitHubApiUrl}");
            
            var response = await _httpClient.GetFromJsonAsync<GitHubRelease>(GitHubApiUrl);
            
            if (response == null)
            {
                System.Diagnostics.Debug.WriteLine("API 返回为空");
                return null;
            }

            var latestVersion = response.TagName?.TrimStart('v');
            var currentVersion = AppInfo.Current.VersionString;
            
            System.Diagnostics.Debug.WriteLine($"当前版本: {currentVersion}");
            System.Diagnostics.Debug.WriteLine($"最新版本: {latestVersion}");

            if (IsNewerVersion(latestVersion, currentVersion))
            {
                System.Diagnostics.Debug.WriteLine("发现新版本！");
                // 使用蓝奏云下载地址，而不是 GitHub 地址
                return new UpdateInfo
                {
                    LatestVersion = latestVersion,
                    CurrentVersion = currentVersion,
                    DownloadUrl = LanzouDownloadUrl,  // 使用蓝奏云地址
                    ReleaseNotes = response.Body,
                    PublishedAt = response.PublishedAt
                };
            }

            System.Diagnostics.Debug.WriteLine("已是最新版本");
            return null;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"检查更新失败: {ex.Message}");
            System.Diagnostics.Debug.WriteLine($"异常类型: {ex.GetType().Name}");
            System.Diagnostics.Debug.WriteLine($"堆栈: {ex.StackTrace}");
            return null;
        }
    }

    /// <summary>
    /// 比较版本号
    /// </summary>
    private bool IsNewerVersion(string? latest, string? current)
    {
        if (string.IsNullOrWhiteSpace(latest) || string.IsNullOrWhiteSpace(current))
            return false;

        try
        {
            var latestParts = latest.Split('.').Select(int.Parse).ToArray();
            var currentParts = current.Split('.').Select(int.Parse).ToArray();

            for (int i = 0; i < Math.Min(latestParts.Length, currentParts.Length); i++)
            {
                if (latestParts[i] > currentParts[i]) return true;
                if (latestParts[i] < currentParts[i]) return false;
            }

            return latestParts.Length > currentParts.Length;
        }
        catch
        {
            return false;
        }
    }
}

/// <summary>
/// 更新信息
/// </summary>
public class UpdateInfo
{
    public string? LatestVersion { get; set; }
    public string? CurrentVersion { get; set; }
    public string? DownloadUrl { get; set; }
    public string? ReleaseNotes { get; set; }
    public DateTime? PublishedAt { get; set; }
}

/// <summary>
/// GitHub Release 响应
/// </summary>
public class GitHubRelease
{
    [JsonPropertyName("tag_name")]
    public string? TagName { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("body")]
    public string? Body { get; set; }

    [JsonPropertyName("published_at")]
    public DateTime? PublishedAt { get; set; }

    [JsonPropertyName("assets")]
    public List<GitHubAsset>? Assets { get; set; }
}

/// <summary>
/// GitHub Asset
/// </summary>
public class GitHubAsset
{
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("browser_download_url")]
    public string? BrowserDownloadUrl { get; set; }

    [JsonPropertyName("size")]
    public long Size { get; set; }
}
