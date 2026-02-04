using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Concurrent;
using skzj.Models;

namespace skzj.Services;

public class BookingService
{
    private const string BaseUrl = "https://m.sgzy.com.cn:2000";
    private static readonly HttpClient SharedHttpClient = CreateSharedHttpClient();

    public async Task<List<Account>> LoadAccountsFromFileAsync(string filePath)
    {
        ArgumentNullException.ThrowIfNull(filePath);

        if (!File.Exists(filePath))
            return new List<Account>();

        var lines = await File.ReadAllLinesAsync(filePath, Encoding.UTF8);
        var accounts = new List<Account>();

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

    public async Task<List<ActivityInfo>> QueryActivitiesAsync(string sessionId, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(sessionId);

        var queryUrl = BaseUrl + "/app/AppBusiness.ashx?action=queryActivityList";

        using var http = CreateHttpClient(BaseUrl, sessionId);
        using var req = new HttpRequestMessage(HttpMethod.Post, queryUrl);

        ApplyCommonHeaders(req, "https://m.sgzy.com.cn:2000/appWeb/tab-activity_bak.html");
        req.Content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            { "rows", "10" },
            { "actflag", "1" }
        });
        req.Content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        using var resp = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        if (resp.IsSuccessStatusCode)
        {
            var body = await resp.Content.ReadAsStringAsync(cancellationToken);
            return ParseActivities(body);
        }

