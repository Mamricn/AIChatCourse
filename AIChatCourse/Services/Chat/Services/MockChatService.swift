//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 10/03/2026.
//

import SwiftUI

struct MockChatService: chatService {
   
    
    
    let chats: [ChatModel]
    let deley: Double
    let showError: Bool
    
    init(chats: [ChatModel] = ChatModel.mocks, deley: Double = 0.0, showError: Bool = false){
        self.chats = chats
        self.deley = deley
        self.showError = showError
    }
    
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    
   
    
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    
  
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return chats.first { chat in
          return chat.userId == userId && chat.avatarId == avatarId
      }
    }
    
    
    func getAllChats(userId: String) async throws -> [ChatModel]  {
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
       return chats
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?{
        try await Task.sleep(for: .seconds(deley))
        try tryShowError()
        return  ChatMessageModel.mocks.randomElement( )
    }
    
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream{ continuation in
            
        }
    }
    
    
    
    func deleteChat(chatId: String) async throws{
        
    }
    func deleteAllChatsForUser(userId: String) async throws{
        
    }
    
    func reportChat(report: ChatReportModel) async throws {
        
    }
   
}
