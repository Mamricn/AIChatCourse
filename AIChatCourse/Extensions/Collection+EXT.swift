//
//  Collection+EXT.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 28/02/2026.
//




extension Collection {
    func first (upTo value: Int) -> [Element]? {
        guard !self.isEmpty else { return nil }
        let maxItems = Swift.min(count , value)
        
        return Array(prefix(maxItems))
    }
    
    func last (upTo value: Int) -> [Element]? {
        guard !self.isEmpty else { return nil }
        let maxItems = Swift.min(count , value)
        
        return Array(suffix(maxItems))
    }

}
