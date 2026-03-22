//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/03/2026.
//

import SwiftUI




enum CategoryRowTestOptions: String, Codable, CaseIterable{
    case orgianl, top, hidden
    
    static var `default`: Self {
        .orgianl
    }
}



protocol ABTestService {
    var activeTest: ActiveABTest { get }
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws
    
}




class MockABTestService: ABTestService {
    
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






struct ActiveABTest: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOptions
    
    init(createAccountTest: Bool, onboardingCommunityTest: Bool, categoryRowTest: CategoryRowTestOptions){
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







class LocalABTestSerivce: ABTestService {
    @UserDefault(key: ActiveABTest.CodingKeys.createAccountTest.rawValue, startingValue: .random()) private var createAccountTest: Bool
    @UserDefault(key: ActiveABTest.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random()) private var onboardingCommunityTest: Bool
    
    @UserDefaultEnum(key: ActiveABTest.CodingKeys.categoryRowTest.rawValue, startingValue: CategoryRowTestOptions.allCases.randomElement()!) private var categoryRowTest: CategoryRowTestOptions


    
    var activeTest: ActiveABTest {
        ActiveABTest(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest,
            categoryRowTest: categoryRowTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
        categoryRowTest = updatedTests.categoryRowTest
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

