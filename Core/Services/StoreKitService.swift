//
//  StoreKitService.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import StoreKit
import Foundation

@Observable
final class StoreKitService {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs = Set<String>()
    
    private let productIDs = ["wordflow.premium.monthly", "wordflow.premium.yearly"]
    
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase"
        case .productNotFound:
            return "Product not found"
        }
    }
}
