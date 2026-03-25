//
//  PurchaseManagerService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/03/2026.
//


protocol PurchaseManagerService {
    
    func listenForTransactions(onTransationUpdated: ([PurchasedEntitlement]) -> Void) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
    func getProducts(productsIds: [String] ) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaesProduct(productId: String) async throws -> [PurchasedEntitlement]
    
}