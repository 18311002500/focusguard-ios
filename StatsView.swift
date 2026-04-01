//
//  StatsView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    @Query(sort: \AppUsage.date, order: .reverse) private var usages: [AppUsage]
    
    @State private var selectedPeriod: StatsPeriod = .week
    
    enum StatsPeriod: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
    }
    
    var userSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    var isPremium: Bool {
        userSettings.isPremiumUnlocked
    }
    
    // 过滤后的专注会话
    var filteredSessions: [FocusSession] {
        let calendar = Calendar.current
        let now = Date()
        
        return sessions.filter { session in
            switch selectedPeriod {
            case .week:
                guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
                return session.startTime >= weekAgo
            case .month:
                guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
                return session.startTime >= monthAgo
            case .year:
                guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return false }
                return session.startTime >= yearAgo
            }
        }
    }
    
    // 完成的专注次数
    var completedSessionsCount: Int {
        filteredSessions.filter(\.isCompleted).count
    }
    
    // 总专注时长
    var totalFocusTime: TimeInterval {
        filteredSessions.filter(\.isCompleted).reduce(0) { $0 + $1.actualDuration }
    }
    
    // 平均专注时长
    var averageFocusTime: TimeInterval {
        let completed = filteredSessions.filter(\.isCompleted)
        guard !completed.isEmpty else { return 0 }
        return totalFocusTime / Double(completed.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 付费功能锁定提示
                    if !isPremium {
                        PremiumBanner()
                    }
                    
                    // 时间周期选择
                    Picker("时间周期", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 统计卡片
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "专注次数",
                            value: "\(completedSessionsCount)",
                            icon: "target",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "总专注时长",
                            value: formatTime(totalFocusTime),
                            icon: "clock.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "平均时长",
                            value: formatTime(averageFocusTime),
                            icon: "chart.bar.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "完成率",
                            value: completionRate,
                            icon: "checkmark.circle.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // 最近专注记录
                    VStack(alignment: .leading, spacing: 12) {
                        Text("最近专注记录")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if filteredSessions.isEmpty {
                            Text("暂无专注记录")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(filteredSessions.prefix(10)) { session in
                                SessionRow(session: session)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("统计分析")
        }
    }
    
    // 完成率
    var completionRate: String {
        guard !filteredSessions.isEmpty else { return "0%" }
        let rate = Double(completedSessionsCount) / Double(filteredSessions.count) * 100
        return String(format: "%.0f%%", rate)
    }
    
    // 格式化时间
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 专注记录行
struct SessionRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack {
            // 状态图标
            Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(session.isCompleted ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(session.startTime))
                    .font(.subheadline)
                
                Text("\(formatTime(session.actualDuration)) / \(formatTime(session.targetDuration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 完成状态标签
            Text(session.isCompleted ? "已完成" : "已中断")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(session.isCompleted ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (session.isCompleted ? Color.green : Color.orange).opacity(0.1)
                )
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes)分钟"
    }
}

// MARK: - 付费功能横幅
struct PremiumBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("解锁高级统计")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("查看周/月/年详细报告")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$4.99")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [FocusSession.self, UserSettings.self, AppUsage.self], inMemory: true)
}
