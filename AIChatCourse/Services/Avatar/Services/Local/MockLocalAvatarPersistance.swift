//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//


@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
    
    
}
