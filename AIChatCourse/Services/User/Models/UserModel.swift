//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//
import Foundation
import SwiftUI


struct UserModel {
    
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    
    
    // set starting value to values above 
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .accent
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
                dateCreated: now.addingTimeInterval(-(45 * day)),
                didCompleteOnboarding: true,
                profileColorHex: "#4D96FF" 
            ),
            UserModel(
                userId: "user_002",
                // now - 30 days - 6 hours
                dateCreated: now.addingTimeInterval(-(30 * day + 6 * hour)),
                didCompleteOnboarding: false,
                profileColorHex: "#FF6B6B"
            ),
            UserModel(
                userId: "user_003",
                // now - 7 days + 3 hours (example of mixing +/-)
                dateCreated: now.addingTimeInterval(-(7 * day) + (3 * hour)),
                didCompleteOnboarding: nil,
                profileColorHex: "#6BCB77"
            ),
            UserModel(
                userId: "user_004",
                dateCreated: nil,
                didCompleteOnboarding: true,
                profileColorHex: nil
            )
        ]
    }

}
