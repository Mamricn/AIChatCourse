//
//  LogService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/03/2026.
//

import SwiftUI

protocol LogService {
    func identyfyUser(userId: String, name: String?, email: String?)
    func addUserPropeties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

