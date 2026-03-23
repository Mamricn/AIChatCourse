//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//

import SwiftUI

protocol PurchaseManagerService {
    
    func listenForTransactions(onTransationUpdated: ([PurchasedEntitlement]) -> Void) async
    func getUserEntitlements() async -> [PurchasedEntitlement]
    func getProducts(productsIds: [String] ) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaesProduct(productId: String) async throws -> [PurchasedEntitlement]
    
}


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

import StoreKit

struct StoreKitPurchaseService: PurchaseManagerService {
    
    func listenForTransactions(onTransationUpdated: ([PurchasedEntitlement]) -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                
                await transaction.finish()
                
                let entitlements = await getUserEntitlements()
                onTransationUpdated(entitlements)
            }
        }
        
        
        
    }
    
    
    
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                
                let isActive: Bool
                if let expirationDate = transaction.expirationDate{
                    isActive = expirationDate >= Date.now
                }else{
                    isActive = transaction.revocationDate == nil
                }
                
                
                activeTransactions.append(
                    PurchasedEntitlement(
                        id: transaction.productID,
                        productId: transaction.productID,
                        expirationDate: transaction.expirationDate,
                        isActive: isActive,
                        originalPurchaseDate: transaction.originalPurchaseDate,
                        latestPurchaseDate: transaction.purchaseDate,
                        ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                        isSandbox: transaction.environment == .sandbox,
                        isVerified: true
                    )
                )
            case .unverified:
                break
            }
        }
        return activeTransactions
    }
    
    
    
    
    func getProducts(productsIds: [String] ) async throws -> [AnyProduct] {
        let products = try await Product.products(for: productsIds)
        
        return products.compactMap({ AnyProduct(storeKitProduct: $0) })
    }
    
    
    
    func restorePurchase() async throws -> [PurchasedEntitlement]{
        try await AppStore.sync()
        return await getUserEntitlements()
    }
    
    
    
    
    
    func purchaesProduct(productId: String) async throws -> [PurchasedEntitlement]{
        
        let products = try await Product.products(for: [productId])
        
        guard let product = products.first else {
            throw Error.productNotFound
        }
        
        
        
        let results = try await product.purchase()
        
        
        switch results {
        case .success(let verificationResult):
            let transaction =  try verificationResult.payloadValue
            await transaction.finish()
            
            return await getUserEntitlements()
            
        case .userCancelled:
            throw Error.userCancelledPurchase
        default:
            throw Error.failedtoPurchase
            
        }
        
        
        enum Error: LocalizedError {
            case productNotFound, userCancelledPurchase, failedtoPurchase
        }
        
    }
}
    
    
    
    @MainActor
    @Observable
class PurchaseManager {
    
    private let service: PurchaseManagerService
    private let logManager: LogManager?
    
    // //User's purchased entitelments, sorted by most resect
    private(set) var entitlements: [PurchasedEntitlement] = []
    
    init(service: PurchaseManagerService, logManager: LogManager? = nil){
        self.service = service
        self.logManager = logManager
        self.configure()
    }
    
    private func configure() {
        Task {
            let entitlements = await service.getUserEntitlements()
            updateActiveEntitlements(entitlements: entitlements)
        }
        Task {
            await service.listenForTransactions { entitlements in
                updateActiveEntitlements(entitlements: entitlements)
            }
        }
        
    }
    
    
    private func updateActiveEntitlements(entitlements: [PurchasedEntitlement]) {
        self.entitlements = entitlements.sortedByKeyPath(keyPath: \.expirationDateCalc, ascending: false)
        
        logManager?.addUserPropeties(dict: entitlements.eventParameters, isHighPriority: false)
    }
    
    
    
    func getProducts(productsIds: [String] ) async throws -> [AnyProduct] {
        logManager?.trackEvent(event: Event.getProductsStart)
        do {
            let entitlements = try await  service.getProducts(productsIds: productsIds)
            logManager?.trackEvent(event: Event.getProductsSuccess(products: entitlements))
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.getProductsFail(error: error))
            throw error
            
        }
        
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.restorePurchaesStart)
        
        do {
            let entitlements = try await service.restorePurchase()
            logManager?.trackEvent(event: Event.restorePurchaesSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements: entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.restorePurchaesFail(error: error))
            throw error
            
        }
    }
    
    func purchaesProduct(productId: String) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.restorePurchaesStart)
        
        do {
            let entitlements = try await service.purchaesProduct(productId: productId)
            logManager?.trackEvent(event: Event.restorePurchaesSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements: entitlements)

            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.restorePurchaesFail(error: error))
            throw error
        }
    }
    
    
    
    
    enum Event: LoggableEvent {
        
        case purchaseStart
        case purchaseSuccess(entitlements: [PurchasedEntitlement])
        case purchaseFail(error: Error)
        case restorePurchaesStart
        case restorePurchaesSuccess(entitlements: [PurchasedEntitlement])
        case restorePurchaesFail(error: Error)
        case getProductsStart
        case getProductsSuccess(products: [AnyProduct])
        case getProductsFail(error: Error)
        
        
        var eventName: String{
            
            switch self {
                
                
            case .purchaseStart:                    return "Purchase_Start"
            case .purchaseSuccess:                  return "Purchase_Success"
            case .purchaseFail:                     return "Purchase_Fail"
            case .restorePurchaesStart:             return "Purchase_restore_Start"
            case .restorePurchaesSuccess:           return "Purchase_restore_Success"
            case .restorePurchaesFail:              return "Purchase_restore_Fail"
            case .getProductsStart:                 return "Purchase_getProducts_Start"
            case .getProductsSuccess:               return "Purchase_getProducts_Success"
            case .getProductsFail:                  return "Purchase_getProducts_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .getProductsSuccess(products: let products):
                return products.eventParameters
            case .purchaseSuccess(entitlements: let entitlements), .restorePurchaesSuccess(entitlements: let entitlements):
                return entitlements.eventParameters
            case .getProductsFail(let error), .restorePurchaesFail(error: let error), .purchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .getProductsFail, .restorePurchaesFail, .purchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
    
    
    
    

