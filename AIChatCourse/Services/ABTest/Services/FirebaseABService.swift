//
//  FirebaseABService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//


import FirebaseRemoteConfig
import SwiftUI



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
