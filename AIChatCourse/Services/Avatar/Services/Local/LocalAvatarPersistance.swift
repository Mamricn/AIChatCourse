//
//  LocalAvatarPersistance.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//


@MainActor
protocol LocalAvatarPersistance {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
