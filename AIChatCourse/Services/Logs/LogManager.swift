//
//  LogManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/03/2026.
//

import SwiftUI


@MainActor
@Observable
class LogManager {
    
    
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    
    
    func identyfyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identyfyUser(userId: userId, name: name, email: email)
        }
    }
    func addUserPropeties(dict: [String: Any]) {
        for service in services {
            service.addUserPropeties(dict: dict)
        }
    }
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }//
    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
    
    
}
