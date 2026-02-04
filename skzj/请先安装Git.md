# ?? 重要提示：需要先安装 Git

## 问题

运行 `github-init.bat` 时出现错误：`'git' 不是内部或外部命令`

## 原因

您的系统还没有安装 Git 或 Git 未添加到环境变量。

---

## ? 解决方案（选择其一）

### ?? 方法 1: 使用 GitHub Desktop（最简单 - 推荐新手）

**这是最简单的方法，不需要命令行！**

#### 步骤：

1. **下载 GitHub Desktop**
   - 访问：https://desktop.github.com/
   - 下载并安装

2. **登录 GitHub**
   - 打开 GitHub Desktop
   - 点击 "Sign in to GitHub.com"
   - 输入您的 GitHub 账号和密码

3. **添加本地仓库**
   - File → Add Local Repository
   - 选择文件夹：`C:\Users\14564\source\repos\skzj`
   - 点击"Add repository"

4. **发布到 GitHub**
   - 在 GitHub Desktop 中
   - Repository → Push 或 Publish Repository
   - 填写仓库名：`skzj-booking-app`
   - 选择 Private 或 Public
   - 点击"Publish repository"

5. **完成！**
   - 您的代码已上传到 GitHub
   - 仓库地址：https://github.com/Wen199512/skzj-booking-app

---

### ?? 方法 2: 安装 Git for Windows（推荐开发者）

#### 步骤 1: 下载并安装

1. 访问：https://git-scm.com/download/win
2. 下载 **Git for Windows**
3. 运行安装程序

#### 步骤 2: 安装选项（重要）

安装时选择以下选项：

- ? **Git from the command line and also from 3rd-party software**
- ? **Use Visual Studio Code as Git's default editor**
- ? **Override the default branch name for new repositories** → 输入 `main`
- ? **Git Credential Manager** （用于 GitHub 登录）
- ? 其他选项保持默认

#### 步骤 3: 验证安装

打开 **新的** 命令提示符窗口，运行：

```cmd
git --version
```

应该显示：`git version 2.x.x.windows.1`

#### 步骤 4: 配置 Git

```cmd
git config --global user.name "Wen199512"
git config --global user.email "your_email@example.com"
```

#### 步骤 5: 重新运行脚本

```cmd
cd C:\Users\14564\source\repos\skzj\skzj
fix-github-push.bat
```

---

### ??? 方法 3: 使用 Visual Studio 的 Git

如果您已安装 Visual Studio 2022：

#### 在 Visual Studio 中：

1. 打开项目
2. 菜单：**Git** → **Create Git Repository**
3. 填写信息：
   - Account: 选择或添加 GitHub 账号
   - Owner: Wen199512
   - Repository name: skzj-booking-app
   - Description: 首矿之家活动预约系统
   - Private/Public: 选择 Private
4. 点击 **Create and Push**

---

## ?? GitHub 身份验证

### 首次推送会要求登录

根据您的安装方式，会看到以下任一提示：

#### A. Git Credential Manager（推荐）

- 会弹出浏览器窗口
- 登录您的 GitHub 账号
- 授权访问
- 自动保存凭据，以后不需要再登录

#### B. 命令行提示

```
Username for 'https://github.com': Wen199512
Password for 'https://Wen199512@github.com': 
```

**注意**：密码应该使用 **个人访问令牌**，而不是您的 GitHub 密码！

**创建个人访问令牌**：
1. 访问：https://github.com/settings/tokens
2. Generate new token → classic
3. 勾选 `repo` 权限
4. 生成并复制令牌
5. 将令牌作为密码粘贴

---

## ?? 推荐流程

### 对于新手：

```
1. 下载 GitHub Desktop ?
   ↓
2. 登录 GitHub 账号 ?
   ↓
3. 添加本地仓库 ?
   ↓
4. 点击 Publish ?
   ↓
5. 完成！??
```

### 对于开发者：

```
1. 安装 Git for Windows ?
   ↓
2. 重启命令提示符 ?
   ↓
3. 配置用户信息 ?
   ↓
4. 运行 fix-github-push.bat ?
   ↓
5. 登录 GitHub（自动弹出） ?
   ↓
6. 完成！??
```

---

## ?? 仍然遇到问题？

### 问题 1: "git 不是命令"

**解决**：
1. 确认 Git 已安装
2. 重新启动命令提示符
3. 检查环境变量 PATH

### 问题 2: "403 Forbidden"

**解决**：使用个人访问令牌而不是密码

### 问题 3: "Repository not found"

**解决**：
1. 确认仓库存在：https://github.com/Wen199512/skzj-booking-app
2. 检查仓库名是否正确
3. 确认您有访问权限

---

## ?? 安装后的下一步

### 安装完成后，运行：

```cmd
cd C:\Users\14564\source\repos\skzj\skzj
fix-github-push.bat
```

这个脚本会自动：
1. ? 初始化 Git 仓库
2. ? 添加远程仓库
3. ? 提交代码
4. ? 推送到 GitHub

---

## ?? 下载链接

| 工具 | 下载链接 | 推荐 |
|------|---------|------|
| **GitHub Desktop** | https://desktop.github.com/ | ????? 最简单 |
| **Git for Windows** | https://git-scm.com/download/win | ???? 专业 |
| **GitHub CLI** | https://cli.github.com/ | ??? 高级 |

---

## ? 成功标志

推送成功后，您会看到：

```
==========================================
  推送成功！
==========================================

仓库地址: https://github.com/Wen199512/skzj-booking-app

下一步:
1. 访问仓库查看文件
2. 配置 GitHub Actions
3. 使用 github-release.bat 发布版本
```

然后访问：https://github.com/Wen199512/skzj-booking-app

应该能看到您的代码！

---

**请先安装 Git 或 GitHub Desktop，然后重新运行脚本！** ??
