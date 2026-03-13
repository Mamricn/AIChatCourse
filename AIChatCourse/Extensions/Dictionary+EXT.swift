//
//  Dictionary+EXT.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/03/2026.
//


import Foundation
extension Dictionary where Key == String, Value == Any {
    
    var asAlphaticalArray: [(key: String, value: Any)] {
        self
        .map({ (key: $0, value: $1) }).sortedByKeyPath(keyPath: \.key)
    }
}
