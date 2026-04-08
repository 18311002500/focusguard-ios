//
//  DeviceActivityMonitor.swift
//  FocusGuardDeviceActivityMonitor
//
//  Device Activity Extension - 用于监控屏幕时间数据
// 需要在 Xcode 中添加 Device Activity Extension target
//

import Foundation
import UserNotifications

#if !targetEnvironment(simulator)
import DeviceActivity
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // 处理时间段开始事件
        // 例如：每日开始时重置统计
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // 处理时间段结束事件
        // 例如：每日结束时生成报告
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // 处理应用达到使用阈值事件
        // 例如：某应用使用超过限制，发送通知
        
        // 发送本地通知提醒用户
        sendLimitNotification()
    }
    
    private func sendLimitNotification() {
        // 配置本地通知内容
        let content = UNMutableNotificationContent()
        content.title = "FocusGuard"
        content.body = "您已达到今日应用使用限制"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
#endif

