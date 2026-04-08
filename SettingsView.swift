//
//  SettingsView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeManager: StoreManager
    @Query private var settings: [UserSettings]
    
    @State private var showingPaywall = false
    @State private var showingRestoreAlert = false
    @State private var restoreMessage = ""
    
    var userSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    var isPremium: Bool {
        storeManager.isPremiumUnlocked
    }
    
    var body: some View {
        NavigationView {
            List {
                // 会员状态区域
                Section {
                    PremiumStatusCard(isPremium: isPremium) {
                        showingPaywall = true
                    }
                }
                
                // 每日目标设置
                Section(header: Text("每日目标")) {
                    NavigationLink(destination: GoalSettingsView()) {
                        HStack {
                            Text("屏幕时间目标")
                            Spacer()
                            Text(formatTime(userSettings.dailyScreenTimeGoal))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: GoalSettingsView()) {
                        HStack {
                            Text("专注时间目标")
                            Spacer()
                            Text(formatTime(userSettings.dailyFocusGoal))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 通知设置
                Section(header: Text("通知")) {
                    Toggle("启用通知", isOn: Binding(
                        get: { userSettings.isNotificationsEnabled },
                        set: { newValue in
                            userSettings.isNotificationsEnabled = newValue
                            try? modelContext.save()
                        }
                    ))
                    
                    if userSettings.isNotificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            Text("通知设置")
                        }
                    }
                }
                
                // 高级功能
                Section(header: Text("高级功能")) {
                    if isPremium {
                        Button(action: exportData) {
                            Label("导出数据", systemImage: "square.and.arrow.up")
                        }
                        
                        NavigationLink(destination: AppLimitsView()) {
                            Label("应用限制", systemImage: "hourglass")
                        }
                    } else {
                        LockedFeatureRow(icon: "square.and.arrow.up", title: "导出数据")
                        LockedFeatureRow(icon: "hourglass", title: "应用限制")
                    }
                }
                
                // 数据管理
                Section(header: Text("数据管理")) {
                    Button(action: clearAllData) {
                        Label("清除所有数据", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // 购买相关
                if !isPremium {
                    Section(header: Text("购买")) {
                        Button {
                            showingPaywall = true
                        } label: {
                            Label("升级到高级版", systemImage: "crown.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            Task {
                                await storeManager.restorePurchases()
                                if storeManager.isPremiumUnlocked {
                                    restoreMessage = "购买已成功恢复！"
                                } else {
                                    restoreMessage = "没有找到之前的购买记录。"
                                }
                                showingRestoreAlert = true
                            }
                        } label: {
                            Label("恢复购买", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                
                // 关于
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Label("使用条款", systemImage: "doc.text")
                    }
                    
                    Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                        Label("隐私政策", systemImage: "hand.raised.fill")
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
            .alert("恢复购买", isPresented: $showingRestoreAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
            .onAppear {
                // 检查之前的购买状态
                Task { await storeManager.checkPreviousPurchases() }
            }
        }
    }
    
    // MARK: - 导出数据
    private func exportData() {
        // TODO: 实现数据导出功能
    }
    
    // MARK: - 清除数据
    private func clearAllData() {
        // TODO: 实现数据清除功能，需要确认弹窗
    }
    
    // MARK: - 格式化时间
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        return "\(hours)小时"
    }
}

// MARK: - 会员状态卡片
struct PremiumStatusCard: View {
    let isPremium: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isPremium ? "crown.fill" : "crown")
                    .font(.system(size: 40))
                    .foregroundStyle(isPremium ? 
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                    )
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPremium ? "高级版已解锁" : "升级到高级版")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(isPremium ? "享受所有高级功能" : "解锁应用限制、深度统计等功能")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !isPremium {
                Button(action: onUpgrade) {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("立即解锁 · $4.99")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("所有功能已解锁")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    isPremium ? Color.yellow.opacity(0.1) : Color.blue.opacity(0.1),
                    isPremium ? Color.orange.opacity(0.1) : Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - 锁定功能行
struct LockedFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.secondary)
    }
}

// MARK: - 目标设置视图
struct GoalSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    var userSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    var body: some View {
        Form {
            Section(header: Text("屏幕时间目标"), footer: Text("设置每日屏幕使用时间目标，超过此时间将收到提醒。")) {
                Stepper(value: Binding(
                    get: { Int(userSettings.dailyScreenTimeGoal / 3600) },
                    set: { newValue in
                        userSettings.dailyScreenTimeGoal = TimeInterval(newValue * 3600)
                        try? modelContext.save()
                    }
                ), in: 1...12) {
                    Text("\(Int(userSettings.dailyScreenTimeGoal / 3600)) 小时")
                }
            }
            
            Section(header: Text("专注时间目标"), footer: Text("设置每日专注时间目标。")) {
                Stepper(value: Binding(
                    get: { Int(userSettings.dailyFocusGoal / 3600) },
                    set: { newValue in
                        userSettings.dailyFocusGoal = TimeInterval(newValue * 3600)
                        try? modelContext.save()
                    }
                ), in: 0...8) {
                    Text("\(Int(userSettings.dailyFocusGoal / 3600)) 小时")
                }
            }
        }
        .navigationTitle("每日目标")
    }
}

// MARK: - 通知设置视图
struct NotificationSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("专注通知")) {
                Toggle("专注完成提醒", isOn: .constant(true))
                Toggle("专注中断提醒", isOn: .constant(true))
            }
            
            Section(header: Text("屏幕时间通知")) {
                Toggle("每日使用报告", isOn: .constant(true))
                Toggle("目标达成提醒", isOn: .constant(true))
            }
        }
        .navigationTitle("通知设置")
    }
}

// MARK: - 应用限制视图
struct AppLimitsView: View {
    var body: some View {
        Text("应用限制功能开发中...")
            .navigationTitle("应用限制")
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserSettings.self], inMemory: true)
        .environmentObject(StoreManager())
}
