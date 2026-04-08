//
//  FocusGuardWidget.swift
//  FocusGuardWidget
//
//  Created by Crabator on 2025/04/01.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - 小组件数据提供者
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todayFocusTime: 3600, dailyGoal: 7200, isFocusing: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todayFocusTime: 3600, dailyGoal: 7200, isFocusing: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // 每15分钟更新一次
        let currentDate = Date()
        for hourOffset in 0 ..< 4 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset * 15, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                todayFocusTime: loadTodayFocusTime(),
                dailyGoal: loadDailyGoal(),
                isFocusing: loadIsFocusing()
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    // 从 UserDefaults 加载今日专注时间
    private func loadTodayFocusTime() -> TimeInterval {
        return UserDefaults(suiteName: "group.com.focusguard")?.double(forKey: "todayFocusTime") ?? 0
    }
    
    // 加载每日目标
    private func loadDailyGoal() -> TimeInterval {
        return UserDefaults(suiteName: "group.com.focusguard")?.double(forKey: "dailyFocusGoal") ?? 7200
    }
    
    // 加载是否正在专注
    private func loadIsFocusing() -> Bool {
        return UserDefaults(suiteName: "group.com.focusguard")?.bool(forKey: "isFocusing") ?? false
    }
}

// MARK: - 小组件数据条目
struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayFocusTime: TimeInterval
    let dailyGoal: TimeInterval
    let isFocusing: Bool
    
    var progress: Double {
        return min(todayFocusTime / dailyGoal, 1.0)
    }
    
    var formattedTime: String {
        let hours = Int(todayFocusTime) / 3600
        let minutes = (Int(todayFocusTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - 小组件视图
struct FocusGuardWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemExtraLarge:
            // 不支持超大尺寸
            return AnyView(EmptyView())
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - 小号小组件
struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // 标题
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("今日专注")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Spacer()
            
            // 时间显示
            Text(entry.formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(entry.progress), height: 6)
                }
            }
            .frame(height: 6)
            
            // 目标
            Text("目标: \(Int(entry.dailyGoal / 3600))小时")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - 中号小组件
struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(entry.progress))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: entry.progress)
                
                VStack {
                    Text(entry.formattedTime)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("\(Int(entry.progress * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            
            // 右侧：信息
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("今日专注")
                        .font(.headline)
                }
                
                Text("目标: \(Int(entry.dailyGoal / 3600))小时")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if entry.isFocusing {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 6))
                        Text("专注中...")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 大号小组件
struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // 顶部标题
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("今日专注统计")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                if entry.isFocusing {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 6))
                        Text("专注中")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // 大进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: CGFloat(entry.progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple, .pink]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut, value: entry.progress)
                
                VStack(spacing: 4) {
                    Text(entry.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("/ \(Int(entry.dailyGoal / 3600))小时目标")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(entry.progress * 100))% 完成")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // 底部快捷操作
            HStack(spacing: 12) {
                Link(destination: URL(string: "focusguard://start")!) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始专注")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Link(destination: URL(string: "focusguard://open")!) {
                    HStack {
                        Image(systemName: "arrow.up.forward.app")
                        Text("打开应用")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

// MARK: - 圆形配件小组件 (Watch/锁屏)
struct AccessoryCircularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(entry.progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("\(Int(entry.progress * 100))%")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

// MARK: - 矩形配件小组件
struct AccessoryRectangularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading) {
                Text("专注: \(entry.formattedTime)")
                    .font(.headline)
                Text("\(Int(entry.progress * 100))% 完成目标")
                    .font(.caption)
            }
            
            Spacer()
            
            if entry.isFocusing {
                Image(systemName: "circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 行内配件小组件
struct AccessoryInlineView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("专注: \(entry.formattedTime)")
        }
    }
}

// MARK: - 小组件主结构
struct FocusGuardWidget: Widget {
    let kind: String = "FocusGuardWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FocusGuardWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FocusGuard")
        .description("追踪您的每日专注时间")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - 预览
#Preview(as: .systemSmall) {
    FocusGuardWidget()
} timeline: {
    SimpleEntry(date: .now, todayFocusTime: 3600, dailyGoal: 7200, isFocusing: false)
    SimpleEntry(date: .now, todayFocusTime: 7200, dailyGoal: 7200, isFocusing: true)
}

#Preview(as: .systemMedium) {
    FocusGuardWidget()
} timeline: {
    SimpleEntry(date: .now, todayFocusTime: 3600, dailyGoal: 7200, isFocusing: false)
}

#Preview(as: .accessoryCircular) {
    FocusGuardWidget()
} timeline: {
    SimpleEntry(date: .now, todayFocusTime: 3600, dailyGoal: 7200, isFocusing: false)
}

