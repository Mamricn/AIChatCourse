//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//

import Foundation

struct ChatMessageModel {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByids: [String]?
    let dateCrated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
        seenByids: [String]? = nil,
        dateCrated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByids = seenByids
        self.dateCrated = dateCrated
    }
    
    
    static var mock: ChatMessageModel {
        mocks[0]
    }
    
    
    static var mocks: [ChatMessageModel] {
           let now = Date()
           
           return [
               ChatMessageModel(
                   id: "msg_001",
                   chatId: "chat_001",
                   authorId: "user_001",
                   content: "Hey 👋",
                   seenByids: ["user_001"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -3)
               ),
               ChatMessageModel(
                   id: "msg_002",
                   chatId: "chat_001",
                   authorId: "user_002",
                   content: "Hi! How are you?",
                   seenByids: ["user_001", "user_002"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -2, minutes: -40)
               ),
               ChatMessageModel(
                   id: "msg_003",
                   chatId: "chat_001",
                   authorId: "user_001",
                   content: "All good — you?",
                   seenByids: ["user_001"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -2, minutes: -15)
               ),
               ChatMessageModel(
                   id: "msg_004",
                   chatId: "chat_002",
                   authorId: "user_003",
                   content: "Welcome to the new chat!",
                   seenByids: ["user_003"],
                   dateCrated: now.addingTimeInterval(days: -1, hours: -6)
               ),
               ChatMessageModel(
                   id: "msg_005",
                   chatId: "chat_002",
                   authorId: "user_001",
                   content: "Nice 🙌",
                   seenByids: ["user_001", "user_003"],
                   dateCrated: now.addingTimeInterval(hours: -3, minutes: -20)
               ),
               ChatMessageModel(
                   id: "msg_006",
                   chatId: "chat_003",
                   authorId: "user_002",
                   content: "Are we still on for today?",
                   seenByids: nil,
                   dateCrated: now.addingTimeInterval(minutes: -25)
               )
           ]
       }
}
