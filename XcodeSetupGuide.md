# Xcode 配置指南 - FocusGuard

## 1. 创建 Xcode 项目

### 步骤 1: 新建项目
1. 打开 Xcode
2. File → New → Project
3. 选择 **iOS → App**
4. 填写信息：
   - **Name**: FocusGuard
   - **Team**: 您的开发者账号
   - **Organization Identifier**: com.yourcompany (替换为您的)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData

### 步骤 2: 设置部署目标
- **iOS**: 16.0+
- **Devices**: iPhone
- **Orientation**: Portrait (竖屏)

---

## 2. 添加文件到项目

将以下文件复制到项目目录：

```
FocusGuard/
├── FocusGuardApp.swift
├── Models.swift
├── ContentView.swift
├── DashboardView.swift
├── AppUsageView.swift
├── FocusView.swift
├── StatsView.swift
├── SettingsView.swift
├── ScreenTimeManager.swift
├── DeviceActivityMonitor.swift
├── StoreManager.swift
├── PaywallView.swift
├── WidgetDataManager.swift
├── FocusGuardWidget.swift
├── TestPlan.swift
├── Theme.swift
├── Components.swift
├── Extensions.swift
└── Info.plist
```

**操作步骤：**
1. 在 Finder 中定位到项目文件夹
2. 将代码文件拖入 Xcode 的 Project Navigator
3. 确保勾选 **"Copy items if needed"**
4. 选择 **"Create groups"**

---

## 3. 配置 Capabilities

### 步骤 1: 打开 Capabilities
1. 点击项目 → Targets → FocusGuard
2. 选择 **Signing & Capabilities** 标签
3. 点击 **+ Capability**

### 步骤 2: 添加以下 Capabilities

#### 必需：
- [x] **Family Controls** 
  - 用途：访问 ScreenTime API
  
- [x] **App Groups**
  - 组名：`group.com.focusguard`
  - 用途：与小组件共享数据

#### 可选（推荐）：
- [x] **Push Notifications** - 专注完成提醒
- [x] **Background Modes** → Processing - 后台计时

---

## 4. 配置 Info.plist

打开 `Info.plist` 文件，添加以下内容：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 应用标识 -->
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.focusguard</string>
    
    <!-- ScreenTime API 权限说明 -->
    <key>NSFamilyControlsUsageDescription</key>
    <string>FocusGuard 需要访问您的屏幕使用时间数据，以帮您追踪应用使用情况和设置专注模式。</string>
    
    <!-- 通知权限 -->
    <key>UIBackgroundModes</key>
    <array>
        <string>processing</string>
    </array>
    
    <!-- 支持的方向 -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    
    <!-- 启动图 -->
    <key>UILaunchScreen</key>
    <dict>
        <key>UIImageName</key>
        <string>LaunchImage</string>
    </dict>
</dict>
</plist>
```

---

## 5. 配置 Entitlements

确保 `.entitlements` 文件包含：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Family Controls -->
    <key>com.apple.developer.family-controls</key>
    <true/>
    
    <!-- App Groups -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.focusguard</string>
    </array>
</dict>
</plist>
```

---

## 6. 添加小组件 Extension

### 步骤 1: 创建 Widget Extension
1. File → New → Target
2. 选择 **Widget Extension**
3. 命名：`FocusGuardWidget`
4. 取消勾选 **"Include Configuration Intent"**
5. 点击 **Finish**
6. 选择 **Activate**

### 步骤 2: 配置小组件
将 `FocusGuardWidget.swift` 的内容复制到新创建的 Widget 文件中。

### 步骤 3: 配置小组件的 App Group
1. 选择 Widget Target
2. Signing & Capabilities → + Capability
3. 添加 **App Groups**
4. 勾选 `group.com.focusguard`

---

## 7. 配置 Build Settings

### 步骤 1: 检查以下设置
- **Swift Language Version**: Swift 5
- **iOS Deployment Target**: 16.0
- **Enable Bitcode**: No (StoreKit 2 需要)

### 步骤 2: 框架搜索路径
确保包含：
- `$(inherited)`
- `@executable_path/Frameworks`

---

## 8. 添加图标

### 步骤 1: 准备图标
创建以下尺寸的图标：
- 20pt @2x, @3x
- 29pt @2x, @3x
- 40pt @2x, @3x
- 60pt @2x, @3x
- 1024pt (App Store)

### 步骤 2: 添加到 Assets
1. 打开 `Assets.xcassets`
2. 选择 `AppIcon`
3. 拖入对应尺寸的图标

---

## 9. 添加启动图（可选）

1. 打开 `Assets.xcassets`
2. 右键 → New Image Set
3. 命名为 `LaunchImage`
4. 添加 1x, 2x, 3x 图片

---

## 10. 验证配置

### 编译检查
1. 选择目标设备（iPhone 14 Pro）
2. 按 **Cmd+B** 编译
3. 确保无错误

### 常见错误及解决

| 错误 | 解决方案 |
|------|----------|
| `Family Controls` 未找到 | 确保 Capabilities 中已添加 |
| `App Group` 未找到 | 检查 Apple Developer 账号中是否配置了该 Group |
| StoreKit 编译错误 | 确保使用 iOS 16.0+ 和 Swift 5 |
| SwiftData 错误 | 确保 Deployment Target ≥ iOS 16.0 |

---

## 11. 下一步

配置完成后，进行：
1. **真机测试** - 在 iPhone 上运行测试
2. **沙盒测试** - 测试内购流程
3. **准备上架素材** - 截图、描述
4. **提交审核**

---

**配置完成日期**: 2025-04-01