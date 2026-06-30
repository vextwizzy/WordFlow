//
//  PremiumView.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import SwiftUI
import StoreKit

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeKitService = StoreKitService()
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            GlassBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(LinearGradient.goldGradient)
                            .pulseEffect(isActive: true)
                        
                        Text("WordFlow Premium")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                        
                        Text("Unlock unlimited learning")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(spacing: 20) {
                        FeatureRow(
                            icon: "infinity",
                            title: "Unlimited Words",
                            description: "Learn as many words as you want, every day"
                        )
                        
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI Explanations",
                            description: "Get personalized explanations powered by AI"
                        )
                        
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "Advanced Statistics",
                            description: "Detailed insights into your learning progress"
                        )
                        
                        FeatureRow(
                            icon: "arrow.down.doc.fill",
                            title: "Export Progress",
                            description: "Download your data anytime"
                        )
                        
                        FeatureRow(
                            icon: "sparkles",
                            title: "Premium Content",
                            description: "Access exclusive word collections"
                        )
                        
                        FeatureRow(
                            icon: "bell.slash.fill",
                            title: "Ad-Free Experience",
                            description: "Enjoy learning without interruptions"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Products
                    if !storeKitService.products.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(storeKitService.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    onSelect: { selectedProduct = product }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                    
                    // Purchase button
                    if let product = selectedProduct {
                        Button(action: { purchase(product) }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Subscribe Now")
                                        .font(.bodyLarge)
                                        .bold()
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(LinearGradient.goldGradient)
                            )
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, 20)
                    }
                    
                    // Restore purchases
                    Button(action: restorePurchases) {
                        Text("Restore Purchases")
                            .font(.bodyRegular)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 10)
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("Auto-renewable subscription")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        HStack(spacing: 16) {
                            Button("Terms") {}
                            Button("Privacy") {}
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.vertical, 20)
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(20)
                    }
                }
                
                Spacer()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Purchase
    
    private func purchase(_ product: Product) {
        isPurchasing = true
        
        Task {
            do {
                let transaction = try await storeKitService.purchase(product)
                
                if transaction != nil {
                    // Purchase successful
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            
            await MainActor.run {
                isPurchasing = false
            }
        }
    }
    
    // MARK: - Restore Purchases
    
    private func restorePurchases() {
        Task {
            do {
                try await storeKitService.restore()
                
                if storeKitService.isPremium {
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to restore purchases"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(LinearGradient.goldGradient)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodyLarge)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.bodySmall)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var isYearly: Bool {
        product.id.contains("yearly")
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(isYearly ? "Yearly" : "Monthly")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                            
                            if isYearly {
                                Text("SAVE 50%")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.success)
                                    )
                            }
                        }
                        
                        Text(product.displayPrice)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(LinearGradient.goldGradient)
                        
                        if isYearly {
                            Text("Just \(yearlyMonthlyPrice) per month")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isSelected ? .success : .white.opacity(0.3))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? LinearGradient.brandGradient : LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.brandPrimary : Color.white.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    var yearlyMonthlyPrice: String {
        let monthlyPrice = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = product.id.contains("usd") ? "USD" : "USD"
        return formatter.string(from: monthlyPrice as NSDecimalNumber) ?? "$\(monthlyPrice)"
    }
}

#Preview {
    PremiumView()
}
