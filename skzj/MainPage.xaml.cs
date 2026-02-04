using System.Collections.ObjectModel;
using Microsoft.Maui.Controls;
using skzj.Models;
using skzj.Services;

namespace skzj;

public partial class MainPage : ContentPage
{
    private readonly BookingService _bookingService;
    private CancellationTokenSource? _cts;
    private Task? _mainTask;
    private int _totalSubmits;
    private readonly object _logLock = new();
    private readonly Account _currentAccount;
    private readonly ObservableCollection<ActivityInfo> _regularActivities = new();
    private readonly ObservableCollection<ActivityInfo> _hotActivities = new();
    private readonly List<ActivityInfo> _selectedActivities = new();
    private const int MaxSelectedActivities = 3;

    public MainPage(Account account)
    {
        ArgumentNullException.ThrowIfNull(account);

        InitializeComponent();
        _bookingService = new BookingService();
        _currentAccount = account;

        lstActivities.ItemsSource = _regularActivities;
        lstActivities2.ItemsSource = _hotActivities;

        InitializeUI();
    }

    private void InitializeUI()
    {
        lblCurrentUser.Text = $"当前用户: {_currentAccount.Name}";
        Log($"欢迎, {_currentAccount.Name}! 您已成功登录");
    }

    private async void OnQueryActivitiesClicked(object? sender, EventArgs e)
    {
        try
        {
            btnQueryActivities.IsEnabled = false;
            _regularActivities.Clear();
            _hotActivities.Clear();
            Log("正在查询活动列表...");

            var sessionId = "lwim4eswym2wuhe5t0044hgq";

            var regularTask = _bookingService.QueryActivitiesAsync(sessionId);
            var hotTask = _bookingService.QueryHotActivitiesAsync(sessionId);

            await Task.WhenAll(regularTask, hotTask);

            var regularActivities = await regularTask;
            var hotActivities = await hotTask;

            foreach (var act in regularActivities)
            {
                _regularActivities.Add(act);
            }

            foreach (var act in hotActivities)
            {
                _hotActivities.Add(act);
            }

            Log($"查询到 {regularActivities.Count} 个常规活动");
            Log($"查询到 {hotActivities.Count} 个热门福利活动");
            Log($"共加载 {regularActivities.Count + hotActivities.Count} 个活动，点击可选择");
        }
        catch (Exception ex)
        {
            Log($"查询活动列表失败: {ex.Message}");
            await DisplayAlert("错误", $"查询失败: {ex.Message}", "确定");
        }
        finally
        {
            btnQueryActivities.IsEnabled = true;
        }
    }

    private void OnActivityTapped(object? sender, TappedEventArgs e)
    {
        if (sender is not Frame frame || frame.BindingContext is not ActivityInfo activity)
            return;

        // 检查是否已选择
        if (_selectedActivities.Any(a => a.ActId == activity.ActId))
        {
            // 取消选择
            _selectedActivities.RemoveAll(a => a.ActId == activity.ActId);
            Log($"取消选择: {activity.ActTitle}");
        }
        else
        {
            // 检查是否达到最大选择数
            if (_selectedActivities.Count >= MaxSelectedActivities)
            {
                Log($"最多只能选择 {MaxSelectedActivities} 个活动");
                DisplayAlert("提示", $"最多只能选择 {MaxSelectedActivities} 个活动", "确定");
                return;
            }

            // 添加选择
            _selectedActivities.Add(activity);
            Log($"已选择: {activity.ActTitle} (ID: {activity.ActId})");
        }

        UpdateSelectedActivitiesDisplay();
    }

    private void UpdateSelectedActivitiesDisplay()
    {
        selectedActivitiesContainer.Children.Clear();

        if (_selectedActivities.Count == 0)
        {
            selectedActivitiesContainer.Children.Add(new Label
            {
                Text = "未选择任何活动",
                TextColor = Colors.Gray,
                FontSize = 12
            });
            return;
        }

        foreach (var activity in _selectedActivities)
        {
            var frame = new Frame
            {
                Padding = 8,
                Margin = new Thickness(0, 2),
                BackgroundColor = Color.FromArgb("#E8F5E9"),
                HasShadow = false,
                CornerRadius = 5
            };

            var grid = new Grid
            {
                ColumnDefinitions =
                {
                    new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) },
                    new ColumnDefinition { Width = GridLength.Auto }
                }
            };

