//
//  TextValidationHelper.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 19/02/2026.
//

import Foundation

struct TextValidationHelper {
    
    enum TextvalidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        
        var errorDescription: String? {
            switch self{
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters."
                
            case .hasBadWords:
                return "Bad word decteded. Please rephrease your message."
            }
        }
        
        
        
    }
    
    
    
    static func checkIfMessageIsValid(text: String, miniumCharacters: Int = 3) throws {
        
        
        guard text.count >= 3 else { throw TextvalidationError.notEnoughCharacters(min: miniumCharacters) }
        
        
        let badWords: [String] = ["shit", "bitch" , "ass"]
        
        if badWords.contains(text.lowercased()){
           throw TextvalidationError.hasBadWords
        }
    }
    
}
