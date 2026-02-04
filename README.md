# 首矿之家活动预约系统

.NET MAUI Android 应用，用于首矿之家活动预约。

## ?? 功能特性

- ? 验证码登录验证
- ? 活动列表查询
- ? 多活动同时预约（最多3个）
- ? 高性能多线程抢票（20线程/账号）
- ? 自动更新检测
- ? zh.txt 账号文件内嵌

## ?? 系统要求

- Android 5.0 (API 21) 或更高版本
- ARM64 架构

## ?? 下载安装

### 方法 1: GitHub Releases（推荐）

1. 访问 [Releases](https://github.com/YOUR_USERNAME/skzj-booking-app/releases) 页面
2. 下载最新版本的 APK 文件
3. 在 Android 设备上安装

### 方法 2: 直接下载

点击下载最新版本: [com.skzj.booking-Signed.apk](https://github.com/YOUR_USERNAME/skzj-booking-app/releases/latest)

## ?? 登录说明

登录需要两个信息：
1. **姓名** - 您的真实姓名
2. **验证码** - 账号文件中的4位数字

## ?? 使用方法

1. 安装并打开应用
2. 输入姓名和验证码登录
3. 点击"查询活动列表"
4. 点击选择活动（最多3个）
5. 点击"开始预约"

## ??? 开发说明

### 技术栈

- .NET 9
- .NET MAUI
- C# 13.0

### 构建项目

```bash
# 恢复依赖
dotnet restore

# 构建 Android APK
dotnet publish -f net9.0-android -c Release -p:RuntimeIdentifier=android-arm64 -p:AndroidPackageFormat=apk
```

或使用快速构建脚本：

```cmd
clean-build-publish.bat
```

### 发布新版本

使用快速发布脚本：

```cmd
github-release.bat
```

或手动发布：

```bash
# 1. 更新版本号 (编辑 skzj.csproj)
# 2. 提交代码
git add .
git commit -m "release: v1.0.1"

# 3. 创建标签
git tag -a v1.0.1 -m "Release v1.0.1"

# 4. 推送
git push origin main --tags
```

## ?? 项目结构

```
skzj/
├── Services/           # 服务层
│   ├── BookingService.cs      # 预约服务
│   └── UpdateService.cs       # 更新检测服务
├── Models/            # 数据模型
│   ├── Account.cs
│   ├── ActivityInfo.cs
│   └── ...
├── Helpers/           # 辅助工具
│   └── EmbeddedResourceHelper.cs
├── LoginPage.xaml     # 登录页面
├── MainPage.xaml      # 主页面
└── zh.txt            # 账号文件（嵌入式资源）
```

## ?? 更新日志

### v1.0.0 (2025-01-XX)

- ? 首次发布
- ? 验证码登录
- ? 活动预约功能
- ? 多线程优化

## ?? 许可证

内部使用

## ?? 技术支持

如有问题，请联系管理员。

---

**开发**: 首矿之家技术团队
