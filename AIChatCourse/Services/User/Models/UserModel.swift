//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//
import Foundation
import SwiftUI


struct UserModel: Codable {
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let lastSignInDate: Date?
    let creationVersion: String?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date?  = nil,
        lastSignInDate: Date?  = nil,
        creationVersion: String?  = nil,
        didCompleteOnboarding: Bool?  = nil,
        profileColorHex: String?  = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.creationVersion = creationVersion
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    
    init(auth: UserAuthInfo, creationVersion: String?){
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            lastSignInDate: auth.lastSignInDate,
            creationVersion: creationVersion
        )
    }
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case creationVersion = "creation_version"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }
    
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .pink
        }
        return Color(hex: profileColorHex )
    }
    
    
    static var mock: Self {
        mocks[0]
    }
    
    
    static var mocks: [Self] {
        let now = Date()
        let day: TimeInterval = 24 * 60 * 60
        let hour: TimeInterval = 60 * 60

        return [
            UserModel(
                userId: "user_001",
                // now - 45 days
                creationDate: now.addingTimeInterval(-(45 * day)),
                didCompleteOnboarding: true,
                profileColorHex: "#4D96FF" 
            ),
            UserModel(
                userId: "user_002",
                // now - 30 days - 6 hours
                creationDate: now.addingTimeInterval(-(30 * day + 6 * hour)),
                didCompleteOnboarding: false,
                profileColorHex: "#FF6B6B"
            ),
            UserModel(
                userId: "user_003",
                // now - 7 days + 3 hours (example of mixing +/-)
                creationDate: now.addingTimeInterval(-(7 * day) + (3 * hour)),
                didCompleteOnboarding: nil,
                profileColorHex: "#6BCB77"
            ),
            UserModel(
                userId: "user_004",
                creationDate: nil,
                didCompleteOnboarding: true,
                profileColorHex: nil
            )
        ]
    }

}
