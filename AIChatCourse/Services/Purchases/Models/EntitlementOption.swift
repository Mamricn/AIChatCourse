//
//  EntitlementOption.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//


enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productID: String{
        switch self {
        case .yearly:
            return "Here product ID which we set up in AppStoreKid"
        }
    }
    static var allProductsIDs: [String]{
        EntitlementOption.allCases.map({$0.productID})
    }
    
}
