//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//



import SwiftUI
import FirebaseFunctions



struct OpenAIService: AIService {

    
    func generateImage(input: String) async throws -> UIImage {
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])
        
        

        
        guard let b64Json = response.data as? String,
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
}
    
    
    
    
enum AIChatRole: String, Codable {
        case user, system, assistant, tool, developer
    }
