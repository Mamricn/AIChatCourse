//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/03/2026.
//

import SwiftUI


protocol ABTestService {
    var activeTest: ActiveABTest { get }
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws
    
}




class MockABTestService: ABTestService {
    
    var activeTest: ActiveABTest
    
    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil){
        self.activeTest = ActiveABTest(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        activeTest = updatedTests
    }
    
}






struct ActiveABTest: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    
    init(createAccountTest: Bool, onboardingCommunityTest: Bool){
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202603_CreateAccTest"
        case onboardingCommunityTest = "_202603_OnbCommTest"
    }
    
    var eventParameters: [String: Any] {
        
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest

        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool){
        createAccountTest = newValue
    }
    mutating func update(onboardingCommunityTest newValue: Bool){
        onboardingCommunityTest = newValue
    }
}







class LocalABTestSerivce: ABTestService {
    @UserDefault(key: ActiveABTest.CodingKeys.createAccountTest.rawValue, startingValue: .random()) private var createAccountTest: Bool
    @UserDefault(key: ActiveABTest.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random()) private var onboardingCommunityTest: Bool

    
    var activeTest: ActiveABTest {
        ActiveABTest(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
    }
}






@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestService
    private let logManager: LogManager?
    
    var activeTest: ActiveABTest
    
    
    init(service: ABTestService, logManager: LogManager? = nil){
        self.logManager = logManager
        self.service = service
        self.activeTest = service.activeTest
        self.configure()
    }
    
    
    private func configure() {
        activeTest = service.activeTest
        logManager?.addUserPropeties(dict: activeTest.eventParameters, isHighPriority: false)
    }
    
    
    func override(updatedTest: ActiveABTest) throws {
       try service.saveUpdatedConfig(updatedTests: updatedTest)
        configure()
        
        
    }
    
}
