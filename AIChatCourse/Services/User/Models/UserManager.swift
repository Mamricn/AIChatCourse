//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 24/02/2026.
//

import SwiftUI






protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func getUser(userId: String) async throws -> UserModel?
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}

struct  MockUserService: UserService{
    func getUser(userId: String) async throws -> UserModel? {
        return currentUser
    }
    
    
    let currentUser: UserModel?
    
    
    init(user: UserModel? = nil){
        self.currentUser = user
    }
    
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func deleteUser(userId: String) async throws {
        
    }
    
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        
    }
    
    
}


import FirebaseFirestore
import SwiftfulFirestore
struct FirebaseUserService: UserService{
    func getUser(userId: String) async throws -> UserModel? {
        try await collection.document(userId).getDocument(as: UserModel.self)
    }
    
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        
        try  collection.document(user.userId).setData(from: user, merge: true)
        
    }
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
    
}






@MainActor
@Observable
class UserManager {
    
    
    private let service: UserService
    private(set) var currentUser: UserModel?
    
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        if isNewUser {
            let creationVersion = Utilities.appVersion
            let user = UserModel(auth: auth, creationVersion: creationVersion)
            try await service.saveUser(user: user)
            self.currentUser = user
        } else {
            // Fetch existing user from Firestore to get profileColorHex, etc.
            if let existingUser = try await service.getUser(userId: auth.uid) {
                self.currentUser = existingUser
            } else {
                // Fallback: shouldn't happen, but handle gracefully
                let user = UserModel(auth: auth, creationVersion: nil)
                try await service.saveUser(user: user)
                self.currentUser = user
            }
        }
    }
    
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws{
        let uid = try currentUserId()
        try await service.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
        
        
    }
    
    
    
    func signOut(){
        currentUser = nil
    }
    
    
    
    func deleteCurrentUser() async throws {
       let uid = try currentUserId()
        
        try await service.deleteUser(userId: uid)
        signOut()
    }
    
    
    
    private func currentUserId() throws -> String{
        
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
            
        }
        return uid
    }
    
    
    
    
    
    enum UserManagerError: LocalizedError {
        case noUserId

    }
    
}


//
//The Rule to Remember
//The uid from Auth is the bridge between the two systems. It's the same ID in both places. Whenever Auth tells you who someone is, you use their uid to go fetch the full picture from Firestore.
//Auth answers: "Is this person who they say they are?"
//Firestore answers: "What do we know about this person?"
//You always need both answers together to have a complete user in your app.