        return new List<ActivityInfo>();
    }

    public async Task<List<ActivityInfo>> QueryHotActivitiesAsync(string sessionId, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(sessionId);

        var queryUrl = BaseUrl + "/app/AppBusiness.ashx?action=queryHotFl";

        using var http = CreateHttpClient(BaseUrl, sessionId);
        using var req = new HttpRequestMessage(HttpMethod.Post, queryUrl);

        ApplyCommonHeaders(req, "https://m.sgzy.com.cn:2000/appWeb/tab-welfare.html");
        req.Content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            { "rows", "20" }
        });
        req.Content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        using var resp = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        if (resp.IsSuccessStatusCode)
        {
            var body = await resp.Content.ReadAsStringAsync(cancellationToken);
            return ParseActivities(body);
        }

        return new List<ActivityInfo>();
    }

    public async Task<string[]> RunBookingAsync(
        string actId,
        List<Account> accounts,
        CancellationToken cancellationToken,
        Action<string> logCallback,
        Func<int> onSubmitCallback)
    {
        ArgumentNullException.ThrowIfNull(actId);
        ArgumentNullException.ThrowIfNull(accounts);
        ArgumentNullException.ThrowIfNull(logCallback);
        ArgumentNullException.ThrowIfNull(onSubmitCallback);

        var loginUrl = BaseUrl + "/app/AppAuth.ashx?action=login";
        var bookUrl = BaseUrl + "/app/AppBusiness.ashx?action=bookActivity";

        // 增加并发线程数：使用 CPU 核心数的 4 倍，最少 32，最多 128
        var maxParallel = Math.Clamp(Environment.ProcessorCount * 4, 32, 128);
        using var gate = new SemaphoreSlim(maxParallel, maxParallel);

        var sessionId = "ddw1j4h5t1c3a0vtgdiqob2l";

        logCallback($"启动高性能预约模式: {maxParallel} 个并发线程");

        // 为每个账号创建多个并发任务（每账号 20 个线程）
        var tasksPerAccount = 20;
        var allTasks = new List<Task<string>>();

        foreach (var account in accounts)
        {
            for (int i = 0; i < tasksPerAccount; i++)
            {
                var taskId = i + 1;
                allTasks.Add(ProcessAccountAsync(
                    BaseUrl,
                    sessionId,
                    loginUrl,
                    bookUrl,
                    actId,
                    account,
                    taskId,
                    gate,
                    cancellationToken,
                    onSubmitCallback,
                    logCallback
                ));
            }
        }

        return await Task.WhenAll(allTasks);
    }

    private async Task<string> ProcessAccountAsync(
        string baseUrl,
        string sessionId,
        string loginUrl,
        string bookUrl,
        string actId,
        Account account,
        int taskId,
        SemaphoreSlim gate,
        CancellationToken cancellationToken,
        Func<int> onSubmit,
        Action<string> log)
    {
        var submits = 0;
        LoginResult? login = null;

        try
        {
            await gate.WaitAsync(cancellationToken);

            using var http = CreateHttpClient(baseUrl, sessionId);

            // 登录
            login = await LoginAsync(http, loginUrl, account.UserId, account.Password, cancellationToken);
            if (!login.Ok || string.IsNullOrWhiteSpace(login.Token))
            {
                return $"{account.Name}-T{taskId} | 登录失败: {login.Msg}";
            }

            // 快速提交循环 - 无延迟
            while (!cancellationToken.IsCancellationRequested)
            {
                var total = onSubmit();
                submits++;

                // 每 100 次提交记录一次日志，减少日志开销
                if (submits % 100 == 0)
                {
                    log($"{account.Name}-T{taskId} | 提交: {submits} | 总计: {total}");
                }

                var book = await BookAsync(http, bookUrl, actId, login.Token, cancellationToken);
                if (book.Ok && IsBookSuccess(book.Msg))
                {
                    log($"?? {account.Name}-T{taskId} | 预约成功! {book.Msg} | 提交次数: {submits}");
                    return $"{account.Name}-T{taskId} | 预约成功 | 提交次数: {submits}";
                }

                // 移除延迟，最大化提交速度
                // await Task.Delay(100, cancellationToken);
            }

            return $"{account.Name}-T{taskId} | 已取消 | 提交次数: {submits}";
        }
        catch (OperationCanceledException)
        {
            return $"{account.Name}-T{taskId} | 已取消 | 提交次数: {submits}";
        }
        catch (Exception ex)
        {
            log($"? {account.Name}-T{taskId} | 异常: {ex.Message}");
            return $"{account.Name}-T{taskId} | 异常 | 提交次数: {submits}";
        }
        finally
        {
            gate.Release();
        }
    }

    private async Task<LoginResult> LoginAsync(
        HttpClient http,
        string loginUrl,
        string userId,
        string password,
        CancellationToken cancellationToken)
    {
        using var loginReq = new HttpRequestMessage(HttpMethod.Post, loginUrl);
        ApplyCommonHeaders(loginReq, "https://m.sgzy.com.cn:2000/appWeb/login.html");
        loginReq.Content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            { "UserID", userId },
            { "Password", password },
        });
        loginReq.Content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        using var loginResp = await http.SendAsync(loginReq, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        var loginBody = await loginResp.Content.ReadAsStringAsync(cancellationToken);

        if (!loginResp.IsSuccessStatusCode)
        {
            return new LoginResult(false, $"HTTP {(int)loginResp.StatusCode}", null);
        }

        var msg = GetMsgOrBody(loginBody);
        var token = GetTokenOrNull(loginBody);
        var ok = !string.IsNullOrWhiteSpace(token);

        return new LoginResult(ok, msg, token);
    }

    private async Task<ApiResult> BookAsync(
        HttpClient http,
        string bookUrl,
        string actId,
        string token,
        CancellationToken cancellationToken)
    {
        using var bookReq = new HttpRequestMessage(HttpMethod.Post, bookUrl);
        ApplyCommonHeaders(bookReq, "https://m.sgzy.com.cn:2000/appWeb/activity_detail.html");
        bookReq.Content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            { "actid", actId },
            { "token", token },
        });
        bookReq.Content.Headers.ContentType = new MediaTypeHeaderValue("application/x-www-form-urlencoded");

        using var bookResp = await http.SendAsync(bookReq, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        var bookBody = await bookResp.Content.ReadAsStringAsync(cancellationToken);

        if (!bookResp.IsSuccessStatusCode)
        {
            return new ApiResult(false, $"HTTP {(int)bookResp.StatusCode}");
        }

        return new ApiResult(true, GetMsgOrBody(bookBody));
    }

    private List<ActivityInfo> ParseActivities(string json)
    {
        var result = new List<ActivityInfo>();
        if (string.IsNullOrWhiteSpace(json))
            return result;

        try
        {
            var actIdPattern = "\\\"actid\\\"\\s*:\\s*\\\"(?<id>[^\\\"]*)\\\"";
            var actTitlePattern = "\\\"acttitle\\\"\\s*:\\s*\\\"(?<title>[^\\\"]*)\\\"";

            var idMatches = Regex.Matches(json, actIdPattern, RegexOptions.IgnoreCase);
            var titleMatches = Regex.Matches(json, actTitlePattern, RegexOptions.IgnoreCase);

            var count = Math.Min(idMatches.Count, titleMatches.Count);
            for (int i = 0; i < count; i++)
            {
                var actId = idMatches[i].Groups["id"].Value;
                var actTitle = titleMatches[i].Groups["title"].Value;

                if (!string.IsNullOrWhiteSpace(actId))
                {
                    result.Add(new ActivityInfo
                    {
                        ActId = actId,
                        ActTitle = string.IsNullOrWhiteSpace(actTitle) ? "(无标题)" : actTitle
                    });
                }
            }
        }
        catch
        {
            // Silently return empty list on parse error
        }

        return result;
    }

    private static HttpClient CreateSharedHttpClient()
    {
        var handler = new SocketsHttpHandler
        {
            AutomaticDecompression = DecompressionMethods.All,
            UseCookies = false, // 手动管理 Cookie
            PooledConnectionLifetime = TimeSpan.FromMinutes(5),
            PooledConnectionIdleTimeout = TimeSpan.FromMinutes(2),
            MaxConnectionsPerServer = 256, // 增加每服务器连接数
        };

        return new HttpClient(handler)
        {
            Timeout = TimeSpan.FromSeconds(10) // 减少超时时间
        };
    }

    private static HttpClient CreateHttpClient(string baseUrl, string sessionId)
    {
        var cookieContainer = new CookieContainer();
        cookieContainer.Add(new Uri(baseUrl), new Cookie("ASP.NET_SessionId", sessionId));

        var handler = new SocketsHttpHandler
        {
            AutomaticDecompression = DecompressionMethods.All,
            UseCookies = true,
            CookieContainer = cookieContainer,
            PooledConnectionLifetime = TimeSpan.FromMinutes(2),
            PooledConnectionIdleTimeout = TimeSpan.FromSeconds(30),
            MaxConnectionsPerServer = 64, // 每个客户端更多连接
        };

        return new HttpClient(handler)
        {
            Timeout = TimeSpan.FromSeconds(10)
        };
    }

    private static void ApplyCommonHeaders(HttpRequestMessage request, string referer)
    {
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        request.Headers.TryAddWithoutValidation("Host", "m.sgzy.com.cn:2000");
        request.Headers.TryAddWithoutValidation(
            "User-Agent",
            "Mozilla/5.0 (Linux; Android 16; PHB110 Build/TP1A.220905.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/134.0.6998.135 Mobile Safari/537.36 Html5Plus/1.0");
        request.Headers.TryAddWithoutValidation("sec-ch-ua-platform", "\"Android\"");
        request.Headers.TryAddWithoutValidation("X-Requested-With", "XMLHttpRequest");
        request.Headers.TryAddWithoutValidation("sec-ch-ua", "\"Chromium\";v=\"134\", \"Not:A-Brand\";v=\"24\", \"Android WebView\";v=\"134\"");
        request.Headers.TryAddWithoutValidation("sec-ch-ua-mobile", "?1");
        request.Headers.TryAddWithoutValidation("Origin", "https://m.sgzy.com.cn:2000");
        request.Headers.TryAddWithoutValidation("Sec-Fetch-Site", "same-origin");
        request.Headers.TryAddWithoutValidation("Sec-Fetch-Mode", "cors");
        request.Headers.TryAddWithoutValidation("Sec-Fetch-Dest", "empty");
        request.Headers.TryAddWithoutValidation("Referer", referer);
        request.Headers.TryAddWithoutValidation("Accept-Language", "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7");
    }

    private static string? TryExtractJsonString(string json, string key)
    {
        if (string.IsNullOrWhiteSpace(json) || string.IsNullOrWhiteSpace(key))
            return null;

        var pattern = "\\\"" + Regex.Escape(key) + "\\\"\\s*:\\s*\\\"(?<v>[^\\\"]*)\\\"";
        var m = Regex.Match(json, pattern, RegexOptions.IgnoreCase);
        if (!m.Success)
            return null;

        var v = m.Groups["v"].Value;
        return string.IsNullOrWhiteSpace(v) ? null : v;
    }

    private static string GetMsgOrBody(string body)
    {
        var msg = TryExtractJsonString(body, "Msg") ?? TryExtractJsonString(body, "msg");
        return string.IsNullOrWhiteSpace(msg) ? (body ?? string.Empty) : msg;
    }

    private static string? GetTokenOrNull(string body)
    {
        return TryExtractJsonString(body, "token")
            ?? TryExtractJsonString(body, "Token")
            ?? TryExtractJsonString(body, "TOKEN");
    }

    private static bool ContainsIgnoreCase(string text, string value)
    {
        if (text == null || value == null)
            return false;

        return text.IndexOf(value, StringComparison.OrdinalIgnoreCase) >= 0;
    }

    private static bool IsBookSuccess(string msg)
    {
        if (string.IsNullOrWhiteSpace(msg))
            return false;

        return ContainsIgnoreCase(msg, "预约成功") || ContainsIgnoreCase(msg, "您已经预约，不能重复预约");
    }
}
