//
//  WidgetDataManager.swift
//  FocusGuard
//
//  Created by Crabator on 2025/04/01.
//

import Foundation
import SwiftData

// MARK: - 小组件数据管理器
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let suiteName = "group.com.focusguard"
    private var defaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
    
    // MARK: - 更新今日专注时间
    func updateTodayFocusTime(_ time: TimeInterval) {
        defaults?.set(time, forKey: "todayFocusTime")
        
        // 触发小组件刷新
        WidgetCenter.shared.reloadTimelines(ofKind: "FocusGuardWidget")
    }
    
    // MARK: - 更新每日目标
    func updateDailyGoal(_ goal: TimeInterval) {
        defaults?.set(goal, forKey: "dailyFocusGoal")
        WidgetCenter.shared.reloadTimelines(ofKind: "FocusGuardWidget")
    }
    
    // MARK: - 更新专注状态
    func updateFocusingState(_ isFocusing: Bool) {
        defaults?.set(isFocusing, forKey: "isFocusing")
        WidgetCenter.shared.reloadTimelines(ofKind: "FocusGuardWidget")
    }
    
    // MARK: - 从数据库计算今日专注时间
    func calculateTodayFocusTime(from sessions: [FocusSession]) -> TimeInterval {
        let calendar = Calendar.current
        let todaySessions = sessions.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: Date())
        }
        return todaySessions.reduce(0) { $0 + $1.actualDuration }
    }
    
    // MARK: - 同步所有数据
    func syncData(focusSessions: [FocusSession], dailyGoal: TimeInterval, isFocusing: Bool) {
        let todayTime = calculateTodayFocusTime(from: focusSessions)
        updateTodayFocusTime(todayTime)
        updateDailyGoal(dailyGoal)
        updateFocusingState(isFocusing)
    }
}

// MARK: - WidgetCenter 导入
import WidgetKit