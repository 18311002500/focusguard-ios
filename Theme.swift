//
//  Theme.swift
//  FocusGuard
//
//  全局主题配置
//

import SwiftUI

enum AppTheme {
    // MARK: - 颜色
    static let primaryColor = Color.blue
    static let secondaryColor = Color.purple
    static let accentColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red
    
    // MARK: - 渐变
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, secondaryColor]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var focusGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple, Color.pink]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - 字体
    enum FontSize {
        static let tiny: CGFloat = 10
        static let small: CGFloat = 12
        static let caption: CGFloat = 14
        static let body: CGFloat = 16
        static let title3: CGFloat = 18
        static let title2: CGFloat = 20
        static let title: CGFloat = 24
        static let largeTitle: CGFloat = 32
        static let display: CGFloat = 48
    }
    
    // MARK: - 间距
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
    }
    
    // MARK: - 圆角
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
    }
    
    // MARK: - 阴影
    static func cardShadow(color: Color = .black) -> some ViewModifier {
        _CardShadowModifier(color: color)
    }
}

struct _CardShadowModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - View 扩展
extension View {
    func cardStyle() -> some View {
        self
            .padding(AppTheme.Spacing.large)
            .background(Color(.systemBackground))
            .cornerRadius(AppTheme.CornerRadius.large)
            .modifier(AppTheme.cardShadow())
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppTheme.primaryGradient)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
}
