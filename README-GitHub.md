# FocusGuard

[![Build Status](https://github.com/18311002500/focusguard-ios/actions/workflows/build.yml/badge.svg)](https://github.com/18311002500/focusguard-ios/actions/workflows/build.yml)

屏幕使用时间追踪 + 专注模式 iOS 应用

## 功能特性

- 📊 **屏幕时间统计** - 追踪每日应用使用情况
- 🍅 **专注模式** - 番茄钟计时，提升效率
- 🔔 **智能提醒** - 专注完成通知
- 📈 **数据统计** - 历史记录与趋势分析
- 💎 **高级功能** - 应用限制、数据导出（内购解锁）
- 🎨 **精美小组件** - 锁屏/主屏幕实时显示

## 技术栈

- SwiftUI
- SwiftData
- ScreenTime API
- StoreKit 2
- WidgetKit

## 系统要求

- iOS 16.0+
- iPhone

## 安装

### 从 App Store 安装
（审核通过后将提供链接）

### 自行构建

1. 克隆仓库
```bash
git clone https://github.com/18311002500/focusguard-ios.git
cd focusguard-ios
```

2. 打开 Xcode 项目
```bash
open FocusGuard.xcodeproj
```

3. 配置签名
- 选择你的 Team
- 修改 Bundle Identifier

4. 构建运行
- 选择目标设备
- 点击 Run

## 自动构建

本项目使用 GitHub Actions 自动构建：

- 每次推送到 `main` 分支自动构建
- 支持手动触发上传到 TestFlight

## 配置说明

### ScreenTime API
需要在 Xcode 中启用 **Family Controls** capability

### App Groups
小组件需要配置 App Group: `group.com.focusguard`

### 内购
产品 ID: `com.focusguard.premium.unlock`

## 项目结构

```
FocusGuard/
├── FocusGuardApp.swift      # 应用入口
├── Models.swift              # 数据模型
├── ContentView.swift         # 主界面
├── DashboardView.swift       # 仪表盘
├── FocusView.swift           # 专注模式
├── StoreManager.swift        # 内购管理
├── FocusGuardWidget.swift    # 小组件
└── .github/workflows/        # CI/CD
```

## 开发路线图

- [x] 基础功能
- [x] 专注模式
- [x] 内购系统
- [x] 小组件
- [x] GitHub Actions
- [ ] TestFlight 测试
- [ ] App Store 上架

## 盈利目标

- 定价: $4.99 一次性解锁
- 目标: $300 净利润
- 需销售: 86 份

## 贡献

欢迎提交 Issue 和 Pull Request

## 许可证

MIT License

## 联系

如有问题，请通过 GitHub Issues 联系

---

**注意**: 本项目仅供学习交流使用