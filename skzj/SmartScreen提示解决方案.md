# ?? Windows SmartScreen 提示解决方案

## 问题说明

下载 GitHub Desktop 时出现 Windows Defender SmartScreen 提示：

```
Windows 已保护你的电脑
Windows Defender SmartScreen 已阻止启动一个未识别的应用。
运行此应用可能会导致你的电脑存在风险。
```

## ? 这是正常的！

**不要担心！** 这个提示很常见，原因是：

1. **新下载的程序** - Windows 不认识这个文件
2. **安全检查** - Windows 在保护您的电脑
3. **GitHub Desktop 是安全的** - 这是 GitHub 官方应用

---

## ?? 如何运行 GitHub Desktop

### 方法 1: 点击"更多信息"（推荐）

1. 看到 SmartScreen 提示时
2. 点击 **"更多信息"** 链接
3. 会出现一个 **"仍要运行"** 按钮
4. 点击 **"仍要运行"**
5. GitHub Desktop 开始安装

**示意图：**
```
┌─────────────────────────────────────┐
│ Windows 已保护你的电脑              │
│                                     │
│ Windows Defender SmartScreen        │
│ 已阻止启动一个未识别的应用...        │
│                                     │
│ [更多信息]  ?? 点击这里               │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 应用名称: GitHubDesktopSetup.exe    │
│ 发布者: GitHub, Inc.                │
│                                     │
│ [仍要运行]  ?? 再点击这里             │
│ [不运行]                            │
└─────────────────────────────────────┘
```

---

### 方法 2: 通过属性解除阻止

如果方法 1 不工作，尝试这个：

#### 步骤：

1. **找到下载的文件**
   - 通常在：`C:\Users\14564\Downloads\GitHubDesktopSetup.exe`

2. **右键点击文件**
   - 选择 **"属性"**

3. **在属性窗口中**
   - 找到底部的 **"安全"** 部分
   - 勾选 **"解除阻止"** 复选框
   - 点击 **"确定"**

4. **双击运行文件**
   - 现在应该可以正常安装了

---

### 方法 3: 临时禁用 SmartScreen（不推荐）

**警告**：这会降低安全性，仅在必要时使用！

#### 步骤：

1. 按 `Win + I` 打开设置
2. 进入 **"隐私和安全性"** → **"Windows 安全中心"**
3. 点击 **"应用和浏览器控制"**
4. 在 **"基于信誉的保护"** 下
5. 点击 **"基于信誉的保护设置"**
6. 找到 **"对应用和文件的检查"**
7. 临时关闭（选择 **"关闭"**）
8. 安装 GitHub Desktop
9. **安装完成后立即重新打开保护！**

---

## ?? 推荐安装流程

### 完整步骤：

```
1. 下载 GitHub Desktop
   ↓
2. 看到 SmartScreen 提示
   ↓
3. 点击"更多信息"
   ↓
4. 点击"仍要运行"
   ↓
5. 安装程序启动
   ↓
6. 完成安装
   ↓
7. 登录 GitHub 账号
   ↓
8. 开始使用！
```

---

## ?? GitHub Desktop 安装向导

安装时的选项：

### 1. 欢迎界面
- 点击 **"Install"** 或 **"安装"**

