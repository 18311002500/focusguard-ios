# GitHub 配置步骤

## 第一步：创建 GitHub 仓库

1. 登录 https://github.com
2. 点击右上角 **+** → **New repository**
3. 填写信息：
   - **Repository name**: `focusguard-ios`
   - **Description**: `FocusGuard - 屏幕时间与专注管理 iOS App`
   - **Public** / Private（建议 Public，免费）
   - 勾选 **Add a README file**
4. 点击 **Create repository**

## 第二步：上传代码

### 方法 1: 命令行
```bash
# 在本地项目目录
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/focusguard-ios.git
git push -u origin main
```

### 方法 2: 网页上传
1. 进入仓库页面
2. 点击 **Add file** → **Upload files**
3. 拖拽所有文件
4. 点击 **Commit changes**

## 第三步：注册 Apple Developer

1. 访问 https://developer.apple.com
2. 点击 **Account**
3. 使用 Apple ID 登录
4. 加入 Apple Developer Program
5. 支付 $99/年

## 第四步：创建 App ID

1. 登录 https://developer.apple.com/account/resources
2. 点击 **Identifiers** → **+**
3. 选择 **App IDs** → **App**
4. 填写：
   - **Description**: FocusGuard
   - **Bundle ID**: `com.yourcompany.focusguard`（替换 yourcompany）
5. 启用 **Family Controls** 能力
6. 点击 **Continue** → **Register**

## 第五步：创建证书

### 开发证书
1. 在 Mac 上打开 **钥匙串访问**
2. 菜单 → **证书助理** → **从证书颁发机构请求证书**
3. 填写邮箱，选择 **存储到磁盘**
4. 上传 CSR 到 Apple Developer → Certificates → +
5. 选择 **iOS App Development**
6. 下载证书并安装

### 发布证书
1. 同上步骤
2. 选择 **Apple Distribution**
3. 下载并安装

## 第六步：创建描述文件

1. Apple Developer → **Profiles** → **+**
2. 选择 **App Store**
3. 选择 App ID（FocusGuard）
4. 选择证书
5. 命名并下载

## 第七步：创建 App Store Connect API Key

1. 登录 https://appstoreconnect.apple.com
2. 点击 **用户和访问** → **密钥**
3. 点击 **+** 生成新密钥
4. 命名：GitHub Actions
5. 选择 **App Manager** 角色
6. 下载密钥（只显示一次！）
7. 记录 **Issuer ID** 和 **Key ID**

## 第八步：配置 GitHub Secrets

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**

### 需要添加的 Secrets：

#### 1. CERTIFICATES_P12
```bash
# 在 Mac 上导出证书为 .p12
# 然后 base64 编码
cat Certificates.p12 | base64 | pbcopy
```
粘贴到 Secret Value

#### 2. CERTIFICATES_PASSWORD
你的 .p12 文件密码

#### 3. APPSTORE_ISSUER_ID
从 App Store Connect 获取的 Issuer ID

#### 4. APPSTORE_API_KEY_ID
从 App Store Connect 获取的 Key ID

#### 5. APPSTORE_API_PRIVATE_KEY
下载的 .p8 文件内容

## 第九步：修改配置文件

### 修改 ExportOptions.plist
```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- 替换为你的 Team ID -->

<key>com.yourcompany.focusguard</key>
<string>FocusGuard App Store</string>  <!-- 替换为你的描述文件名称 -->
```

### 修改所有文件的 Bundle ID
将所有 `com.yourcompany.focusguard` 替换为你的 Bundle ID

## 第十步：触发构建

1. 推送代码到 GitHub
2. 进入仓库 → **Actions** 标签
3. 点击 **Build FocusGuard iOS App**
4. 点击 **Run workflow**
5. 选择分支，点击 **Run workflow**

## 第十一步：上传到 TestFlight

构建成功后：
1. 登录 https://appstoreconnect.apple.com
2. 进入 **我的 App** → FocusGuard
3. 点击 **TestFlight** 标签
4. 应该能看到自动上传的构建版本
5. 添加测试员进行测试

## 第十二步：提交审核

1. 在 App Store Connect 填写 App 信息
2. 上传截图
3. 填写描述、关键词
4. 点击 **提交审核**

---

## 常见问题

### Q: 我没有 Mac，怎么导出证书？
**A**: 借用朋友的 Mac 1-2 小时，或者使用云 Mac 服务一次性配置。

### Q: GitHub Actions 构建失败？
**A**: 检查 Secrets 配置是否正确，查看构建日志。

### Q: 如何更新 App？
**A**: 修改代码 → 推送 GitHub → Actions 自动构建 → TestFlight 自动更新。

---

**完成这些步骤后，您就可以完全通过 GitHub 管理和发布 iOS App 了！**