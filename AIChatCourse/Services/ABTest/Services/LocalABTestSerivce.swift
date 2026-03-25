//
//  LocalABTestSerivce.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//
import SwiftUI

@MainActor
class LocalABTestSerivce: ABTestService {
    
    
    
    @UserDefault(key: ActiveABTest.CodingKeys.createAccountTest.rawValue, startingValue: .random()) private var createAccountTest: Bool
    @UserDefault(key: ActiveABTest.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random()) private var onboardingCommunityTest: Bool
    
    @UserDefaultEnum(key: ActiveABTest.CodingKeys.categoryRowTest.rawValue, startingValue: CategoryRowTestOptions.allCases.randomElement()!) private var categoryRowTest: CategoryRowTestOptions
    @UserDefaultEnum(key: ActiveABTest.CodingKeys.paywallTest.rawValue, startingValue: PaywallTestOptions.allCases.randomElement()!) private var paywallTest: PaywallTestOptions


    
    var activeTest: ActiveABTest {
        ActiveABTest(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest,
            paywallTest: paywallTest
            
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
        categoryRowTest = updatedTests.categoryRowTest
        paywallTest = updatedTests.paywallTest
    }
    
    func featchUpdatedConfig() async throws -> ActiveABTest {
        activeTest
    }
    
}
