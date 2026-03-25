//
//  MockPurchaseService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/03/2026.
//

import SwiftUI

struct MockPurchaseService: PurchaseManagerService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []){
        self.activeEntitlements = activeEntitlements
    }
    
    
    func listenForTransactions(onTransationUpdated: ([PurchasedEntitlement]) -> Void) async {
        onTransationUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    
    func getProducts(productsIds: [String] ) async throws -> [AnyProduct]{
        return AnyProduct.mocks.filter{ product in
            
            return productsIds.contains(product.id)
        }
    }
    
    
    
    func restorePurchase() async throws -> [PurchasedEntitlement]{
        activeEntitlements
    }
    
    
    
    func purchaesProduct(productId: String) async throws -> [PurchasedEntitlement]{
        activeEntitlements
    }

}
