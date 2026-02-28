//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//

import SwiftUI







@MainActor
@Observable
class AvatarManager {
    
    
    private let services: AvatarService

    init(services: AvatarService) {
        self.services = services
    }
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        //Upload image
        try await services.createAvatar(avatar: avatar, image: image)
        
    }
    
    
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await services.getFeaturedAvatars( )
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await services.getPopularAvatars( )
    }
    
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await services.getAvatarForCategory(category: category)
    }
    
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await services.getAvatarsForAuthor(userId: userId)
    }
    
    
}
