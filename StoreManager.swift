//
//  StoreManager.swift
//  FocusGuard
//
//  Created by Crabator on 2025/04/01.
//

import Foundation
import StoreKit

// MARK: - 内购产品类型
enum PremiumFeature: String, CaseIterable, Hashable {
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
}

// MARK: - 内购管理器
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPremiumUnlocked: Bool = false
    @Published var errorMessage: String?
    
    init() {
        isPremiumUnlocked = UserDefaults.standard.bool(forKey: "isPremiumUnlocked")
        startTransactionListener()
    }
    
    // MARK: - 监听交易
    private func startTransactionListener() {
        Task {
            for await result in StoreKit.Transaction.updates {
                await handleTransaction(result)
            }
        }
    }
    
    private func handleTransaction(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        
        if transaction.productID == ProductID.premiumUnlock.rawValue {
            await MainActor.run {
                isPremiumUnlocked = true
                UserDefaults.standard.set(true, forKey: "isPremiumUnlocked")
            }
        }
        await transaction.finish()
    }
    
    // MARK: - 请求产品
    func loadProducts() async {
        do {
            products = try await Product.products(for: [ProductID.premiumUnlock.rawValue])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 购买
    func purchase() async {
        guard let product = products.first else {
            errorMessage = "产品未加载"
            return
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleTransaction(verification)
            case .userCancelled:
                break
            case .pending:
                errorMessage = "购买等待中..."
            @unknown default:
                errorMessage = "未知错误"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 恢复购买
    func restore() async {
        do {
            try await AppStore.sync()
            await checkPurchases()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 检查购买状态
    func checkPurchases() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            await handleTransaction(result)
        }
    }
    
    // MARK: - 检查特定功能是否解锁
    func isFeatureUnlocked(_ feature: PremiumFeature) -> Bool {
        return isPremiumUnlocked
    }
}
