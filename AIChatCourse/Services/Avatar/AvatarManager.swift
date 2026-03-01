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
    
    
    private var local: LocalAvatarPersistance
    private let remote: RemoteAvatarService

    init(service: RemoteAvatarService, local: LocalAvatarPersistance? = nil) {
        self.remote = service
        self.local = local ?? MockLocalAvatarPersistance()
    }
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try local.addRecentAvatar(avatar: avatar)
        try await remote.incrementAvatarClickCount(avatarId: avatar.id)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        //Upload image
        try await remote.createAvatar(avatar: avatar, image: image)
        
    }
    
    
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars( )
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars( )
    }
    
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarForCategory(category: category)
    }
    
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForAuthor(userId: userId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
    
    
}
