//
//  CategoryRowTestOptions.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 23/03/2026.
//

import SwiftUI

enum CategoryRowTestOptions: String, Codable, CaseIterable{
    case orgianl, top, hidden
    
    static var `default`: Self {
        .orgianl
    }
}
