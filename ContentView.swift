//
//  ContentView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/03/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("概览", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            AppUsageView()
                .tabItem {
                    Label("应用", systemImage: "app.badge.fill")
                }
                .tag(1)
            
            FocusView()
                .tabItem {
                    Label("专注", systemImage: "target")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(4)
        }
        .onAppear {
            initializeDefaultSettings()
        }
    }
    
    private func initializeDefaultSettings() {
        if settings.isEmpty {
            let defaultSettings = UserSettings()
            modelContext.insert(defaultSettings)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [AppUsage.self, FocusSession.self, UserSettings.self], inMemory: true)
}
