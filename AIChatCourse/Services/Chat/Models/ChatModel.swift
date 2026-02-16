//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 15/02/2026.
//

import Foundation




struct ChatModel: Identifiable {
     
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModyfired: Date
    
    
    
    
    static var mock: ChatModel {
        mocks[0]
    }
    
    
    static var mocks: [ChatModel]{
        let now = Date()
            return [
                ChatModel(
                    id: "mock_chat_001",
                    userId: "user_001",
                    avatarId: "avatar_001",
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
                ChatModel(
                    id: "mock_chat_002",
                    userId: "user_002",
                    avatarId: "avatar_002",
                    dateCreated: now.addingTimeInterval(days: -3, hours: -6),
                    dateModyfired: now.addingTimeInterval(hours: -2)
                ),
                ChatModel(
                    id: "mock_chat_003",
                    userId: "user_003",
                    avatarId: "avatar_003",
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
                ChatModel(
                    id: "mock_chat_004",
                    userId: "user_004",
                    avatarId: "avatar_004",
                    dateCreated: now.addingTimeInterval(days: -10),
                    dateModyfired: now.addingTimeInterval(days: -2, hours: -3)
                ),
            ]
    }
    
}
