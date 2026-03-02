//
//  UserManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 24/02/2026.
//

import SwiftUI



@MainActor
@Observable
class UserManager {
    
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistence

    private(set) var currentUser: UserModel?
    
    private var listenerTask: Task<Void, Never>?

    
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
        

    }
    
    
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        
        if isNewUser{
            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion )
            try await remote.saveUser(user: user)
        }
        attachListener(userId: auth.uid)
    }
    
    private func attachListener(userId: String) {
        listenerTask?.cancel()
        listenerTask = Task {
            do {
                for try await user in remote.streamUser(userId: userId){
                    self.currentUser = user
                    self.saveCurrentUserLocally()
                    print("successfuly lisstend to user \(user)")
                }
            } catch {
                print("Stream error \(error)")
            }
        }
    }
    
    
    private func saveCurrentUserLocally(){
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                print("Success saved current user locally ")

            } catch {
                print("Error saving current user locally \(error)")
            }
        }
    }
    
    
    
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws{
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
        
        
    }

       
       func signOut() {
           listenerTask?.cancel()
           listenerTask = nil
           currentUser = nil
       }
    
    
    
    func deleteCurrentUser() async throws {
       let uid = try currentUserId()
        
        try await remote.deleteUser(userId: uid)
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




//The Rule to Remember The uid from Auth is the bridge between the two systems. It's the same ID in both places. Whenever Auth tells you who someone is, you use their uid to go fetch the full picture from Firestore. Auth answers: "Is this person who they say they are?" Firestore answers: "What do we know about this person?"You always need both answers together to have a complete user in your app.

