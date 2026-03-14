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






extension Dictionary where Key == String {
    
    
    mutating func first(upTo maxItems: Int ){
        var counter: Int = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
}
