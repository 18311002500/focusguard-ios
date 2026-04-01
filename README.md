//
//  README.md
//  FocusGuard
//

# FocusGuard

## 项目概述
屏幕使用时间追踪 + 专注模式应用

## 核心功能
- 屏幕使用时间统计（通过 ScreenTime API）
- 应用使用排行
- 专注模式（番茄钟）
- 应用使用限制（付费解锁）
- 数据统计与导出（付费解锁）

## 技术栈
- SwiftUI
- SwiftData
- ScreenTime API (FamilyControls, DeviceActivity, ManagedSettings)
- StoreKit 2
- WidgetKit

## 开发里程碑
- [x] M1: 项目初始化 + Core Data 模型
- [x] M2: ScreenTime API 集成
- [x] M3: UI 界面完善
- [x] M4: 专注模式功能
- [x] M5: StoreKit 内购集成
- [x] M6: 小组件开发
- [x] M7: 测试 + 审核准备
- [x] M8: Xcode 配置 ✅

## 项目状态
**🎉 所有开发工作已完成！等待真机测试。**

## 盈利目标
- 定价: $4.99 一次性解锁
- 目标: 300 美元净利润
- 需销售: 86 份
- 净收入/份: $3.49 (扣除 Apple 30% 分成)

## ⚠️ ScreenTime API 配置说明

### 1. Xcode 配置
在 Xcode 中需要添加以下 Capability：
- **Family Controls** (必需)
- **App Groups** (推荐，用于数据共享)

### 2. Info.plist
添加权限声明：
```xml
<key>NSFamilyControlsUsageDescription</key>
<string>FocusGuard 需要访问您的屏幕使用时间数据，以帮您追踪应用使用情况和设置专注模式。</string>
```

### 3. Entitlements
```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

### 4. Device Activity Extension (可选)
如需实时监控应用使用情况，需要添加 Device Activity Extension target。

### 5. App Store Connect 配置
- 创建 App 内购买项目
- 产品 ID: `com.focusguard.premium.unlock`
- 类型: 非消耗型
- 价格: $4.99

## 注意事项
- ScreenTime API 仅在真机上可用，模拟器无法获取真实数据
- 需要 iOS 16.0+
- 用户必须在设置中授予屏幕时间权限
- 小组件需要配置 App Groups: `group.com.focusguard`

## 文件结构
```
FocusGuard/
├── FocusGuardApp.swift           # 应用入口
├── Models.swift                   # 数据模型
├── ContentView.swift              # 主界面
├── DashboardView.swift            # 概览页
├── AppUsageView.swift             # 应用排行页
├── FocusView.swift                # 专注模式页（含历史记录）
├── StatsView.swift                # 统计分析页
├── SettingsView.swift             # 设置页
├── ScreenTimeManager.swift        # 屏幕时间管理器
├── DeviceActivityMonitor.swift    # 设备活动监控
├── StoreManager.swift             # StoreKit 内购管理
├── PaywallView.swift              # 购买页面
├── WidgetDataManager.swift        # 小组件数据管理
├── FocusGuardWidget.swift         # 小组件实现
├── TestPlan.swift                 # 测试计划
├── Theme.swift                    # 全局主题配置
├── Components.swift               # 可复用 UI 组件
├── Extensions.swift               # Swift 扩展
├── Info.plist.swift               # 配置文件说明
├── README.md                      # 项目说明
└── AppStoreChecklist.md           # 上架检查清单
```

## 主题系统
使用 `AppTheme` 统一管理：
- 颜色 (primaryColor, secondaryColor, accentColor)
- 渐变 (primaryGradient, focusGradient)
- 字体大小 (FontSize)
- 间距 (Spacing)
- 圆角 (CornerRadius)

## 组件库
- `CircularProgressView` - 环形进度条
- `StatCardView` - 统计卡片
- `AppIconView` - 应用图标
- `EmptyStateView` - 空状态视图
- `LoadingView` - 加载视图
- `SegmentedControl` - 分段控制器
- `ToggleRow` - 开关行
- `NavigationRow` - 导航行
- `PrimaryButton` - 主按钮

## 扩展
- `TimeInterval` - 时间格式化
- `Date` - 日期工具
- `Color` - 十六进制颜色
- `View` - 视图工具
- `Double` - 百分比格式化
- `Array` - 安全访问

## 下一步行动
1. 配置 Xcode 项目 Capabilities
2. 在 App Store Connect 创建 App 和内购项目
3. 使用真机测试 ScreenTime API
4. 使用沙盒测试员测试购买流程
5. 准备截图和元数据
6. 提交审核

---
**项目完成日期:** 2025-04-01  
**开发者:** Crabator (创虾)
