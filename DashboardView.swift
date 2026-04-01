//
//  DashboardView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    @Query private var settings: [UserSettings]
    @Query(sort: \AppUsage.usageTime, order: .reverse) private var todayUsages: [AppUsage]
    @Query(filter: #Predicate<FocusSession> { session in
        session.startTime > Calendar.current.startOfDay(for: Date())
    }) private var todaySessions: [FocusSession]
    
    @State private var showingPermissionAlert = false
    
    var userSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    var totalScreenTime: TimeInterval {
        todayUsages.reduce(0) { $0 + $1.usageTime }
    }
    
    var completedFocusSessions: Int {
        todaySessions.filter(\.isCompleted).count
    }
    
    var totalFocusTime: TimeInterval {
        todaySessions.filter(\.isCompleted).reduce(0) { $0 + $1.actualDuration }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xlarge) {
                    // 权限状态提示
                    if !screenTimeManager.isAuthorized {
                        permissionBanner
                    }
                    
                    // 今日屏幕使用时间卡片
                    screenTimeCard
                    
                    // 专注统计卡片
                    focusStatsCard
                    
                    // 应用排行
                    topAppsSection
                }
                .padding()
            }
            .navigationTitle("FocusGuard")
            .refreshable {
                await refreshData()
            }
            .alert("需要屏幕时间权限", isPresented: $showingPermissionAlert) {
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("FocusGuard 需要屏幕时间权限来追踪您的应用使用情况。请在设置中开启权限。")
            }
        }
    }
    
    // MARK: - 权限横幅
    private var permissionBanner: some View {
        Button(action: {
            Task {
                await screenTimeManager.requestAuthorization()
            }
        }) {
            HStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("需要屏幕时间权限")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("点击授权以获取应用使用数据")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
    
    // MARK: - 屏幕时间卡片
    private var screenTimeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "iphone")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("今日屏幕时间")
                    .font(.headline)
                Spacer()
                
                if screenTimeManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(totalScreenTime.shortString())
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                Spacer()
                
                // 进度环
                CircularProgressView(
                    progress: min(totalScreenTime / userSettings.dailyScreenTimeGoal, 1.0),
                    lineWidth: 8,
                    color: screenTimeColor,
                    size: 60
                )
            }
            
            // 目标提示
            if totalScreenTime > userSettings.dailyScreenTimeGoal {
                Label("已超过今日目标", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Text("目标: \(userSettings.dailyScreenTimeGoal.shortString())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - 专注统计卡片
    private var focusStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("今日专注")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("\(completedFocusSessions)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("完成次数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text(totalFocusTime.shortString())
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("专注时长")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - 热门应用排行
    private var topAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("应用排行")
                    .font(.headline)
                Spacer()
                NavigationLink("查看全部") {
                    AppUsageView()
                }
                .font(.caption)
            }
            
            if todayUsages.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("暂无数据")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(screenTimeManager.isAuthorized ? "下拉刷新获取数据" : "请先授权屏幕时间权限")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                ForEach(todayUsages.prefix(5)) { usage in
                    HStack {
                        Image(systemName: "app.fill")
                            .foregroundColor(.blue)
                        Text(usage.appName)
                            .lineLimit(1)
                        Spacer()
                        Text(usage.usageTime.shortString())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - 刷新数据
    private func refreshData() async {
        await screenTimeManager.fetchTodayUsage()
    }
    
    // MARK: - 辅助方法
    private var screenTimeColor: Color {
        let ratio = totalScreenTime / userSettings.dailyScreenTimeGoal
        if ratio < 0.5 {
            return .green
        } else if ratio < 0.8 {
            return .yellow
        } else {
            return .orange
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [AppUsage.self, FocusSession.self, UserSettings.self], inMemory: true)
        .environmentObject(ScreenTimeManager.shared)
}