            var label = new Label
            {
                Text = $"{activity.ActTitle} (ID: {activity.ActId})",
                FontSize = 12,
                VerticalOptions = LayoutOptions.Center
            };
            grid.Add(label, 0, 0);

            var removeButton = new Button
            {
                Text = "×",
                FontSize = 16,
                TextColor = Colors.Red,
                BackgroundColor = Colors.Transparent,
                Padding = new Thickness(5, 0),
                WidthRequest = 30,
                HeightRequest = 30
            };
            removeButton.Clicked += (s, e) =>
            {
                _selectedActivities.Remove(activity);
                Log($"移除选择: {activity.ActTitle}");
                UpdateSelectedActivitiesDisplay();
            };
            grid.Add(removeButton, 1, 0);

            frame.Content = grid;
            selectedActivitiesContainer.Children.Add(frame);
        }
    }

    private async void OnStartClicked(object? sender, EventArgs e)
    {
        if (_cts != null)
        {
            Log("已经在运行中");
            return;
        }

        if (_selectedActivities.Count == 0)
        {
            await DisplayAlert("提示", "请先选择要预约的活动", "确定");
            Log("请先选择要预约的活动");
            return;
        }

        _cts = new CancellationTokenSource();
        _totalSubmits = 0;

        btnStart.IsEnabled = false;
        btnStop.IsEnabled = true;

        _mainTask = Task.Run(async () => await RunBookingAsync(_cts.Token));
    }

    private void OnStopClicked(object? sender, EventArgs e)
    {
        if (_cts == null)
        {
            Log("未在运行中");
            return;
        }

        _cts.Cancel();
        Log("已发出停止请求，正在等待任务结束...");
    }

    private async Task RunBookingAsync(CancellationToken cancellationToken)
    {
        try
        {
            Log($"开始预约 {_selectedActivities.Count} 个活动...");
            Log($"预约人: {_currentAccount.Name}");

            var accounts = new List<Account> { _currentAccount };
            var allResults = new List<string>();

            // 依次预约每个活动
            foreach (var activity in _selectedActivities)
            {
                if (cancellationToken.IsCancellationRequested)
                    break;

                Log($"\n--- 预约活动: {activity.ActTitle} (ID: {activity.ActId}) ---");

                var results = await _bookingService.RunBookingAsync(
                    activity.ActId,
                    accounts,
                    cancellationToken,
                    msg => Log(msg),
                    () => Interlocked.Increment(ref _totalSubmits)
                );

                foreach (var result in results)
                {
                    Log(result);
                    allResults.Add($"[{activity.ActTitle}] {result}");
                }

                // 短暂延迟后预约下一个活动
                if (_selectedActivities.IndexOf(activity) < _selectedActivities.Count - 1)
                {
                    await Task.Delay(1000, cancellationToken);
                }
            }

            Log($"\n总提交次数: {_totalSubmits}");
            Log("所有活动预约完成");
        }
        catch (OperationCanceledException)
        {
            Log("预约已取消");
        }
        catch (Exception ex)
        {
            Log($"执行期间发生错误: {ex.Message}");
        }
        finally
        {
            if (_cts != null)
            {
                _cts.Dispose();
                _cts = null;
            }
            _mainTask = null;

            MainThread.BeginInvokeOnMainThread(() =>
            {
                btnStart.IsEnabled = true;
                btnStop.IsEnabled = false;
            });
        }
    }

    private void Log(string text)
    {
        var line = $"[{DateTime.Now:HH:mm:ss}] {text}\n";

        lock (_logLock)
        {
            MainThread.BeginInvokeOnMainThread(() =>
            {
                txtLog.Text += line;
                
                // 自动滚动到底部
                logScrollView.ScrollToAsync(txtLog, ScrollToPosition.End, false);
            });
        }
    }
}
