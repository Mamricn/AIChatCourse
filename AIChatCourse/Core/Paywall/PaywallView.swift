//
//  PaywallView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//

import SwiftUI



struct PaywallView: View {
    
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var products: [AnyProduct] = []
    @State private var productsIds: [String] = EntitlementOption.allProductsIDs
    @State private var showAlert: AnyAppAlert?

    
    var body: some View {
        
        ZStack{
            if products.isEmpty {
                ProgressView()
            } else {
                CustomPaywalView(
                    products: products,
                    onBackButtonPressed: onBackButtonPressed,
                    onRestorePurchasePressed: onRestorePurchasePressed,
                    onPurchaseProductPressed: onPurchaseProductPressed
                )
            }
        }
        
        
        
        
//        StoreKitPaywallView()
            .screenAppearAnalytics(name: "Paywall")
            .showCustomAlert(alert: $showAlert)
            .task {
                await onLoadProducts()
            }
    }
    
    private func onLoadProducts() async {
        logManager.trackEvent(event: Event.loadProductsStart)
        do {
            products = try await purchaseManager.getProducts(productsIds: productsIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)

        dismiss()
    }
    private func onRestorePurchasePressed()  {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlaments = try await purchaseManager.restorePurchase()
                if entitlaments.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    private func onPurchaseProductPressed(product: AnyProduct)  {
        Task {
            do {
                let entitlaments = try await purchaseManager.purchaesProduct(productId: product.id)
                logManager.trackEvent(event: Event.purchaseProductSuccess(product: product))

                if entitlaments.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    
    
    enum Event: LoggableEvent {
        
        case loadProductsStart
        case purchaseProductSuccess(product: AnyProduct)
        case restorePurchaseStart
        case backButtonPressed
        
        
        
        var eventName: String{
            
            switch self {
            case .loadProductsStart:         return "PaywalView_loadProduct_Start"
            case .purchaseProductSuccess:    return "PaywalView_purchaseProduct_Success"
            case .restorePurchaseStart:      return "PaywalView_restorePurchase_Start"
            case .backButtonPressed:         return "PaywalView_backButton_Pressed"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .purchaseProductSuccess(product: let product):
                return product.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
    
    
    
    
}




import StoreKit
struct StoreKitPaywallView: View {
//    var productIds: String = EntitlementOption.allProductsIDs
    var body: some View {
//        SubscriptionStoreView(subscriptions: EntitlementOption.allProductsIDs) {
            Text("ho")
        }
    }
//}
#Preview {
    PaywallView()
        .previewEnvironment()
}
