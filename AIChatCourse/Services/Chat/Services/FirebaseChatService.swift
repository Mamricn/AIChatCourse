//
//  FirebaseChatService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 10/03/2026.
//


import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: chatService {
    
    
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    private var chatReportColleciton: CollectionReference {
        Firestore.firestore().collection("chat_reports")
    }
    
    
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        //        let result: [ChatModel] = try await collection
        //            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
        //            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
        //            .getAllDocuments()
        //
        //
        //        return result.first
        
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add  the message to chat sub-collection
        try  messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        
        //update chat dateModified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModyfired.rawValue: Date.now
        ])
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await messagesCollection(chatId: chatId).document(messageId).updateData([
            ChatMessageModel.CodingKeys.seenByIds.rawValue: FieldValue.arrayUnion([userId])
        ])
    }
    
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.dateCrated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
    }
    
    
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
    
    func deleteChat(chatId: String) async throws {
        async let deleteChat: () = collection.deleteDocument(id: chatId)
        async let deleteMessage: () = messagesCollection(chatId: chatId).deleteAllDocuments()
        let (_, _) =  await (try  deleteChat, try  deleteMessage)
    }
    
    
    
    func deleteAllChatsForUser(userId: String) async throws {
        let chats = try await getAllChats(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in chats {
                group.addTask {
                    try await deleteChat(chatId: chat.id)
                }
            }
            try await group.waitForAll()
        }
    }
        
        func reportChat(report: ChatReportModel) async throws {
            try await chatReportColleciton.setDocument(document: report)
        }
        
        
    }
    
