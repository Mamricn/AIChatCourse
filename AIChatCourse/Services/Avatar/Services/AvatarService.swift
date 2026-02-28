//
//  AvatarService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 28/02/2026.
//

import SwiftUI

protocol AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]
}
