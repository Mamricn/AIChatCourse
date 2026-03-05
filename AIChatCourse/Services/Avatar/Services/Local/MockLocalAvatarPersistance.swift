//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//


@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    let avatars: [AvatarModel]
    
    init(avatars : [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        avatars
    }
    
    
}
