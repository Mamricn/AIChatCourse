//
//  MockLocalAvatarPersistance.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//


@MainActor
struct MockLocalAvatarPersistance: LocalAvatarPersistance {
    
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    
    
}
