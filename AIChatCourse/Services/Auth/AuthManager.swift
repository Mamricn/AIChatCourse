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
    
    
    init(service: AuthService) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    private func addAuthListener(){
        Task{
            for await value in service.addAutheticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }){
                self.auth = value
                print("Auth listener successed: \(value?.uid ?? "no uid")")
            }
        }
    }
    
    
    func getAuthId() throws -> String {
        
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
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
        try service.signOut()
        auth = nil
    }
    func deleteAccount() async throws{
        try await service.deleteAccount()
        auth = nil
    }
    
    
    
    enum AuthError: LocalizedError {
        case notSignedIn
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
