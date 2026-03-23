//
//  ABTestManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/03/2026.
//

import SwiftUI





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
        
        Task {
            do {
                activeTest = try await service.featchUpdatedConfig()
                logManager?.addUserPropeties(dict: activeTest.eventParameters, isHighPriority: false)
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
        
    }
    
    
    func override(updatedTest: ActiveABTest) throws {
       try service.saveUpdatedConfig(updatedTests: updatedTest)
        configure()
        
        
    }
    
    
    
    enum Event: LoggableEvent {
        
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        
        var eventName: String{
            
            switch self {
            case .fetchRemoteConfigSuccess:  return "ABTestManager_fetchRemoteConfig_Success"
            case .fetchRemoteConfigFail:     return "ABTestManager_fetchRemoteConfig_Fail "
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .fetchRemoteConfigFail(let error):
                return error.eventParameters
                
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .fetchRemoteConfigFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    
    
}

