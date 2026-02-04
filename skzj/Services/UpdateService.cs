using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace skzj.Services;

/// <summary>
/// 应用更新检测服务
/// </summary>
public class UpdateService
{
    // GitHub API 地址（替换为您的仓库地址）
    private const string GitHubApiUrl = "https://api.github.com/repos/YOUR_USERNAME/skzj-booking-app/releases/latest";
    
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
