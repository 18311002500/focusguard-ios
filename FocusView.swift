//
//  FocusView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData
import UserNotifications

struct FocusView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FocusSession.startTime, order: .reverse) private var focusSessions: [FocusSession]
    @Query private var settings: [UserSettings]
    
    @State private var isFocusing = false
    @State private var isPaused = false
    @State private var remainingTime: TimeInterval = 25 * 60
    @State private var selectedDuration: TimeInterval = 25 * 60
    @State private var currentSession: FocusSession?
    @State private var timer: Timer?
    @State private var showingHistory = false
    @State private var showingGiveUpAlert = false
    @State private var interruptionCount = 0
    
    let durationOptions: [TimeInterval] = [15 * 60, 25 * 60, 45 * 60, 60 * 60]
    let durationLabels = ["15分钟", "25分钟", "45分钟", "60分钟"]
    
    var userSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    // 今日专注统计
    var todayFocusStats: (sessions: Int, totalTime: TimeInterval, completed: Int) {
        let calendar = Calendar.current
        let today = focusSessions.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: Date())
        }
        let totalTime = today.reduce(0) { $0 + $1.actualDuration }
        let completed = today.filter { $0.isCompleted }.count
        return (today.count, totalTime, completed)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 今日统计卡片
                    TodayFocusStatsCard(stats: todayFocusStats)
                        .padding(.horizontal)
                    
                    // 专注计时器
                    ZStack {
                        // 背景圆环
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 16)
                            .frame(width: 260, height: 260)
                        
                        // 进度圆环
                        Circle()
                            .trim(from: 0, to: isFocusing ? CGFloat(remainingTime / selectedDuration) : 1.0)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .pink]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 260, height: 260)
                            .animation(.linear(duration: 1), value: remainingTime)
                        
                        // 时间显示
                        VStack(spacing: 8) {
                            Text(formatTime(remainingTime))
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(isFocusing ? .primary : .secondary)
                            
                            if isFocusing {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text(isPaused ? "已暂停" : "专注中")
                                        .font(.subheadline)
                                        .foregroundColor(isPaused ? .orange : .blue)
                                }
                            } else {
                                Text("准备专注")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // 打断次数显示
                    if isFocusing && interruptionCount > 0 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("已打断 \(interruptionCount) 次")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // 时长选择（仅在非专注状态显示）
                    if !isFocusing {
                        VStack(spacing: 16) {
                            Text("选择专注时长")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(0..<durationOptions.count, id: \.self) { index in
                                    DurationButton(
                                        label: durationLabels[index],
                                        isSelected: selectedDuration == durationOptions[index]
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedDuration = durationOptions[index]
                                            remainingTime = durationOptions[index]
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 控制按钮
                    HStack(spacing: 24) {
                        if isFocusing {
                            // 暂停/继续按钮
                            ControlButton(
                                icon: isPaused ? "play.circle.fill" : "pause.circle.fill",
                                color: isPaused ? .green : .orange,
                                size: 70
                            ) {
                                togglePause()
                            }
                            
                            // 放弃按钮
                            ControlButton(
                                icon: "xmark.circle.fill",
                                color: .red,
                                size: 70
                            ) {
                                showingGiveUpAlert = true
                            }
                            
                            // 完成按钮（仅在最后5分钟显示）
                            if remainingTime <= 300 {
                                ControlButton(
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    size: 70
                                ) {
                                    completeFocus()
                                }
                            }
                        } else {
                            // 开始按钮
                            Button(action: startFocus) {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.fill")
                                        .font(.title2)
                                    Text("开始专注")
                                        .font(.title3.bold())
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // 历史记录入口
                    if !isFocusing {
                        Button(action: { showingHistory = true }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("查看专注历史")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 12)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("专注模式")
            .sheet(isPresented: $showingHistory) {
                FocusHistoryView()
            }
            .alert("确定要放弃吗？", isPresented: $showingGiveUpAlert) {
                Button("继续专注", role: .cancel) { }
                Button("放弃", role: .destructive) {
                    giveUpFocus()
                }
            } message: {
                Text("放弃后本次专注将不会被记录为完成。")
            }
            .onAppear {
                requestNotificationPermission()
            }
            .onDisappear {
                // 不停止计时器，允许后台运行
            }
        }
    }
    
    // MARK: - 开始专注
    private func startFocus() {
        // 请求通知权限
        requestNotificationPermission()
        
        let session = FocusSession(targetDuration: selectedDuration)
        modelContext.insert(session)
        try? modelContext.save()
        
        currentSession = session
        remainingTime = selectedDuration
        isFocusing = true
        isPaused = false
        interruptionCount = 0
        
        // 启动计时器
        startTimer()
        
        // 发送通知
        scheduleFocusNotification()
    }
    
    // MARK: - 启动计时器
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                completeFocus()
            }
        }
    }
    
    // MARK: - 暂停/继续
    private func togglePause() {
        if isPaused {
            // 继续
            startTimer()
            interruptionCount += 1
            if let session = currentSession {
                session.interruptionCount = interruptionCount
                try? modelContext.save()
            }
        } else {
            // 暂停
            timer?.invalidate()
            timer = nil
        }
        isPaused.toggle()
    }
    
    // MARK: - 放弃专注
    private func giveUpFocus() {
        timer?.invalidate()
        timer = nil
        
        if let session = currentSession {
            session.endTime = Date()
            session.isCompleted = false
            session.isAbandoned = true
            try? modelContext.save()
        }
        
        // 取消通知
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focusComplete"])
        
        resetFocusState()
    }
    
    // MARK: - 结束专注
    private func endFocus() {
        timer?.invalidate()
        timer = nil
        
        if let session = currentSession {
            session.endTime = Date()
            session.isCompleted = false
            try? modelContext.save()
        }
        
        resetFocusState()
    }
    
    // MARK: - 完成专注
    private func completeFocus() {
        timer?.invalidate()
        timer = nil
        
        if let session = currentSession {
            session.endTime = Date()
            session.isCompleted = true
            try? modelContext.save()
        }
        
        // 播放完成提示
        playCompletionFeedback()
        
        resetFocusState()
    }
    
    // MARK: - 重置状态
    private func resetFocusState() {
        isFocusing = false
        isPaused = false
        remainingTime = selectedDuration
        currentSession = nil
        interruptionCount = 0
        
        // 同步小组件数据
        syncWidgetData()
    }
    
    // MARK: - 同步小组件数据
    private func syncWidgetData() {
        WidgetDataManager.shared.syncData(
            focusSessions: focusSessions,
            dailyGoal: userSettings.dailyFocusGoal,
            isFocusing: isFocusing
        )
    }
    
    // MARK: - 通知权限
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            // 处理结果
        }
    }
    
    // MARK: - 发送专注完成通知
    private func scheduleFocusNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 专注完成！"
        content.body = "恭喜你完成了 \(Int(selectedDuration / 60)) 分钟的专注时间！"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: selectedDuration, repeats: false)
        let request = UNNotificationRequest(identifier: "focusComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 播放完成反馈
    private func playCompletionFeedback() {
        // 触觉反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - 格式化时间
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - 今日专注统计卡片
struct TodayFocusStatsCard: View {
    let stats: (sessions: Int, totalTime: TimeInterval, completed: Int)
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(stats.sessions)",
                label: "今日专注",
                icon: "target",
                color: .blue
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: formatDuration(stats.totalTime),
                label: "总时长",
                icon: "clock",
                color: .purple
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                value: "\(stats.completed)",
                label: "已完成",
                icon: "checkmark.circle",
                color: .green
            )
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private func formatDuration(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - 统计项
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 控制按钮
struct ControlButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.6))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(color.opacity(0.15))
                .clipShape(Circle())
        }
    }
}

