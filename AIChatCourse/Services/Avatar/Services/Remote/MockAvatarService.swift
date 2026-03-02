//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 28/02/2026.
//

import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    
    
    let avatars: [AvatarModel]
    let deley: Double
    let showError: Bool
    
    init(avatars: [AvatarModel] = AvatarModel.mocks, deley: Double = 0.0, showError: Bool = false) {
        self.avatars = avatars
        self.deley = deley
        self.showError = showError
    }
    
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        guard let avatar = avatars.first(where: {$0.id == id}) else {
            throw URLError(.noPermissionsToReadFile)
        }
        try await Task.sleep(for: .seconds(deley))
        
        return  avatar
    }
    
    
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return  avatars.shuffled()
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return avatars.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return  avatars.shuffled()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return avatars.shuffled()
    }
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try tryShowError()
    }
    
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        
    }
    
    func removeAuthorIdFromAllAvatars(userId: String) async throws {
        
    }
    
}
