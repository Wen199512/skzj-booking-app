# ?? GitHub 发布系统已配置完成！

## ? 已创建的文件

### ?? 文档

1. **GitHub发布指南.md** - 完整的 GitHub 发布教程
2. **发布检查清单.md** - 发布前检查事项
3. **README.md** - 项目说明文档

### ?? 脚本

1. **github-init.bat** - 初始化 Git 仓库
2. **github-release.bat** - 快速发布新版本

### ?? 配置文件

1. **.gitignore** - Git 忽略文件配置
2. **.github/workflows/build-and-release.yml** - 自动构建工作流

### ?? 代码

1. **Services/UpdateService.cs** - 应用内更新检测服务

---

## ?? 快速开始

### 第一次使用（初始化）

```cmd
# 1. 运行初始化脚本
github-init.bat

# 2. 在 GitHub 创建仓库
# 访问: https://github.com/new

# 3. 按照脚本提示完成配置
```

### 发布新版本

```cmd
# 运行发布脚本
github-release.bat

# 按照提示输入:
# - 新版本号 (如 1.0.1)
# - 更新说明
# - 确认发布
```

### 自动流程

推送版本标签后，GitHub Actions 会自动：
1. ? 构建 Android APK
2. ? 创建 GitHub Release
3. ? 上传 APK 文件
4. ? 生成下载链接

---

## ?? 用户更新流程

### 方法 1: 应用内更新（需要实现）

1. 打开应用
2. 应用自动检测新版本
3. 显示更新提示
4. 点击更新下载 APK
5. 安装新版本

### 方法 2: GitHub 手动下载

1. 访问 Releases 页面
2. 下载最新 APK
3. 安装

---

## ?? 配置说明

### 需要修改的地方

#### 1. UpdateService.cs

找到并修改 GitHub API URL：

```csharp
// 第 12 行
private const string GitHubApiUrl = "https://api.github.com/repos/YOUR_USERNAME/skzj-booking-app/releases/latest";

// 替换为您的实际仓库地址
private const string GitHubApiUrl = "https://api.github.com/repos/yourusername/your-repo/releases/latest";
```

#### 2. github-release.bat

找到并修改仓库地址提示：

```batch
# 第 88 行和第 94 行
echo https://github.com/YOUR_USERNAME/skzj-booking-app/actions
echo https://github.com/YOUR_USERNAME/skzj-booking-app/releases

# 替换为您的实际仓库地址
```

#### 3. README.md

修改所有仓库链接为您的实际地址。

---

## ?? 使用示例

### 场景 1: 首次发布

```cmd
# 1. 初始化 Git
github-init.bat

# 2. 发布 v1.0.0
github-release.bat
输入版本号: 1.0.0
输入更新说明: 首次发布
输入 END 结束
确认发布? y

# 3. 等待 GitHub Actions 完成构建
# 4. 在 Releases 页面查看并下载
```

### 场景 2: 发布更新

```cmd
# 1. 修改代码
# 2. 测试功能
# 3. 发布新版本

github-release.bat
输入版本号: 1.0.1
输入更新说明: 修复登录Bug
输入 END 结束
确认发布? y

# 自动完成发布
```

### 场景 3: 紧急修复

```cmd
# 1. 创建 hotfix 分支
git checkout -b hotfix/1.0.2

# 2. 修复问题
# 3. 快速发布

github-release.bat
输入版本号: 1.0.2
输入更新说明: 紧急修复验证码问题
```

---

## ?? 功能特性

### 已实现

- ? Git 仓库管理
- ? 自动构建 APK
- ? 自动创建 Release
- ? 版本标签管理
- ? 更新检测 API
- ? 快捷发布脚本

### 可选实现

- ? 应用内更新下载
- ? 更新进度显示
- ? 强制更新机制
- ? 更新日志展示

---

## ?? 完整工作流程

```
开发新功能
    ↓
本地测试
    ↓
更新版本号
    ↓
运行 github-release.bat
    ↓
推送代码和标签到 GitHub
    ↓
GitHub Actions 自动构建
    ↓
创建 Release 并上传 APK
    ↓
用户收到更新提示
    ↓
下载并安装新版本
```

---

## ?? 注意事项

### 敏感文件

如果 `zh.txt` 包含真实账号信息：

1. 添加到 .gitignore：
   ```
   zh.txt
   ```

2. 使用其他方式分发账号文件

3. 或使用加密存储

### GitHub Token

- GitHub Actions 使用内置 `GITHUB_TOKEN`
- 无需额外配置
- 自动拥有 Release 权限

### 构建时间

- Windows runner 构建约需 5-10 分钟
- 请耐心等待构建完成

---

## ?? 常见问题

### Q1: 如何查看构建进度？

访问: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`

### Q2: 构建失败怎么办？

1. 查看 Actions 日志
2. 检查错误信息
3. 修复问题后重新推送标签

### Q3: 如何删除错误的 Release？

1. 访问 Releases 页面
2. 点击 Release 右侧的编辑
3. 点击删除
4. 删除对应的 Git 标签

### Q4: 如何实现应用内更新？

查看 `GitHub发布指南.md` 中的"应用内更新检测"章节。

---

## ?? 获取帮助

- ?? 查看 `GitHub发布指南.md` 获取详细教程
- ? 查看 `发布检查清单.md` 确保发布正确
- ?? 查看 GitHub Actions 日志排查问题

---

## ?? 下一步

1. ? 运行 `github-init.bat` 初始化仓库
2. ? 修改配置中的仓库地址
3. ? 测试发布流程
4. ? 实现应用内更新（可选）

---

**一切就绪！现在您可以通过 GitHub 轻松管理应用发布了！** ??

如有问题，请参考相关文档或查看 GitHub Actions 日志。
