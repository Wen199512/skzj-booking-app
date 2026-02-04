# 首矿之家活动预约系统

一个基于 .NET MAUI 开发的 Android/Windows 跨平台活动预约应用。

## ?? 应用信息

- **应用名称**: 首矿之家活动预约
- **应用 ID**: com.skzj.booking
- **当前版本**: 1.0.0
- **目标平台**: Android 5.0+ (API 21+), Windows 10+
- **框架**: .NET 9.0 MAUI

## ? 主要功能

### 1. 用户登录
- 基于姓名的简单登录验证
- 从 `zh.txt` 文件加载账号信息
- 自动验证用户身份

### 2. 活动查询
- 查询常规活动列表
- 查询热门福利活动
- 支持活动详情查看

### 3. 活动预约
- 单账号多线程并发预约
- 实时显示预约进度
- 自动保存预约结果

### 4. 日志记录
- 实时显示操作日志
- 记录预约提交次数
- 保存预约结果到文件

## ?? 项目结构

```
skzj/
├── Models/                 # 数据模型
│   ├── Account.cs         # 账号模型
│   ├── ActivityInfo.cs    # 活动信息模型
│   ├── LoginResult.cs     # 登录结果模型
│   └── ApiResult.cs       # API 结果模型
├── Services/              # 服务层
│   └── BookingService.cs  # 预约服务
├── Pages/                 # 页面
│   ├── LoginPage.xaml     # 登录页面
│   ├── LoginPage.xaml.cs
│   ├── MainPage.xaml      # 主页面
│   └── MainPage.xaml.cs
├── Resources/             # 资源文件
├── zh.txt                 # 账号数据文件
├── 快速发布.bat           # 快速发布脚本
├── publish-android.ps1    # PowerShell 发布脚本
├── 发布指南.md            # 详细发布指南
├── 发布检查清单.md        # 发布检查清单
└── README_账号文件说明.md # 账号文件说明
```

## ?? 快速开始

### 开发环境要求

- Visual Studio 2022 (17.8+) 或 Visual Studio Code
- .NET 9.0 SDK
- .NET MAUI 工作负载
- Android SDK (用于 Android 开发)

### 安装步骤

1. **克隆或下载项目**
   ```bash
   git clone <repository-url>
   cd skzj
   ```

2. **还原 NuGet 包**
   ```bash
   dotnet restore
   ```

3. **准备账号文件**
   - 编辑 `zh.txt` 文件
   - 格式: `姓名,用户ID,密码`

4. **运行项目**
   ```bash
   # Android
   dotnet build -t:Run -f net9.0-android
   
   # Windows
   dotnet build -t:Run -f net9.0-windows10.0.19041.0
   ```

## ?? 发布 APP

### 方法一: 快速发布（推荐新手）

直接双击运行 `快速发布.bat`

### 方法二: PowerShell 脚本

```powershell
.\publish-android.ps1
```

### 方法三: 命令行

```bash
dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64
```

**详细说明请参阅**: [发布指南.md](发布指南.md)

## ?? 安装应用

### Android 设备

1. **通过文件传输**
   - 将 APK 文件传输到手机
   - 在手机上点击 APK 文件安装
   - 允许"未知来源"安装

2. **通过 ADB**
   ```bash
   adb install path\to\app.apk
   ```

### 测试账号

当前 `zh.txt` 包含以下测试账号：

1. 赵忠民
2. 郭丽英
3. 张双军
4. 吴宝坤
5. 温骏
6. 夏彦东
7. 王鹏
8. 鲍东宾
9. 高家伟
10. 许哲
11. 温伯江
12. 李志超
13. 闫青
14. 庞丽凤

## ?? 配置说明

### 账号文件配置

**文件位置**: `skzj/zh.txt`

**格式要求**:
```
姓名,用户ID,密码
张三,USER123,PASS123
李四,USER456,PASS456
```

**注意事项**:
- 使用英文逗号分隔
- 每行一个账号
- 支持 UTF-8 编码
- 姓名不区分大小写

### 应用配置

修改 `skzj.csproj` 中的以下设置：

```xml
<!-- 应用标题 -->
<ApplicationTitle>首矿之家活动预约</ApplicationTitle>

<!-- 应用 ID -->
<ApplicationId>com.skzj.booking</ApplicationId>

<!-- 版本号 -->
<ApplicationDisplayVersion>1.0.0</ApplicationDisplayVersion>
<ApplicationVersion>1</ApplicationVersion>
```

## ?? 故障排查

### 登录失败

- 检查账号文件是否存在
- 验证姓名拼写是否正确
- 确认文件格式正确

### 应用崩溃

- 查看日志输出
- 检查 `zh.txt` 是否包含在 APK 中
- 尝试使用 Debug 版本

### 发布失败

- 确认已安装 Android 工作负载
- 检查网络连接
- 清理项目后重新构建

**更多问题请参阅**: [发布检查清单.md](发布检查清单.md)

## ?? 文档

- [发布指南.md](发布指南.md) - 详细的发布步骤和配置
- [发布检查清单.md](发布检查清单.md) - 发布前检查项
- [README_账号文件说明.md](README_账号文件说明.md) - 账号文件详细说明

## ??? 技术栈

- **框架**: .NET 9.0 MAUI
- **语言**: C# 13.0
- **UI**: XAML
- **HTTP**: HttpClient
- **异步**: async/await
- **并发**: SemaphoreSlim, Task.WhenAll

## ?? 系统要求

### 开发环境
- Windows 10/11 或 macOS
- 16GB+ RAM (推荐)
- Visual Studio 2022 或 VS Code

### 运行环境

**Android**:
- Android 5.0 (API 21) 或更高版本
- ARM64 或 x64 处理器

**Windows**:
- Windows 10 版本 1809 或更高版本
- x64 处理器

## ?? 贡献

欢迎提交问题和改进建议！

## ?? 许可证

此项目仅供内部使用。

## ?? 支持

如有问题，请联系开发团队。

---

**版本**: 1.0.0  
**最后更新**: 2025-01-XX  
**开发框架**: .NET MAUI 9.0
