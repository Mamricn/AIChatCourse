//
//  PurchaseManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//

import SwiftUI


    
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
    
    
    
    

