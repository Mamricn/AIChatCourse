//
//  ActiveABTest.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//
import SwiftUI
import FirebaseRemoteConfig

@MainActor
struct ActiveABTest: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOptions
    private(set) var paywallTest: PaywallTestOptions
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOptions,
        paywallTest: PaywallTestOptions
    ){
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
        self.paywallTest = paywallTest
    }

    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202603_CreateAccTest"
        case onboardingCommunityTest = "_202603_OnbCommTest"
        case categoryRowTest = "_202603_CategoryRowTest"
        case paywallTest = "_202603_PaywallTest"
    }
    
    var eventParameters: [String: Any] {
        
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue,
            "test\(CodingKeys.paywallTest.rawValue)": paywallTest.rawValue


        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool){
        createAccountTest = newValue
    }
    mutating func update(onboardingCommunityTest newValue: Bool){
        onboardingCommunityTest = newValue
    }
    mutating func update(categoryRowTest newValue: CategoryRowTestOptions){
        categoryRowTest = newValue
    }
    mutating func update(paywallTest newValue: PaywallTestOptions){
        paywallTest = newValue
    }
}




// MARK: REMOTE CONFIG

extension ActiveABTest {
    
    init(config: RemoteConfig){
        let createAccountTest = config.configValue(forKey: ActiveABTest.CodingKeys.createAccountTest.rawValue).boolValue
        print("FOUND CREATE ACCOUNT DATA: \(createAccountTest)")
        self.createAccountTest = createAccountTest
        
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTest.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self .onboardingCommunityTest = onboardingCommunityTest
        
        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTest.CodingKeys.categoryRowTest.rawValue).stringValue
        if let option = CategoryRowTestOptions(rawValue: categoryRowTestStringValue){
            self.categoryRowTest = option
        }else {
            self.categoryRowTest = .default
        }
        
        let paywallTestStringValue = config.configValue(forKey: ActiveABTest.CodingKeys.paywallTest.rawValue).stringValue
        if let option = PaywallTestOptions(rawValue: categoryRowTestStringValue){
            self.paywallTest = option
        }else {
            self.paywallTest = .default
        }
        
    }
    
    //Convert to a NSObject Dictionary to setDifaults within FirebaseABTestService
    var asNSObjectDictionary: [String : NSObject]? {
         [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject,
            CodingKeys.paywallTest.rawValue: paywallTest.rawValue as NSObject

        ]
    }
}
