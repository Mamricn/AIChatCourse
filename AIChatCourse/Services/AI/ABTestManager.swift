//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/03/2026.
//

import SwiftUI




struct ActiveABTest: Codable {
    private(set) var createAccountTest: Bool
    
    init(createAccountTest: Bool){
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202603_CreateAccTest"
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
}








protocol ABTestService {
    var activeTest: ActiveABTest { get }
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws
    
}


class MockABTestService: ABTestService {
    
    var activeTest: ActiveABTest
    
    init(createAccountTest: Bool? = nil){
        self.activeTest = ActiveABTest(
            createAccountTest: createAccountTest ?? false
        )
    }
    
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        activeTest = updatedTests
    }

    
    
    
}

class LocalABTestSerivce: ABTestService {
    @UserDefault(key: ActiveABTest.CodingKeys.createAccountTest.rawValue, startingValue: .random()) private var createAccountTest: Bool
    
    var activeTest: ActiveABTest {
        ActiveABTest(
            createAccountTest: createAccountTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        createAccountTest = updatedTests.createAccountTest
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
