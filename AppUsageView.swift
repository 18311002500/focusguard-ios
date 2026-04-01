//
//  AppUsageView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData

struct AppUsageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppUsage.usageTime, order: .reverse) private var usages: [AppUsage]
    
    @State private var selectedTimeRange: TimeRange = .today
    
    enum TimeRange: String, CaseIterable {
        case today = "今日"
        case week = "本周"
        case month = "本月"
    }
    
    var filteredUsages: [AppUsage] {
        let calendar = Calendar.current
        let now = Date()
        
        return usages.filter { usage in
            switch selectedTimeRange {
            case .today:
                return calendar.isDateInToday(usage.date)
            case .week:
                guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
                return usage.date >= weekAgo
            case .month:
                guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
                return usage.date >= monthAgo
            }
        }
    }
    
    var totalTime: TimeInterval {
        filteredUsages.reduce(0) { $0 + $1.usageTime }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 时间范围选择器
                Picker("时间范围", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 总使用时间
                VStack(spacing: 8) {
                    Text("总使用时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(totalTime))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                }
                .padding(.vertical, 10)
                
                // 应用列表
                List {
                    ForEach(filteredUsages) { usage in
                        AppUsageRow(usage: usage, totalTime: totalTime)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("应用使用")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

// MARK: - 应用使用行
struct AppUsageRow: View {
    let usage: AppUsage
    let totalTime: TimeInterval
    
    var percentage: Double {
        guard totalTime > 0 else { return 0 }
        return Double(usage.usageTime) / Double(totalTime)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 应用图标占位
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "app.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // 应用信息
            VStack(alignment: .leading, spacing: 4) {
                Text(usage.appName)
                    .font(.system(size: 16, weight: .medium))
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(usageColor)
                            .frame(width: geometry.size.width * CGFloat(percentage), height: 4)
                    }
                }
                .frame(height: 4)
            }
            
            Spacer()
            
            // 使用时间
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(usage.usageTime))
                    .font(.system(size: 14, weight: .medium))
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var usageColor: Color {
        if percentage > 0.3 {
            return .orange
        } else if percentage > 0.15 {
            return .yellow
        } else {
            return .green
        }
    }
    
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

#Preview {
    AppUsageView()
        .modelContainer(for: [AppUsage.self], inMemory: true)
}
