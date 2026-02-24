//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 24/02/2026.
//

import Foundation

struct MockAuthService: AuthService {
    let currentUser: UserAuthInfo?
    
    init(user: UserAuthInfo? = nil){
        self.currentUser = user
    }
    
    
    func addAutheticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>{
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }
    
    func signInAnonymusly() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
    
    
}
