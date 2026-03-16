//
//  AuthManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 24/02/2026.
//

import SwiftUI

@MainActor
@Observable
class AuthManager {
    
    
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    private let logManager: LogManager?
    
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
       
    }
    
    private func addAuthListener(){
        logManager?.trackEvent(event: Event.authListenerStart)
        Task{
            for await value in service.addAutheticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
                

            }){
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                if let value {
                    logManager?.identyfyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserPropeties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserPropeties(dict: Utilities.eventParameters, isHighPriority: false)
                }
            }
        }
    }
    
    
    func getAuthId() throws -> String {
        //start
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
            //success string
        }
        return uid
    }
    
    func signInAnonymusly() async throws -> (user: UserAuthInfo, isNewUser: Bool){
        try await service.signInAnonymusly()
    }
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool){
        try await service.signInApple()
    }
    func signOut() throws{
        logManager?.trackEvent(event: Event.signOutStart)

        try service.signOut()
        auth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)

    }
    func deleteAccount() async throws{
        logManager?.trackEvent(event: Event.deleteAccountStart)

        try await service.deleteAccount()
        auth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

    }
    
    
    
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    
    
    
    
    enum Event: LoggableEvent {
    
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess

        
        
        var eventName: String{
            switch self {
                
            case .authListenerStart:            return "AuthManager_authListener_Start"
            case .authListenerSuccess:          return "AuthManager_authListener_Success"
            case .signOutStart:                 return "AuthManager_signOut_Start"
            case .signOutSuccess:               return "AuthManager_signOut_Success"
            case .deleteAccountStart:           return "AuthManager_deleteAccount_Start"
            case .deleteAccountSuccess:         return "AuthManager_deleteAccount_Success"
                
                
                
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParameters

                
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}

//
//protocol AuthService: Sendable {
//    func getAuthenticatedUser() -> UserAuthInfo?
//    func signInAnonymusly() async throws -> (user: UserAuthInfo, isNewUser: Bool)
//    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
//    func signOut() throws
//    func deleteAccount() async throws
//}
