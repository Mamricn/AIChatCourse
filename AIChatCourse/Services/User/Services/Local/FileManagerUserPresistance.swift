//
//  FileManagerUserPresistance.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//


import SwiftUI


struct FileManagerUserPresistance: LocalUserPersistence {
    private let userDocumentkey = "current_user"
    
    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentkey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentkey, value: user)
    }
}
