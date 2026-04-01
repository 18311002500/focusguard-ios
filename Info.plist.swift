//
//  Info.plist
//  FocusGuard
//
//  应用配置文件 - 包含 ScreenTime API 所需权限声明
//

/*
在 Xcode 项目的 Info.plist 中添加以下内容：

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 屏幕时间权限声明 -->
    <key>NSFamilyControlsUsageDescription</key>
    <string>FocusGuard 需要访问您的屏幕使用时间数据，以帮您追踪应用使用情况和设置专注模式。</string>
    
    <!-- 本地通知权限 -->
    <key>UIBackgroundModes</key>
    <array>
        <string>processing</string>
    </array>
    
    <!-- 应用名称 -->
    <key>CFBundleDisplayName</key>
    <string>FocusGuard</string>
    
    <!-- 支持的界面方向 -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    
    <!-- 启动画面 -->
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>LaunchScreenBackground</string>
        <key>UIImageName</key>
        <string>LaunchImage</string>
    </dict>
</dict>
</plist>

*/

/*
Entitlements 配置 (FocusGuard.entitlements):

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Family Controls - 屏幕时间 API 必需 -->
    <key>com.apple.developer.family-controls</key>
    <true/>
    
    <!-- App Groups - 用于主应用和扩展间共享数据 -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourdomain.focusguard</string>
    </array>
</dict>
</plist>

*/
