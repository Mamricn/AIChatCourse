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


@MainActor
protocol ABTestService {
    var activeTest: ActiveABTest { get }
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws
    func featchUpdatedConfig() async throws -> ActiveABTest
    
}




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






@MainActor
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
    
    func featchUpdatedConfig() async throws -> ActiveABTest {
        activeTest
    }
    
}

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


import FirebaseRemoteConfig
@MainActor
class FirebaseABService: ABTestService {
    var activeTest: ActiveABTest {
        ActiveABTest(config: RemoteConfig.remoteConfig())
    }
    
    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        let defaultValues = ActiveABTest(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default
        )
        RemoteConfig.remoteConfig().setDefaults(defaultValues.asNSObjectDictionary)
        RemoteConfig.remoteConfig().activate()
    }
    
    
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws {
        assertionFailure("Error: Firebase AB Tests are not configuable from the client.")
    }
    
    
    
    
    func featchUpdatedConfig() async throws -> ActiveABTest {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        
        switch status {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return activeTest
        case .error:
            throw RemoteConfigError.failedToFetch
        default:
            throw RemoteConfigError.failedToFetch
        }
    }
    enum RemoteConfigError: LocalizedError {
        case failedToFetch
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

