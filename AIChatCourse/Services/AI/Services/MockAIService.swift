//
//  MockAIService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//

import SwiftUI


struct MockAIService: AIService {
    
    func generateImage(input: String) async throws -> UIImage {
        try? await Task.sleep(for: .seconds(1))
        return UIImage(systemName: "circle.fill")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(nanoseconds: 40000)
        return AIChatModel(role: .assistant, content: "This is returned text from AI")
    }
}
