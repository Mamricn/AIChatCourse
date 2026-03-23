//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//


@MainActor
protocol ABTestService {
    var activeTest: ActiveABTest { get }
    func saveUpdatedConfig(updatedTests: ActiveABTest) throws
    func featchUpdatedConfig() async throws -> ActiveABTest
    
}