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
    
    
}
