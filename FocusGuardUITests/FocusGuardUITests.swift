//
//  FocusGuardUITests.swift
//  FocusGuardUITests
//
//  Created by Crabator on 2025/04/08.
//

import XCTest

final class FocusGuardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testTabNavigation() throws {
        // 测试底部标签栏导航
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
        
        // 点击统计标签
        let statsTab = tabBar.buttons["统计"]
        if statsTab.exists {
            statsTab.tap()
            sleep(1)
        }
        
        // 点击设置标签
        let settingsTab = tabBar.buttons["设置"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
        }
    }
    
    // MARK: - Dashboard Tests
    
    func testDashboardElements() throws {
        // 检查导航标题
        let navigationTitle = app.navigationBars["FocusGuard"]
        XCTAssertTrue(navigationTitle.exists, "Dashboard navigation title should exist")
        
        // 检查屏幕时间卡片
        let screenTimeCard = app.staticTexts["今日屏幕时间"]
        XCTAssertTrue(screenTimeCard.exists, "Screen time card should exist")
        
        // 检查专注统计卡片
        let focusCard = app.staticTexts["今日专注"]
        XCTAssertTrue(focusCard.exists, "Focus stats card should exist")
    }
    
    // MARK: - Focus Mode Tests
    
    func testFocusModeUI() throws {
        // 查找开始专注按钮（如果有的话）
        let startFocusButton = app.buttons["开始专注"]
        if startFocusButton.exists {
            startFocusButton.tap()
            sleep(1)
            
            // 检查专注界面元素
            let timerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] '分钟'")).firstMatch
            XCTAssertTrue(timerLabel.exists, "Timer should be visible during focus mode")
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsNavigation() throws {
        // 导航到设置页面
        let settingsTab = app.tabBars.firstMatch.buttons["设置"]
        guard settingsTab.exists else {
            XCTSkip("Settings tab not found")
            return
        }
        
        settingsTab.tap()
        sleep(1)
        
        // 检查设置页面元素
        let settingsTitle = app.navigationBars["设置"]
        XCTAssertTrue(settingsTitle.exists, "Settings navigation bar should exist")
    }
    
    // MARK: - Launch Performance Test
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
