//
//  PaywallView.swift
//  FocusGuard
//
//  Created by Crabator on 2025/04/01.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @State private var showingRestoreAlert = false
    @State private var restoreMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题区域
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        
                        Text("升级到高级版")
                            .font(.largeTitle.bold())
                        
                        Text("解锁所有功能，提升您的专注力")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // 功能列表
                    VStack(spacing: 16) {
                        ForEach(PremiumFeature.allCases, id: \.self) { feature in
                            FeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 价格卡片
                    if let product = storeManager.products.first {
                        PriceCard(product: product)
                            .padding(.horizontal)
                    } else {
                        LoadingPriceCard()
                            .padding(.horizontal)
                    }
                    
                    // 购买按钮
                    VStack(spacing: 12) {
                        if let product = storeManager.products.first {
                            Button {
                                Task {
                                    await storeManager.purchase(product)
                                }
                            } label: {
                                HStack {
                                    if storeManager.purchaseState.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "lock.open.fill")
                                        Text("立即解锁 - \(product.displayPrice)")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .disabled(storeManager.purchaseState.isLoading)
                        }
                        
                        // 恢复购买按钮
                        Button {
                            Task {
                                await storeManager.restorePurchases()
                                if storeManager.isPremiumUnlocked {
                                    restoreMessage = "购买已恢复！"
                                } else {
                                    restoreMessage = "没有找到之前的购买记录。"
                                }
                                showingRestoreAlert = true
                            }
                        } label: {
                            Text("恢复购买")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(storeManager.purchaseState.isLoading)
                    }
                    .padding(.horizontal, 24)
                    
                    // 错误提示
                    if let errorMessage = storeManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // 底部说明
                    VStack(spacing: 8) {
                        Text("一次性购买，永久使用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Link("隐私政策", destination: URL(string: "https://your-privacy-policy-url.com")!)
                            Link("使用条款", destination: URL(string: "https://your-terms-url.com")!)
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("恢复购买", isPresented: $showingRestoreAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
            .onAppear {
                Task {
                    await storeManager.loadProducts()
                }
            }
        }
    }
}

// MARK: - 功能行
struct FeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.system(size: 28))
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.displayName)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 价格卡片
struct PriceCard: View {
    let product: Product
    
    var body: some View {
        VStack(spacing: 16) {
            Text("限时优惠")
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(12)
            
            VStack(spacing: 8) {
                Text(product.displayPrice)
                    .font(.system(size: 48, weight: .bold))
                
                Text("一次性购买，永久使用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("30天退款保证")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - 加载中价格卡片
struct LoadingPriceCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - 预览
#Preview {
    PaywallView()
        .environmentObject(StoreManager())
}
