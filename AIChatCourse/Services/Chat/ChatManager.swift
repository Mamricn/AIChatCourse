//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 03/03/2026.
//



protocol chatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    
}



struct MockChatService: chatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: chatService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
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
    
    
}




