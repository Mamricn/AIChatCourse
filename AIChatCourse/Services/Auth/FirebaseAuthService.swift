//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 21/02/2026.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync



struct FirebaseAuthService: AuthService {
    
    func getAuthenticatedUser() -> UserAuthInfo?{
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func signInAnonymusly() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
       let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
        
        
    }
    
    
    
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        
        let credential  = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        
        if let user = Auth.auth().currentUser, user.isAnonymous{
            do {
                // try to link to exisitng annonymous account
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError{
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredencial = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await user.link(with: secondaryCredencial)
                        return result.asAuthInfo
                    }
                    break
                default:
                    break
                }
            }
        }
        
        // otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
        
    }
    
    
    
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    
    
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
           throw AuthError.userNotFound
        }
        
        try await user.delete()
    }
    
    
    
    
    
    enum AuthError: LocalizedError{
        case userNotFound
        
        var errorDescription: String? {
            switch self{
            case .userNotFound:
                return "Current authenticated user not found"
            }
        }
        
    }
}


extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? false
        return (user, isNewUser)
    }
}
