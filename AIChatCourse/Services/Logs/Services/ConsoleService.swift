//
//  ConsoleService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/03/2026.
//

import SwiftUI
import OSLog



actor LogSystem {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    
    nonisolated func log(level: LogType, message: String){
        Task {
            await log(level: level.OsLogType, message: message)
        }
    }
    
}

enum LogType {
    
    //Use "info" informative tasks. These are not considered analytics, issues, or errors.
    case info
    // Default type of analytics
    case analytic
    //Issues or error that should not occur, but will not negativly affect the user expereience
    case warning
    // issues or error that negativly affect user expirence
    case severe
    
    var emoji: String {
        switch self {
        case .info:
            return "👋"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "🚨"
        }
    }
    
    var OsLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .default
        case .warning:
            return .error
        case .severe:
            return .fault
        }
    }
}


struct ConsoleService: LogService {
    
    private let printParameters: Bool
    
    init(printParameters: Bool = true){
        self.printParameters = printParameters
    }
    
    
    let logger = LogSystem()
    
    func identyfyUser(userId: String, name: String?, email: String?) {
        let string = """
📈 Identify User 
userId: \(userId)
name: \(name ?? "Unknown")
email: \(email ?? "Unknown")
"""
        
        
        Task {
            logger.log(level: LogType.info, message: string)
        }
        
    }
    
    
    
    func addUserPropeties(dict: [String : Any], isHighPriority: Bool) {
        var string = """
📈 Log User Properties (isHighPriority: \(isHighPriority.description))

"""
        if printParameters{
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key]{
                    string += "\n key: \(key), value: \(value)"
                }
            }
        }
        
        logger.log(level: LogType.info, message: string)
    }
    
    func deleteUserProfile() {
        
        let string = """
📈 Delete User Profile



"""
        logger.log(level: LogType.info, message: string)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.type.emoji) \(event.eventName)"
        
        if printParameters, let parameters = event.parameters, !parameters.isEmpty{
                let sortedKeys = parameters.keys.sorted()
                for key in sortedKeys {
                    if let value = parameters[key]{
                        string += "\n key: \(key), value: \(value)"
                    }
                }
        }
        
      
        
        logger.log(level: event.type, message: string)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
    
    
}
