//
//  FocusGuardApp.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData

// ScreenTime API 只在真机上可用
#if !targetEnvironment(simulator)
import FamilyControls
#endif

@main
struct FocusGuardApp: App {
    @StateObject private var storeManager = StoreManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUsage.self,
            FocusSession.self,
            UserSettings.self,
            AppLimit.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ScreenTimeManager.shared)
                .environmentObject(storeManager)
                .onAppear {
                    ScreenTimeManager.shared.setupContext(sharedModelContainer.mainContext)
                    ScreenTimeManager.shared.checkAuthorizationStatus()
                    
                    // 检查之前的购买
                    storeManager.checkPreviousPurchases()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 配置通知
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("通知权限申请失败: \(error)")
            }
        }
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
