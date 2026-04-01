# GitHub 解决方案 - FocusGuard

## 方案概览

使用 GitHub 的 **免费资源** + **自动化** 来完成 iOS 开发和上架。

## 方案 1: GitHub Actions + Mac 运行器（推荐）

### 原理
GitHub Actions 提供 **macOS 运行器**，可以运行 Xcode！

### 成本
- **免费额度**: 2000 分钟/月
- **额外**: $0.08/分钟（macOS 运行器）
- **预估**: 每次构建 10-20 分钟，约 $1-2/次

### 步骤

#### 1. 创建 GitHub 仓库
```bash
# 在 GitHub 上创建仓库: focusguard-ios
# 上传所有代码
```

#### 2. 配置 GitHub Actions
创建 `.github/workflows/build.yml`:

```yaml
name: Build and Upload to App Store

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-14  # GitHub 提供的 Mac 运行器
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    
    - name: Build App
      run: |
        xcodebuild -project FocusGuard.xcodeproj \
                   -scheme FocusGuard \
                   -destination 'platform=iOS Simulator,name=iPhone 15' \
                   build
    
    - name: Run Tests
      run: |
        xcodebuild test -project FocusGuard.xcodeproj \
                        -scheme FocusGuard \
                        -destination 'platform=iOS Simulator,name=iPhone 15'
```

#### 3. 配置自动上传到 App Store
```yaml
    - name: Install certificates
      uses: apple-actions/import-codesign-certs@v2
      with:
        p12-file-base64: ${{ secrets.CERTIFICATES_P12 }}
        p12-password: ${{ secrets.CERTIFICATES_PASSWORD }}
    
    - name: Build and Archive
      run: |
        xcodebuild -project FocusGuard.xcodeproj \
                   -scheme FocusGuard \
                   -archivePath FocusGuard.xcarchive \
                   archive
    
    - name: Export IPA
      run: |
        xcodebuild -exportArchive \
                   -archivePath FocusGuard.xcarchive \
                   -exportPath ./build \
                   -exportOptionsPlist ExportOptions.plist
    
    - name: Upload to App Store
      uses: apple-actions/upload-testflight-build@v1
      with:
        app-path: ./build/FocusGuard.ipa
        issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
        api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
        api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

---

## 方案 2: GitHub Codespaces + 远程 Mac

### 原理
使用 Codespaces 编辑代码，连接到云 Mac 进行构建。

### 配置
1. 开启 GitHub Codespaces
2. 在 Codespaces 中编辑代码
3. 通过 SSH 连接到云 Mac 或 GitHub Actions 进行构建

---

## 方案 3: GitHub + 社区协作

### 原理
将项目开源，吸引社区贡献者帮助开发和测试。

### 步骤
1. **开源项目** - MIT 许可证
2. **创建 Issues** - 标记 "help wanted"
3. **寻找贡献者** - 有 Mac 的开发者帮助测试
4. **收益分享** - 承诺收益分成

### 优势
- 免费获得 Mac 用户测试
- 社区贡献代码
- 提前获得用户反馈

---

## 方案 4: GitHub + Expo / React Native

### 原理
使用 Expo 的 EAS Build 服务，在云端构建 iOS App。

### 成本
- EAS Build: $0.05/分钟
- iOS 构建约 15-20 分钟
- 每次构建约 $1

### 步骤
1. 将 SwiftUI 代码转为 React Native（或保持 SwiftUI 用 Expo）
2. 配置 `eas.json`
3. 运行 `eas build --platform ios`
4. Expo 自动构建并上传到 App Store

---

## 推荐方案: GitHub Actions + macOS 运行器

### 为什么推荐？
- ✅ 完全自动化
- ✅ 无需本地 Mac
- ✅ 每次提交自动构建
- ✅ 可以自动上传到 TestFlight
- ✅ 成本可控（$1-2/次构建）

### 需要的准备

#### 1. Apple Developer 账号 ($99/年)
- 必需
- 用于签名和上架

#### 2. 配置文件
- 证书 (Certificates)
- 描述文件 (Provisioning Profiles)
- App Store Connect API Key

#### 3. GitHub Secrets
在仓库 Settings → Secrets 中添加：
- `CERTIFICATES_P12` - Base64 编码的证书
- `CERTIFICATES_PASSWORD` - 证书密码
- `APPSTORE_ISSUER_ID` - App Store Connect Issuer ID
- `APPSTORE_API_KEY_ID` - API Key ID
- `APPSTORE_API_PRIVATE_KEY` - API 私钥

---

## 实施步骤

### 第一步：创建 GitHub 仓库
```bash
# 1. 在 GitHub 创建仓库
# 2. 上传所有代码
# 3. 添加 README 和 LICENSE
```

### 第二步：配置 Apple Developer
```bash
# 1. 登录 Apple Developer
# 2. 创建 App ID: com.yourcompany.focusguard
# 3. 创建证书和描述文件
# 4. 创建 App Store Connect API Key
```

### 第三步：配置 GitHub Actions
```bash
# 1. 创建 .github/workflows/build.yml
# 2. 配置 Secrets
# 3. 推送代码触发构建
```

### 第四步：自动上架
```bash
# 1. 构建成功自动上传到 TestFlight
# 2. 在 App Store Connect 提交审核
# 3. 审核通过后自动发布
```

---

## 成本计算

| 项目 | 成本 |
|------|------|
| Apple Developer | $99/年 |
| GitHub Actions | ~$10-20/月（按使用） |
| **总计** | **~$120-140/年** |

对比购买 Mac mini ($699)：
- GitHub 方案：1年回本
- 无需维护硬件
- 随时随地构建

---

## 风险与解决

| 风险 | 解决 |
|------|------|
| GitHub Actions 排队 | 使用付费运行器，优先执行 |
| 证书过期 | 设置提醒，自动续期 |
| 构建失败 | 本地模拟器测试后再推送 |
| 无法调试 | 使用日志和 TestFlight 测试 |

---

## 下一步

宝总，如果您选择 GitHub 方案，我需要：

1. **创建 GitHub 仓库** - 您创建，我上传代码
2. **配置 GitHub Actions** - 我编写工作流文件
3. **准备 Apple Developer** - 您注册，我指导配置
4. **测试构建** - 第一次构建验证

**您现在可以做的：**
- [ ] 注册 GitHub 账号（如果还没有）
- [ ] 创建 focusguard-ios 仓库
- [ ] 注册 Apple Developer ($99)

**我立即准备的：**
- GitHub Actions 工作流文件
- 自动化构建脚本
- 详细的配置指南

---

宝总，确定用 GitHub 方案吗？我立即开始准备工作流文件！