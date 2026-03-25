//
//  PaywallTestOptions.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/03/2026.
//


import SwiftUI

enum PaywallTestOptions: String, Codable, CaseIterable{
    case custom
    
    static var `default`: Self {
        .custom
    }
}
