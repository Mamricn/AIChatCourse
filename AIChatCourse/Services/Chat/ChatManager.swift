//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 03/03/2026.
//



protocol chatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    
}



struct MockChatService: chatService {
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
    
    func createNewChat(chat: ChatModel) async throws {
        
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
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add  the message to chat sub-collection
        try  messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)
        
        
        //update chat dateModified
        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModyfired.rawValue: Date.now
        ])
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
    
    
}




