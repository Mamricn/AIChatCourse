//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//



import OpenAI
import SwiftUI



struct OpenAIService: AIService {

    
    var openAI: OpenAI {
        OpenAI(apiToken: "")
    }
    
    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .chatgpt_4o_latest,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._512,
            style: .natural,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        
        let messages = chats.compactMap({$0.toOpenAIModel()})
        
        let query = ChatQuery( messages: messages, model: .gpt3_5Turbo )
        
        
        let result = try await openAI.chats(query: query)
        
        guard
            let chat = result.choices.first?.message,
            let model = AIChatModel(chat: chat)
        
        else {
            throw OpenAIError.invalidResponse
        }
        return model
    }
    
    
    
    
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
        
    }
        
    }


struct AIChatModel {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    init?(chat: ChatResult.Choice.Message) {
        self.role = AIChatRole(role: chat.role)
        
        guard let string = chat.content?.description else {
            return nil
        }
        self.message = string
    }
    
    func toOpenAIModel() -> ChatQuery.ChatCompletionMessageParam? {
        ChatQuery.ChatCompletionMessageParam(role: .user, content: message)
    }
}

enum AIChatRole {
case user, system, assistant, tool, developer

    init(role: String) {
        switch role {
        case "system":
            self = .system
        case "user":
            self = .user
        case "assistant":
            self = .assistant
        case "tool":
            self = .tool
        case "developer":
            self = .developer
        default:
            self = .developer
        }
    }

    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .system:
            return .system
        case .assistant:
            return .assistant
        case .tool:
            return .tool
        case .developer:
            return .developer
        }
    }
}
