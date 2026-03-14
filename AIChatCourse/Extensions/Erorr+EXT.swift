//
//  Erorr+EXT.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 14/03/2026.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
