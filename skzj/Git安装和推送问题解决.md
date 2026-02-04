# ?? GitHub 推送问题解决方案

## 问题诊断

您遇到的错误：`'git' 不是内部或外部命令`

**原因**：Git 未安装或未添加到 PATH 环境变量

---

## ? 解决方案

### 方法 1: 安装 Git（推荐）

#### 步骤 1: 下载 Git

访问：https://git-scm.com/download/win

下载并安装 **Git for Windows**

#### 步骤 2: 安装选项

安装时选择：
- ? **Git from the command line and also from 3rd-party software**
- ? **Use Visual Studio Code as Git's default editor**（如果使用 VS Code）
- ? **Override the default branch name** → `main`
- ? **Git Credential Manager** （推荐）

#### 步骤 3: 验证安装

重新打开命令提示符或 PowerShell，运行：

```cmd
git --version
```

应该看到类似：`git version 2.43.0.windows.1`

---

### 方法 2: 使用 Visual Studio 的 Git

如果您已安装 Visual Studio，可以使用内置的 Git：

#### 步骤 1: 找到 Git 路径

默认路径通常是：
```
C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\
```

#### 步骤 2: 添加到 PATH

1. 按 `Win + X`，选择"系统"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到 `Path`
5. 点击"编辑"
6. 点击"新建"
7. 添加 Git 路径
8. 点击"确定"保存

#### 步骤 3: 重启命令提示符

关闭所有命令提示符窗口，重新打开

---

### 方法 3: 使用 Visual Studio Git 界面

#### 在 Visual Studio 中使用 Git

1. 打开 Visual Studio
2. 菜单：**Git** → **Create Git Repository**
3. 填写信息：
   - Repository location: `C:\Users\14564\source\repos\skzj`
   - Remote: `https://github.com/Wen199512/skzj-booking-app.git`
4. 点击"Create and Push"

#### 使用 Team Explorer

1. 打开 Visual Studio
2. 视图 → Team Explorer
3. 点击"连接"图标
4. 选择"克隆"或"同步"
5. 输入仓库 URL
6. 推送代码

---

## ?? GitHub 身份验证

### 方法 1: GitHub Desktop（最简单）

1. 下载 GitHub Desktop：https://desktop.github.com/
2. 登录您的 GitHub 账号
3. 选择您的仓库
4. 使用图形界面推送代码

### 方法 2: 个人访问令牌（Personal Access Token）

#### 步骤 1: 创建令牌

1. 访问：https://github.com/settings/tokens
2. 点击"Generate new token" → "Generate new token (classic)"
3. 填写信息：
   - Note: `skzj-booking-app`
   - Expiration: 选择有效期
   - 勾选权限：
     - ? `repo` (完整仓库访问)
     - ? `workflow` (GitHub Actions)
4. 点击"Generate token"
5. **复制令牌**（只显示一次！）

#### 步骤 2: 使用令牌

推送时，用户名使用您的 GitHub 用户名，密码使用令牌：

```cmd
git push -u origin main

Username: Wen199512
Password: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 方法 3: SSH 密钥

#### 步骤 1: 生成 SSH 密钥

```cmd
ssh-keygen -t ed25519 -C "your_email@example.com"
```

按 Enter 使用默认位置，设置密码（可选）

#### 步骤 2: 添加到 GitHub

1. 复制公钥：
   ```cmd
   type %USERPROFILE%\.ssh\id_ed25519.pub
   ```

2. 访问：https://github.com/settings/keys

3. 点击"New SSH key"

4. 粘贴公钥，保存

#### 步骤 3: 修改远程 URL

```cmd
git remote set-url origin git@github.com:Wen199512/skzj-booking-app.git
```

#### 步骤 4: 测试连接

```cmd
ssh -T git@github.com
```

应该看到：`Hi Wen199512! You've successfully authenticated`

---

## ?? 完整推送流程

### 安装 Git 后

```cmd
# 1. 验证 Git 安装
git --version

# 2. 配置用户信息
git config --global user.name "Wen199512"
git config --global user.email "your_email@example.com"

# 3. 初始化仓库（如果还没有）
cd C:\Users\14564\source\repos\skzj
git init
git branch -M main

# 4. 添加远程仓库
git remote add origin https://github.com/Wen199512/skzj-booking-app.git

# 5. 添加文件
git add .

# 6. 提交
git commit -m "Initial commit: 首矿之家活动预约系统"

# 7. 推送到 GitHub
git push -u origin main
```

### 首次推送会提示登录

使用以下任一方式：
- GitHub Desktop 自动处理
- Git Credential Manager（安装 Git 时自带）
- 个人访问令牌
- SSH 密钥

---

## ?? 常见问题

### Q1: 推送时提示"403 Forbidden"

**原因**: 身份验证失败

**解决**: 使用个人访问令牌或 SSH 密钥

### Q2: 推送时提示"Repository not found"

**原因**: 
- 仓库不存在
- 仓库名错误
- 没有访问权限

**解决**: 
1. 检查仓库 URL
2. 确认仓库已创建
3. 检查权限设置

### Q3: 推送时提示"non-fast-forward"

**原因**: 远程仓库有本地没有的提交

**解决**:
```cmd
# 拉取远程更改
git pull origin main --rebase

# 再次推送
git push origin main
```

---

## ?? 推荐流程

### 对于初学者（最简单）

1. **安装 GitHub Desktop**
   - 下载：https://desktop.github.com/
   - 图形界面，简单易用
   - 自动处理身份验证

2. **在 GitHub Desktop 中**
   - File → Add Local Repository
   - 选择 `C:\Users\14564\source\repos\skzj`
   - 输入提交信息
   - 点击"Publish repository"

### 对于开发者（推荐）

1. **安装 Git for Windows**
2. **配置 Git Credential Manager**
3. **使用命令行或 VS Code 集成 Git**
4. **使用 `fix-github-push.bat` 脚本**

---

## ?? 快速检查清单

安装 Git 后，运行：

```cmd
# 检查 Git
git --version

# 检查配置
git config --list

# 检查远程仓库
git remote -v

# 检查状态
git status
```

全部正常后，运行：

```cmd
fix-github-push.bat
```

---

## ?? 有用的链接

- **Git 下载**: https://git-scm.com/download/win
- **GitHub Desktop**: https://desktop.github.com/
- **GitHub CLI**: https://cli.github.com/
- **GitHub 文档**: https://docs.github.com/zh
- **个人令牌**: https://github.com/settings/tokens
- **SSH 密钥**: https://github.com/settings/keys

---

**安装 Git 后，重新运行 `fix-github-push.bat` 即可！** ??
