//
//  MockABTestService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//
import SwiftUI


class MockABTestService: ABTestService {
    func featchUpdatedConfig() async throws -> ActiveABTest {
        activeTest
    }
    
    
    var activeTest: ActiveABTest
    
    init(
        createAccountTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOptions? = nil
    ){
        self.activeTest = ActiveABTest(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        activeTest = updatedTests
    }
    
}
