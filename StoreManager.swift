//
//  StoreManager.swift
//  FocusGuard
//
//  Created by Crabator on 2025/04/01.
//

import Foundation
import StoreKit
import SwiftData

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
    case premiumUnlock = "com.focusguard.premium.unlock"
    
    static var allProductIDs: [String] {
        return Self.allCases.map { $0.rawValue }
    }
}

// MARK: - 购买状态
enum PurchaseState {
    case notStarted
    case loading
    case purchasing
    case purchased
    case failed(Error)
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
    
    private var updates: Task<Void, Never>?
    
    init() {
        // 检查之前的购买状态
        checkPreviousPurchases()
        
        // 监听购买更新
        updates = Task {
            for await update in Transaction.updates {
                await handleUpdate(update)
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - 请求产品
    func requestProducts() async {
        purchaseState = .loading
        
        do {
            let storeProducts = try await Product.products(for: ProductID.allProductIDs)
            products = storeProducts.sorted { $0.price < $1.price }
            purchaseState = .notStarted
        } catch {
            purchaseState = .failed(error)
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
                purchaseState = .failed(StoreError.unknown)
                errorMessage = "未知错误"
            }
        } catch {
            purchaseState = .failed(error)
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
            purchaseState = .failed(error)
            errorMessage = "恢复失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 检查之前的购买
    func checkPreviousPurchases() {
        Task {
            for await entitlement in Transaction.currentEntitlements {
                if case .verified(let transaction) = entitlement {
                    await handleVerifiedTransaction(transaction)
                }
            }
        }
    }
    
    // MARK: - 处理购买验证
    private func handlePurchaseVerification(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            await handleVerifiedTransaction(transaction)
            await transaction.finish()
            purchaseState = .purchased
            
        case .unverified(_, let error):
            purchaseState = .failed(error)
            errorMessage = "验证失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 处理已验证的交易
    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        switch transaction.productID {
        case ProductID.premiumUnlock.rawValue:
            isPremiumUnlocked = true
            // 保存到 UserDefaults
            UserDefaults.standard.set(true, forKey: "isPremiumUnlocked")
            
        default:
            break
        }
    }
    
    // MARK: - 处理更新
    private func handleUpdate(_ update: Transaction) async {
        if case .verified(let transaction) = update {
            await handleVerifiedTransaction(transaction)
            await transaction.finish()
        }
    }
    
    // MARK: - 检查特定功能是否解锁
    func isFeatureUnlocked(_ feature: PremiumFeature) -> Bool {
        // 所有高级功能都需要解锁
        return isPremiumUnlocked
    }
}

// MARK: - 错误类型
enum StoreError: LocalizedError {
    case unknown
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "未知错误"
        case .productNotFound:
            return "找不到产品"
        case .purchaseFailed:
            return "购买失败"
        }
    }
}

// MARK: - SwiftUI Environment Key
private struct StoreManagerKey: EnvironmentKey {
    static let defaultValue = StoreManager()
}

extension EnvironmentValues {
    var storeManager: StoreManager {
        get { self[StoreManagerKey.self] }
        set { self[StoreManagerKey.self] = newValue }
    }
}