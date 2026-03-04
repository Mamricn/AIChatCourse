//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//

import Foundation

struct ChatMessageModel: Identifiable, Codable{
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCrated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCrated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCrated = dateCrated
    }
    
    var dateCratedCalculated: Date {
        dateCrated ?? .distantPast
    }
    
    func hasBeenSeenBy(userId: String) -> Bool{
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCrated = "date_created"
    }
    
    
    
    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCrated: .now
        )
    }
    static func newIAMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId:chatId,
            authorId: avatarId ,
            content: message,
            seenByIds: [],
            dateCrated: .now
        )
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
                   authorId: UserAuthInfo.mock().uid,
                   content: AIChatModel(role: .user, content: "Hello how are you?"),
                   seenByIds: ["user_001"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -3)
               ),
               ChatMessageModel(
                   id: "msg_002",
                   chatId: "chat_001",
                   authorId: AvatarModel.mock.avatarId,
                   content: AIChatModel(role: .assistant, content: "Im doing well, thanks for asking!"),
                   seenByIds: ["user_001", "user_002"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -2, minutes: -40)
               ),
               ChatMessageModel(
                   id: "msg_003",
                   chatId: "chat_001",
                   authorId: UserAuthInfo.mock().uid,
                   content: AIChatModel(role: .user, content: "Alright"),
                   seenByIds: ["user_001"],
                   dateCrated: now.addingTimeInterval(days: -2, hours: -2, minutes: -15)
               ),
               ChatMessageModel(
                   id: "msg_004",
                   chatId: "chat_002",
                   authorId: AvatarModel.mock.avatarId,
                   content: AIChatModel(role: .assistant, content: "Welcome to the new chat!"),
                   seenByIds: ["user_003"],
                   dateCrated: now.addingTimeInterval(days: -1, hours: -6)
               ),
               ChatMessageModel(
                   id: "msg_005",
                   chatId: "chat_002",
                   authorId: UserAuthInfo.mock().uid,
                   content: AIChatModel(role: .user, content: "Nice"),
                   seenByIds: ["user_001", "user_003"],
                   dateCrated: now.addingTimeInterval(hours: -3, minutes: -20)
               ),
               ChatMessageModel(
                   id: "msg_006",
                   chatId: "chat_003",
                   authorId: AvatarModel.mock.avatarId,
                   content: AIChatModel(role: .assistant, content: "Are we still on for today?"),
                   seenByIds: nil,
                   dateCrated: now.addingTimeInterval(minutes: -25)
               )
           ]
       }
}
