//
//  chatService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 10/03/2026.
//


protocol chatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReportModel) async throws
    
}

