//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 28/02/2026.
//

import SwiftUI

struct MockAvatarService: AvatarService {
    
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))

        return  AvatarModel.mocks.shuffled()
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(3))
        return AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))

        return  AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))

        return  AvatarModel.mocks.shuffled()
    }
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
    
    
    
    
}
