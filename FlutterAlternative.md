# FocusGuard Flutter 版本方案

## 为什么考虑 Flutter？

| 优势 | 说明 |
|------|------|
| **跨平台** | 一套代码 → iOS + Android |
| **无需 Mac** | Windows/Linux 即可开发 |
| **热重载** | 开发效率高 |
| **原生性能** | 接近原生体验 |
| **未来扩展** | 可添加 Web、Desktop |

## 技术栈对比

| 功能 | SwiftUI (原方案) | Flutter (新方案) |
|------|------------------|------------------|
| UI 框架 | SwiftUI | Flutter Widgets |
| 状态管理 | SwiftData | Hive / SQLite |
| 屏幕时间 | ScreenTime API | Usage Stats (Android) + 手动记录 |
| 内购 | StoreKit | in_app_purchase 插件 |
| 小组件 | WidgetKit | home_widget 插件 |

## ⚠️ 关键差异

### ScreenTime API 问题
Flutter **无法直接访问 iOS ScreenTime API**（需要原生代码）。

### 解决方案
1. **Android 优先** - 先用 Flutter 开发 Android 版本
2. **手动记录** - 用户手动输入专注时间
3. **混合开发** - Flutter UI + 原生 ScreenTime 模块

## 推荐方案：Android 优先

### 第一阶段：Flutter Android 版本
- 开发周期：2-3 周
- 成本：$25 Google Play 费用
- 验证市场：Android 用户反馈

### 第二阶段：添加 iOS 支持
- 借用/租用 Mac 1-2 天
- 添加原生 ScreenTime 模块
- 提交 App Store

## 盈利对比

| 平台 | 费用 | 净收入/份 | 需销售 |
|------|------|-----------|--------|
| iOS | $99/年 | $3.49 | 86 份 |
| Android | $25 一次性 | $3.49 | 93 份 |
| 双平台 | $124 | $6.98 | 44 份/平台 |

## 我的建议

宝总，考虑到您没有 Mac，我建议：

### 方案 A: 坚持 iOS（推荐）
- 借用朋友 Mac 2-3 天
- 完成配置和测试
- 使用 MacinCloud $25/月维护
- **优点**: 原方案完整，ScreenTime API 功能完整

### 方案 B: 转 Android
- 用 Flutter 开发 Android 版本
- Windows/Linux 即可开发
- 验证市场后再考虑 iOS
- **优点**: 无需 Mac，快速启动

### 方案 C: 混合方案
- 现在借用 Mac 完成 iOS 版本
- 同时准备 Flutter 版本作为备份
- 双平台发布
- **优点**: 风险分散，收益最大化

---

宝总，您希望：
1. **坚持原 iOS 方案** - 我帮您准备借用 Mac 的清单
2. **转 Flutter Android** - 我开始准备 Flutter 版本架构
3. **双平台并行** - 同时准备两个版本