### 2. 安装位置
- 通常使用默认位置
- `C:\Users\14564\AppData\Local\GitHubDesktop\`

### 3. 登录 GitHub
- 选择 **"Sign in to GitHub.com"**
- 输入您的 GitHub 账号和密码
- 可能需要验证码

### 4. 配置 Git
- 会自动配置 Git
- 使用您的 GitHub 信息

---

## ? 安装成功标志

安装完成后，您会看到：

1. **GitHub Desktop 主界面**
2. **"Let's get started!"** 或类似欢迎信息
3. 可以选择 **"Clone a repository"** 或 **"Create a new repository"**

---

## ?? 安装后的下一步

### 添加您的项目到 GitHub

#### 方法 1: 通过 GitHub Desktop

1. **打开 GitHub Desktop**
2. **File** → **Add Local Repository**
3. **选择文件夹**：
   ```
   C:\Users\14564\source\repos\skzj
   ```
4. 如果提示 "This directory does not appear to be a Git repository"
5. 点击 **"create a repository"**
6. 填写信息：
   - Name: `skzj-booking-app`
   - Description: `首矿之家活动预约系统`
   - Local path: 已选择
7. 点击 **"Create Repository"**

#### 方法 2: 发布到 GitHub

1. 在 GitHub Desktop 中
2. 点击顶部的 **"Publish repository"** 按钮
3. 填写信息：
   - Name: `skzj-booking-app`
   - Description: `首矿之家活动预约系统`
   - Keep this code private: ? 勾选（推荐）
4. 点击 **"Publish Repository"**

---

## ?? 常见问题

### Q1: 点击"更多信息"没有反应？

**解决**：
1. 等待几秒钟
2. 或者使用方法 2（通过属性解除阻止）

### Q2: 安装时提示需要管理员权限？

**解决**：
1. 右键点击安装程序
2. 选择 **"以管理员身份运行"**

### Q3: 安装后找不到程序？

**位置**：
- 开始菜单搜索 "GitHub Desktop"
- 或者：`C:\Users\14564\AppData\Local\GitHubDesktop\GitHubDesktop.exe`

### Q4: GitHub Desktop 和 Git 有什么区别？

| 特性 | GitHub Desktop | Git for Windows |
|------|----------------|-----------------|
| **界面** | 图形界面 | 命令行 |
| **难度** | 简单 | 需要学习命令 |
| **功能** | GitHub 集成 | 完整的 Git |
| **推荐** | ? 新手 | 开发者 |

---

## ?? 为什么选择 GitHub Desktop？

### 优势

1. ? **简单易用** - 图形界面，无需命令
2. ? **自动配置** - 自动设置 Git
3. ? **GitHub 集成** - 直接连接 GitHub
4. ? **可视化** - 清楚看到更改
5. ? **一键操作** - Commit、Push、Pull 都是一键

### 适合您的场景

对于首矿之家预约系统，GitHub Desktop 是最佳选择：

```
开发代码
   ↓
GitHub Desktop 自动检测更改
   ↓
输入提交信息
   ↓
点击"Commit"
   ↓
点击"Push origin"
   ↓
代码上传到 GitHub！
```

---

## ?? 安装后的验证

安装完成后，验证是否成功：

### 1. 打开 GitHub Desktop

### 2. 检查菜单栏
- File
- Edit
- View
- Repository
- Branch
- Help

### 3. 尝试登录
- File → Options → Accounts
- 应该能看到您的 GitHub 账号

### 4. 测试克隆
- File → Clone Repository
- 应该能看到您的 GitHub 仓库列表（如果有的话）

---

## ?? 安装完成清单

安装并配置 GitHub Desktop 后：

- [ ] GitHub Desktop 已安装
- [ ] 已登录 GitHub 账号
- [ ] 添加了本地仓库 `skzj`
- [ ] 发布到 GitHub（创建远程仓库）
- [ ] 能看到文件更改
- [ ] 能提交（Commit）
- [ ] 能推送（Push）

---

## ?? 下一步操作

安装 GitHub Desktop 后：

1. ? **添加本地仓库**
   ```
   File → Add Local Repository
   选择: C:\Users\14564\source\repos\skzj
   ```

2. ? **发布到 GitHub**
   ```
   点击: Publish repository
   设置为 Private
   ```

3. ? **提交当前更改**
   ```
   查看更改列表
   输入提交信息
   点击: Commit to main
   ```

4. ? **推送到 GitHub**
   ```
   点击: Push origin
   ```

5. ? **验证上传**
   ```
   访问: https://github.com/Wen199512/skzj-booking-app
   应该能看到您的代码！
   ```

---

## ?? 有用链接

- **GitHub Desktop 下载**: https://desktop.github.com/
- **GitHub Desktop 文档**: https://docs.github.com/desktop
- **视频教程**: https://www.youtube.com/results?search_query=github+desktop+tutorial

---

**SmartScreen 提示是正常的安全检查，点击"更多信息"→"仍要运行"即可！** ??

安装后您就能用图形界面轻松管理代码了！
