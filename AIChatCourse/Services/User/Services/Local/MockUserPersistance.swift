//
//  MockUserPersistance.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//


struct MockUserPersistance: LocalUserPersistance {
    
    let currentUser: UserModel?
    
    
    init(user: UserModel?){
        self.currentUser = user
    }
    
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        
    }
    
    
}