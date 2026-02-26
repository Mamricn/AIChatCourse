//
//  AIService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//


import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
