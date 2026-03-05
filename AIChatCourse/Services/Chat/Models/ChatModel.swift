//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 15/02/2026.
//

import Foundation
import IdentifiableByString




struct ChatModel: Identifiable, Codable, Hashable, StringIdentifiable {
    
     
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModyfired: Date
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModyfired = "date_modified"
    }
    
    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }
    
    
    static func new(userId: String, avatarId: String) -> Self {
        
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModyfired: .now
        )
    }
    
    
    static var mock: Self {
        mocks[0]
    }
    
    
    static var mocks: [Self]{
        let now = Date()
            return [
                ChatModel(
                    id: "mock_chat_001",
                    userId: UserAuthInfo.mock().uid,
                    avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
                ChatModel(
                    id: "mock_chat_002",
                    userId: UserAuthInfo.mock().uid,
                    avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                    dateCreated: now.addingTimeInterval(days: -3, hours: -6),
                    dateModyfired: now.addingTimeInterval(hours: -2)
                ),
                ChatModel(
                    id: "mock_chat_003",
                    userId: UserAuthInfo.mock().uid,
                    avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
                ChatModel(
                    id: "mock_chat_004",
                    userId: UserAuthInfo.mock().uid,
                    avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
            ]
    }
    
}
