//
//  LogService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/03/2026.
//

import SwiftUI

protocol LogService {
    func identyfyUser(userId: String, name: String?, email: String?)
    func addUserPropeties(dict: [String: Any])
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
