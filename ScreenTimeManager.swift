//
//  ScreenTimeManager.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import Foundation
import SwiftData

// ScreenTime API 只在真机上可用
#if !targetEnvironment(simulator)
import FamilyControls
import DeviceActivity
import ManagedSettings
#endif

/// ScreenTimeManager - 屏幕时间管理器
/// 负责读取设备屏幕使用数据并同步到本地数据库
/// ⚠️ 需要 Family Controls entitlement 和屏幕时间权限
@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @Published var isAuthorized = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if !targetEnvironment(simulator)
    private let center = DeviceActivityCenter()
    #endif
    private var context: ModelContext?
    
    private init() {}
    
    /// 设置 ModelContext
    func setupContext(_ context: ModelContext) {
        self.context = context
    }
    
    // MARK: - 权限申请
    
    /// 申请屏幕时间权限
    /// 这是使用 ScreenTime API 的第一步
    func requestAuthorization() async {
        #if targetEnvironment(simulator)
        // 模拟器上自动授权
        await MainActor.run {
            self.isAuthorized = true
            self.errorMessage = nil
        }
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = true
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.isAuthorized = false
                self.errorMessage = "权限申请失败: \(error.localizedDescription)"
            }
        }
        #endif
    }
    
    /// 检查当前权限状态
    func checkAuthorizationStatus() {
        #if targetEnvironment(simulator)
        isAuthorized = true
        #else
        let status = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = (status == .approved)
        #endif
    }
    
    // MARK: - 数据获取
    
    /// 获取今日屏幕使用数据
    /// 由于 ScreenTime API 限制，这里使用模拟数据演示架构
    /// 实际设备上需要通过 DeviceActivity 扩展获取真实数据
    func fetchTodayUsage() async {
        guard isAuthorized else {
            errorMessage = "未获得屏幕时间权限"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // ⚠️ 注意：ScreenTime API 的数据获取需要通过 DeviceActivity Extension
        // 这里提供架构代码，实际数据获取需要在真机上测试
        
        // 模拟数据（用于开发和预览）
        #if DEBUG || targetEnvironment(simulator)
        await loadMockData()
        #endif
    }
    
    /// 同步屏幕时间数据到本地数据库
    /// - Parameter activities: 从 DeviceActivity 获取的活动数据
    func syncUsageData(activities: [AppActivity]) async {
        guard let context = context else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for activity in activities {
            // 检查是否已存在今天的记录
            let descriptor = FetchDescriptor<AppUsage>(
                predicate: #Predicate { usage in
                    usage.bundleIdentifier == activity.bundleIdentifier &&
                    usage.date >= today
                }
            )
            
            if let existingUsage = try? context.fetch(descriptor).first {
                // 更新现有记录
                existingUsage.usageTime = activity.usageTime
            } else {
                // 创建新记录
                let newUsage = AppUsage(
                    bundleIdentifier: activity.bundleIdentifier,
                    appName: activity.appName,
                    usageTime: activity.usageTime,
                    date: Date(),
                    category: activity.category
                )
                context.insert(newUsage)
            }
        }
        
        try? context.save()
    }
    
    // MARK: - 模拟数据（仅用于开发测试）
    
    #if DEBUG || targetEnvironment(simulator)
    private func loadMockData() async {
        guard let context = context else { return }
        
        let mockApps = [
            ("com.tencent.xin", "微信", 5400.0, "社交"),
            ("com.ss.iphone.ugc.Aweme", "抖音", 3480.0, "娱乐"),
            ("com.xingin.xhs", "小红书", 2700.0, "社交"),
            ("com.apple.mobilesafari", "Safari", 1800.0, "工具"),
            ("com.burbn.instagram", "Instagram", 1200.0, "社交"),
            ("com.atebits.Tweetie2", "Twitter", 900.0, "社交"),
            ("com.apple.mobilemail", "邮件", 600.0, "效率"),
            ("com.apple.MobileSMS", "信息", 480.0, "社交")
        ]
        
        for (bundleId, name, time, category) in mockApps {
            let usage = AppUsage(
                bundleIdentifier: bundleId,
                appName: name,
                usageTime: time,
                date: Date(),
                category: category
            )
            context.insert(usage)
        }
        
        try? context.save()
    }
    #endif
}

// MARK: - 应用活动数据结构

struct AppActivity {
    let bundleIdentifier: String
    let appName: String
    let usageTime: TimeInterval
    let category: String?
    let icon: Data?
}

// MARK: - 应用限制管理（付费功能）

@MainActor
class AppLimitManager: ObservableObject {
    static let shared = AppLimitManager()
    
    #if !targetEnvironment(simulator)
    private let store = ManagedSettingsStore()
    #endif
    
    private init() {}
    
    /// 设置应用使用限制
    /// ⚠️ 需要 Premium 解锁
    func setLimit(for bundleIdentifier: String, dailyLimit: TimeInterval) {
        // 使用 ManagedSettings API 设置限制
        // 实际实现需要在 DeviceActivity Extension 中处理
    }
    
    /// 移除应用限制
    func removeLimit(for bundleIdentifier: String) {
        // 移除限制逻辑
    }
    
    /// 检查应用是否达到限制
    func checkLimit(bundleIdentifier: String) -> Bool {
        // 检查逻辑
        return false
    }
}
