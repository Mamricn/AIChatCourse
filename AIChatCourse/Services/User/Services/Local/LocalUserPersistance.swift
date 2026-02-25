//
//  LocalUserPersistance.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//


protocol LocalUserPersistance {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
    
}