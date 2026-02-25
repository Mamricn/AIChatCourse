//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//


protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
    
}