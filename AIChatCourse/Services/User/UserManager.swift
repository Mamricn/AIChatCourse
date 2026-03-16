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
    
    private let logManager: LogManager?
    
    private var listenerTask: Task<Void, Never>?

    
    
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
        self.logManager = logManager
        

    }
    
    
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        
        if isNewUser{
            let user = UserModel(auth: auth, creationVersion: Utilities.appVersion )
            logManager?.trackEvent(event: Event.logInStart(user: user))
            
            try await remote.saveUser(user: user)
            logManager?.trackEvent(event: Event.logInSuccess(user: user))
        }
        attachListener(userId: auth.uid)
    }
    
    
    
    private func attachListener(userId: String) {
        listenerTask?.cancel()
        logManager?.trackEvent(event: Event.remoteListenerStart)
        listenerTask = Task {
            do {
                for try await user in remote.streamUser(userId: userId){
                    self.currentUser = user
                    self.saveCurrentUserLocally()
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: user))
                    
                    logManager?.addUserPropeties(dict: user.eventParameters, isHighPriority: true)
                    logManager?.addUserPropeties(dict: Utilities.eventParameters, isHighPriority: false)
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    
    
    private func saveCurrentUserLocally(){
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))

        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
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
           logManager?.trackEvent(event: Event.SignOut)
       }
    
    
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
       let uid = try currentUserId()
        
        try await remote.deleteUser(userId: uid)
        signOut()
        logManager?.trackEvent(event: Event.deleteAccountSuccess)

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
    
    
    
    
    enum Event: LoggableEvent {
        
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case SignOut
        case deleteAccountStart
        case deleteAccountSuccess

        
        
        
        
        
        
        
        var eventName: String{
            
            switch self {
            case .logInStart:               return "UserManager_logIn_Start"
            case .logInSuccess:             return "UserManager_logIn_Success"
            case .remoteListenerStart:      return "UserManager_remoteListener_Start"
            case .remoteListenerSuccess:    return "UserManager_remoteListener_Success"
            case .remoteListenerFail:       return "UserManager_remoteListener_Fail"
            case .saveLocalStart:           return "UserManager_saveLocal_Start"
            case .saveLocalSuccess:         return "UserManager_saveLocal_Success"
            case .saveLocalFail:            return "UserManager_saveLocal_Fail"
            case .SignOut:                  return "UserManager_SignOut"
            case .deleteAccountStart:       return "UserManager_deleteAccount_Start"
            case .deleteAccountSuccess:     return "UserManager_deleteAccount_Success"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .remoteListenerFail(error: let error), .saveLocalFail(error: let error):
                return error.eventParameters
            case .logInStart(user: let user), .logInSuccess(user: let user), .remoteListenerSuccess(user: let user), .saveLocalSuccess(user: let user), .saveLocalStart(user: let user):
                return user?.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
                
            case .remoteListenerFail, .saveLocalFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}




//The Rule to Remember The uid from Auth is the bridge between the two systems. It's the same ID in both places. Whenever Auth tells you who someone is, you use their uid to go fetch the full picture from Firestore. Auth answers: "Is this person who they say they are?" Firestore answers: "What do we know about this person?"You always need both answers together to have a complete user in your app.

