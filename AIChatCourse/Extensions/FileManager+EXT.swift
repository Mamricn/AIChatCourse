//
//  FileManager+EXT.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//

import Foundation



extension FileManager {
    
    static func saveDocument<T: Codable>(key: String, value: T?) throws {

        let data = try JSONEncoder().encode(value)
        let url = try getDocumentURL(for: key)
        try data.write(to: url)
    }
    
    
    
    
    static func getDocument<T: Codable>(key: String) throws -> T? {
        let url = try getDocumentURL(for: key)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    
    
    private static func getDocumentURL(for key: String) throws -> URL {
            FileManager.default
            .urls(for: .documentDirectory,
            in: .userDomainMask)
            .first!
            .appendingPathComponent("\(key).txt")
        
       
    }
}
