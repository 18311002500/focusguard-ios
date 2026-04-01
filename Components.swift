//
//  Components.swift
//  FocusGuard
//
//  可复用 UI 组件
//

import SwiftUI

// MARK: - 进度环组件
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(CGFloat(progress), 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 统计卡片组件
struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    let progress: Double?
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        color: Color,
        progress: Double? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.progress = progress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                if let progress = progress {
                    CircularProgressView(
                        progress: progress,
                        lineWidth: 4,
                        color: color,
                        size: 36
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: AppTheme.FontSize.title, weight: .bold, design: .rounded))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(color.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 应用图标组件
struct AppIconView: View {
    let bundleIdentifier: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(iconColor.opacity(0.15))
                .frame(width: size, height: size)
            
            Image(systemName: iconName)
                .font(.system(size: size * 0.5))
                .foregroundColor(iconColor)
        }
    }
    
    private var iconColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal, .indigo]
        let hash = abs(bundleIdentifier.hashValue)
        return colors[hash % colors.count]
    }
    
    private var iconName: String {
        let icons = ["app.fill", "bubble.left.fill", "envelope.fill", "safari.fill", "photo.fill", "music.note", "video.fill", "cart.fill"]
        let hash = abs(bundleIdentifier.hashValue)
        return icons[hash % icons.count]
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xlarge) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: AppTheme.Spacing.small) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.xlarge)
                        .padding(.vertical, AppTheme.Spacing.medium)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - 加载视图
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150)
    }
}

// MARK: - 分段控制器
struct SegmentedControl<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let title: (T) -> String
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selection = item
                    }
                }) {
                    Text(title(item))
                        .font(.subheadline)
                        .fontWeight(selection == item ? .semibold : .regular)
                        .foregroundColor(selection == item ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selection == item ? AppTheme.primaryColor : Color.clear
                        )
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - 开关行
struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 导航行
struct NavigationRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let showBadge: Bool
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        showBadge: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showBadge = showBadge
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if showBadge {
                Circle()
                    .fill(AppTheme.errorColor)
                    .frame(width: 8, height: 8)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 按钮样式
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .disabled(isLoading)
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            StatCardView(
                title: "今日屏幕时间",
                value: "4h 32m",
                subtitle: "目标: 4小时",
                icon: "iphone",
                color: .blue,
                progress: 0.75
            )
            
            HStack {
                AppIconView(bundleIdentifier: "com.test.app1", size: 50)
                AppIconView(bundleIdentifier: "com.test.app2", size: 50)
                AppIconView(bundleIdentifier: "com.test.app3", size: 50)
            }
            
            EmptyStateView(
                icon: "chart.pie",
                title: "暂无数据",
                message: "开始使用 FocusGuard 追踪您的屏幕时间",
                actionTitle: "开始追踪",
                action: {}
            )
            
            LoadingView(message: "正在加载数据...")
            
            PrimaryButton(title: "开始专注", icon: "play.fill") {}
        }
        .padding()
    }
}
