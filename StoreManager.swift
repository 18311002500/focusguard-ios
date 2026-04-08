//
//  StoreManager.swift
//  FocusGuard
//
//  Created by Crabator on 2025/04/01.
//

import Foundation
import StoreKit

// MARK: - 内购产品类型
enum PremiumFeature: String, CaseIterable {
    case unlimitedFocus = "unlimited_focus"
    case appLimits = "app_limits"
    case dataExport = "data_export"
    case advancedStats = "advanced_stats"
    
    var displayName: String {
        switch self {
        case .unlimitedFocus: return "无限专注"
        case .appLimits: return "应用限制"
        case .dataExport: return "数据导出"
        case .advancedStats: return "高级统计"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedFocus: return "无限制使用专注模式"
        case .appLimits: return "设置每日应用使用限制"
        case .dataExport: return "导出您的使用数据为 CSV"
        case .advancedStats: return "查看详细的周/月统计"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedFocus: return "infinity.circle.fill"
        case .appLimits: return "hourglass.circle.fill"
        case .dataExport: return "square.and.arrow.up.circle.fill"
        case .advancedStats: return "chart.bar.fill"
        }
    }
}

// MARK: - 产品 ID
enum ProductID: String, CaseIterable {
    case premiumUnlock = "com.baobao.focusguard.premium"
    
    static var allProductIDs: [String] {
        return Self.allCases.map { $0.rawValue }
    }
}

// MARK: - 购买状态
enum PurchaseState: Equatable {
    case notStarted
    case loading
    case purchasing
    case purchased
    case failed(String)
    case restored
    
    var isLoading: Bool {
        switch self {
        case .loading, .purchasing:
            return true
        default:
            return false
        }
    }
}

// MARK: - 内购管理器
@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .notStarted
    @Published var isPremiumUnlocked: Bool = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        // 检查之前的购买状态
        isPremiumUnlocked = UserDefaults.standard.bool(forKey: "isPremiumUnlocked")
        
        // 监听购买更新
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - 监听交易更新
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    // MARK: - 处理交易结果
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        switch result {
        case .verified(let transaction):
            await handleVerifiedTransaction(transaction)
            await transaction.finish()
        case .unverified(_, let error):
            print("Transaction unverified: \(error)")
        }
    }
    
    // MARK: - 请求产品
    func requestProducts() async {
        purchaseState = .loading
        
        do {
            let storeProducts = try await Product.products(for: ProductID.allProductIDs)
            products = storeProducts.sorted { $0.price < $1.price }
            purchaseState = .notStarted
        } catch {
            purchaseState = .failed(error.localizedDescription)
            errorMessage = "无法加载产品: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 购买产品
    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handlePurchaseVerification(verification)
                
            case .userCancelled:
                purchaseState = .notStarted
                
            case .pending:
                purchaseState = .notStarted
                errorMessage = "购买正在等待处理..."
                
            @unknown default:
                purchaseState = .failed("未知错误")
                errorMessage = "未知错误"
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            errorMessage = "购买失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 恢复购买
    func restorePurchases() async {
        purchaseState = .loading
        
        do {
            try await AppStore.sync()
            await checkPreviousPurchases()
            purchaseState = .restored
        } catch {
            purchaseState = .failed(error.localizedDescription)
            errorMessage = "恢复失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 检查之前的购买
    func checkPreviousPurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await handleVerifiedTransaction(transaction)
            }
        }
    }
    
    // MARK: - 处理购买验证
    private func handlePurchaseVerification(_ verification: VerificationResult<StoreKit.Transaction>) async {
        switch verification {
        case .verified(let transaction):
            await handleVerifiedTransaction(transaction)
            await transaction.finish()
            purchaseState = .purchased
            
        case .unverified(_, let error):
            purchaseState = .failed(error.localizedDescription)
            errorMessage = "验证失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 处理已验证的交易
    private func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        switch transaction.productID {
        case ProductID.premiumUnlock.rawValue:
            isPremiumUnlocked = true
            UserDefaults.standard.set(true, forKey: "isPremiumUnlocked")
            
        default:
            break
        }
    }
    
    // MARK: - 检查特定功能是否解锁
    func isFeatureUnlocked(_ feature: PremiumFeature) -> Bool {
        return isPremiumUnlocked
    }
}

// MARK: - SwiftUI Environment
import SwiftUI

private struct StoreManagerKey: EnvironmentKey {
    static var defaultValue: StoreManager {
        return StoreManager()
    }
}

extension EnvironmentValues {
    var storeManager: StoreManager {
        get { self[StoreManagerKey.self] }
        set { self[StoreManagerKey.self] = newValue }
    }
}
