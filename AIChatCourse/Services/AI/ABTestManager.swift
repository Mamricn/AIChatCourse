//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/03/2026.
//

import SwiftUI




struct ActiveABTest: Codable {
    let createAccountTest: Bool
    
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
}








protocol ABTestService {
    var activeTest: ActiveABTest { get }
}


struct MockABTestService: ABTestService {
    
    let activeTest: ActiveABTest
    
    init(createAccountTest: Bool? = nil){
        self.activeTest = ActiveABTest(
            createAccountTest: createAccountTest ?? false
        )
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
        logManager?.addUserPropeties(dict: activeTest.eventParameters, isHighPriority: false)
    }
    
}
