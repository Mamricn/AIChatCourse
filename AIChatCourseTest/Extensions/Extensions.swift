

//
//  Extensions.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/03/2026.
//

import Foundation

// MARK: - String

extension String {
    
    static func random(length: Int = 10) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    static func randomEmail() -> String {
        return "\(random(length: 6))@\(random(length: 5)).com"
    }
    
    static func randomDateString() -> String {
        ISO8601DateFormatter().string(from: .random())
    }
}

// MARK: - Bool

extension Bool {
    static var random: Bool {
        Swift.Bool.random()
    }
}

// MARK: - Date

extension Date {
    
    static func random(
        from start: Date = Date(timeIntervalSince1970: 0),
        to end: Date = Date()
    ) -> Date {
        let interval = end.timeIntervalSince(start)
        let randomInterval = TimeInterval.random(in: 0...interval)
        return start.addingTimeInterval(randomInterval)
    }
}