// MARK: - 时长选择按钮
struct DurationButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 72, height: 40)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
                .cornerRadius(12)
        }
    }
}

// MARK: - 专注历史视图
struct FocusHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FocusSession.startTime, order: .reverse) private var sessions: [FocusSession]
    
    var body: some View {
        NavigationView {
            List {
                if sessions.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("暂无专注记录")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("开始你的第一次专注吧！")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                } else {
                    // 本周统计
                    WeeklyStatsSection(sessions: sessions)
                    
                    // 历史记录
                    Section(header: Text("历史记录")) {
                        ForEach(sessions) { session in
                            FocusSessionRow(session: session)
                        }
                    }
                }
            }
            .navigationTitle("专注历史")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 本周统计
struct WeeklyStatsSection: View {
    let sessions: [FocusSession]
    
    var weeklyStats: (total: TimeInterval, completed: Int, abandoned: Int) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let weekSessions = sessions.filter { $0.startTime >= weekAgo }
        
        let total = weekSessions.reduce(0) { $0 + $1.actualDuration }
        let completed = weekSessions.filter { $0.isCompleted }.count
        let abandoned = weekSessions.filter { $0.isAbandoned }.count
        
        return (total, completed, abandoned)
    }
    
    var body: some View {
        Section(header: Text("本周统计")) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("总专注时长")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDuration(weeklyStats.total))
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("完成率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let total = weeklyStats.completed + weeklyStats.abandoned
                        let rate = total > 0 ? Double(weeklyStats.completed) / Double(total) : 0
                        Text("\(Int(rate * 100))%")
                            .font(.title2.bold())
                            .foregroundColor(rate >= 0.7 ? .green : .orange)
                    }
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    Label("\(weeklyStats.completed) 次完成", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Label("\(weeklyStats.abandoned) 次放弃", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .font(.subheadline)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formatDuration(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}

// MARK: - 专注记录行
struct FocusSessionRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: 12) {
            // 状态图标
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 18))
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sessionDate)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text("\(Int(session.targetDuration / 60))分钟")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if session.interruptionCount > 0 {
                        Text("• 打断\(session.interruptionCount)次")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatDuration(session.actualDuration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(statusText)
                    .font(.caption2)
                    .foregroundColor(statusColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var sessionDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        if Calendar.current.isDateInToday(session.startTime) {
            formatter.dateFormat = "今天 HH:mm"
        } else if Calendar.current.isDateInYesterday(session.startTime) {
            formatter.dateFormat = "昨天 HH:mm"
        } else {
            formatter.dateFormat = "M月d日 HH:mm"
        }
        
        return formatter.string(from: session.startTime)
    }
    
    private var statusIcon: String {
        if session.isCompleted {
            return "checkmark.circle.fill"
        } else if session.isAbandoned {
            return "xmark.circle.fill"
        } else {
            return "pause.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if session.isCompleted {
            return .green
        } else if session.isAbandoned {
            return .red
        } else {
            return .orange
        }
    }
    
    private var statusText: String {
        if session.isCompleted {
            return "已完成"
        } else if session.isAbandoned {
            return "已放弃"
        } else {
            return "未完成"
        }
    }
    
    private func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return "\(minutes)分钟"
    }
}

#Preview {
    FocusView()
        .modelContainer(for: [FocusSession.self, UserSettings.self], inMemory: true)
}
