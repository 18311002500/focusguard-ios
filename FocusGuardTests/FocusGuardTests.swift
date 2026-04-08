//
//  FocusGuardTests.swift
//  FocusGuardTests
//
//  Created by Crabator on 2025/04/08.
//

import XCTest
import SwiftData
@testable import FocusGuard

@MainActor
final class FocusGuardTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // 创建内存中的 ModelContainer 用于测试
        let schema = Schema([FocusSession.self, AppUsage.self, UserSettings.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
        try await super.tearDown()
    }
    
    // MARK: - FocusSession Tests
    
    func testFocusSessionCreation() throws {
        let session = FocusSession(targetDuration: 1500) // 25分钟
        
        XCTAssertEqual(session.targetDuration, 1500)
        XCTAssertFalse(session.isCompleted)
        XCTAssertEqual(session.interruptionCount, 0)
        XCTAssertNil(session.endTime)
    }
    
    func testFocusSessionCompletion() throws {
        let session = FocusSession(targetDuration: 600)
        session.endTime = Date()
        session.actualDuration = 600
        session.isCompleted = true
        
        XCTAssertTrue(session.isCompleted)
        XCTAssertEqual(session.actualDuration, 600)
        XCTAssertNotNil(session.endTime)
    }
    
    func testFocusSessionInterruption() throws {
        let session = FocusSession(targetDuration: 1200)
        session.interruptionCount = 3
        
        XCTAssertEqual(session.interruptionCount, 3)
    }
    
    // MARK: - AppUsage Tests
    
    func testAppUsageCreation() throws {
        let usage = AppUsage(
            bundleIdentifier: "com.test.app",
            appName: "测试应用",
            usageTime: 3600,
            date: Date(),
            category: "生产力"
        )
        
        XCTAssertEqual(usage.bundleIdentifier, "com.test.app")
        XCTAssertEqual(usage.appName, "测试应用")
        XCTAssertEqual(usage.usageTime, 3600)
        XCTAssertEqual(usage.category, "生产力")
    }
    
    // MARK: - UserSettings Tests
    
    func testUserSettingsDefaults() throws {
        let settings = UserSettings()
        
        XCTAssertEqual(settings.dailyScreenTimeGoal, 14400) // 4小时默认
        XCTAssertEqual(settings.dailyFocusGoal, 7200) // 2小时默认
        XCTAssertTrue(settings.notificationsEnabled)
    }
    
    func testUserSettingsUpdate() throws {
        let settings = UserSettings()
        settings.dailyScreenTimeGoal = 7200
        settings.dailyFocusGoal = 3600
        
        XCTAssertEqual(settings.dailyScreenTimeGoal, 7200)
        XCTAssertEqual(settings.dailyFocusGoal, 3600)
    }
    
    // MARK: - TimeInterval Extension Tests
    
    func testTimeIntervalShortString() {
        let oneHour: TimeInterval = 3600
        XCTAssertEqual(oneHour.shortString(), "1h 0m")
        
        let thirtyMinutes: TimeInterval = 1800
        XCTAssertEqual(thirtyMinutes.shortString(), "30m")
        
        let ninetyMinutes: TimeInterval = 5400
        XCTAssertEqual(ninetyMinutes.shortString(), "1h 30m")
    }
    
    // MARK: - SwiftData Tests
    
    func testFocusSessionPersistence() async throws {
        let session = FocusSession(targetDuration: 900)
        context.insert(session)
        
        // 查询
        let descriptor = FetchDescriptor<FocusSession>()
        let results = try context.fetch(descriptor)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.targetDuration, 900)
    }
    
    func testAppUsagePersistence() async throws {
        let usage = AppUsage(
            bundleIdentifier: "com.test.persistence",
            appName: "持久化测试",
            usageTime: 1800,
            date: Date(),
            category: "测试"
        )
        context.insert(usage)
        
        let descriptor = FetchDescriptor<AppUsage>()
        let results = try context.fetch(descriptor)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.appName, "持久化测试")
    }
}
