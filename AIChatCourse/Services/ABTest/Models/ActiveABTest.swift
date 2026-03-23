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
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOptions
    ){
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }

    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202603_CreateAccTest"
        case onboardingCommunityTest = "_202603_OnbCommTest"
        case categoryRowTest = "_202603_CategoryRowTest"
    }
    
    var eventParameters: [String: Any] {
        
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue

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
    }
    
    //Convert to a NSObject Dictionary to setDifaults within FirebaseABTestService
    var asNSObjectDictionary: [String : NSObject]? {
         [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject
        ]
    }
}
