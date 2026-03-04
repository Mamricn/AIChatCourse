//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 03/03/2026.
//



protocol chatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    
}



struct MockChatService: chatService {
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
    
    func createNewChat(chat: ChatModel) async throws {
        
    }
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?{
        return ChatModel.mock
    }
    
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream{ continuation in
            
        }
    }
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: chatService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
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
    
    
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add  the message to chat sub-collection
        try  messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        
        //update chat dateModified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModyfired.rawValue: Date.now
        ])
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments()
    }
    
    
    
}


@MainActor
@Observable
class ChatManager {
    
    private let service: chatService
    
    init(service: chatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws  {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    
    
    func streamChatMessages(chatId: String)  -> AsyncThrowingStream<[ChatMessageModel], Error>  {
          service.streamChatMessages(chatId: chatId)
    }
    
}




