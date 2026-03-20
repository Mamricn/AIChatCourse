//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//



import OpenAI
import SwiftUI
import FirebaseFunctions



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
        
        
        let messages = chats.compactMap { chat in
            
            let role = chat.role.rawValue
            let content = chat.message
            return [
                "role": role,
                "content": content
            ]
        }
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIText").call([
            "messages": messages
        ])
        print("got reponse")
        print(response)
        print(response.data)
        
        guard
            let dict =  response.data as? [String: Any],
            let roleString = dict ["role"] as? String,
            let role = AIChatRole(rawValue: roleString),
            let conent = dict ["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        return AIChatModel(role: role, content: conent)
        
    }
    
    
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
        
    }
        
    }


struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }
    
    var eventParameters: [String: Any] {
        
        let dict: [String: Any?] = [
            "aichat_\(CodingKeys.role.rawValue)": role,
            "aichat_\(CodingKeys.message.rawValue)": message,

            
        ]
        
        return dict.compactMapValues({ $0 })
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

enum AIChatRole: String, Codable {
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
