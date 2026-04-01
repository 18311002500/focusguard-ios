//
//  Models.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import Foundation
import SwiftData

// MARK: - 应用使用数据模型
@Model
class AppUsage {
    var id: UUID
    var bundleIdentifier: String
    var appName: String
    var usageTime: TimeInterval
    var date: Date
    var category: String?
    
    init(bundleIdentifier: String, appName: String, usageTime: TimeInterval, date: Date, category: String? = nil) {
        self.id = UUID()
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.usageTime = usageTime
        self.date = date
        self.category = category
    }
}

// MARK: - 专注会话模型
@Model
class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var targetDuration: TimeInterval
    var isCompleted: Bool
    var isAbandoned: Bool
    var interruptionCount: Int
    var note: String?
    
    init(targetDuration: TimeInterval, note: String? = nil) {
        self.id = UUID()
        self.startTime = Date()
        self.targetDuration = targetDuration
        self.isCompleted = false
        self.isAbandoned = false
        self.interruptionCount = 0
        self.note = note
    }
    
    var actualDuration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
}

// MARK: - 用户设置模型
@Model
class UserSettings {
    var id: UUID
    var isPremiumUnlocked: Bool
    var dailyFocusGoal: TimeInterval
    var dailyScreenTimeGoal: TimeInterval
    var preferredFocusDuration: TimeInterval
    var isNotificationsEnabled: Bool
    
    init() {
        self.id = UUID()
        self.isPremiumUnlocked = false
        self.dailyFocusGoal = 60 * 60 // 1小时
        self.dailyScreenTimeGoal = 4 * 60 * 60 // 4小时
        self.preferredFocusDuration = 25 * 60 // 25分钟
        self.isNotificationsEnabled = true
    }
}

// MARK: - 应用限制模型（付费功能）
@Model
class AppLimit {
    var id: UUID
    var bundleIdentifier: String
    var appName: String
    var dailyLimit: TimeInterval
    var isEnabled: Bool
    
    init(bundleIdentifier: String, appName: String, dailyLimit: TimeInterval) {
        self.id = UUID()
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.dailyLimit = dailyLimit
        self.isEnabled = true
    }
}
