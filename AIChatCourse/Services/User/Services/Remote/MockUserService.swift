//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//


struct  MockUserService: RemoteUserService{
    
    let currentUser: UserModel?
    
    
    init(user: UserModel? = nil){
        self.currentUser = user
    }
    
    
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            continuation.finish()
        }
    }
    
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func deleteUser(userId: String) async throws {
        
    }
    
    
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        
    }
    
    
    
}