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
    
    
}

import StoreKit

struct StoreKitPurchaseService: PurchaseManagerService {
    
    func listenForTransactions(onTransationUpdated: ([PurchasedEntitlement]) -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
               let entitlements = await getUserEntitlements()
                onTransationUpdated(entitlements)
                
                await transaction.finish()
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

}
