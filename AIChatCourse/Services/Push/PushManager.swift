//
//  PushManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 17/03/2026.
//

import Foundation
import SwiftfulUtilities

@MainActor
@Observable
class PushManager {
    
   private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
       let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserPropeties(dict: [ "push_is_authorized" : isAuthorized ], isHighPriority: true)
        return isAuthorized
        
    }
    
    func canRequestAuthroization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationForTheNextWeek(){
        
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            
            do {
                //Tomorrow
                try await scheduleNotifcation(
                    title: "Hey you ready to chat?",
                    subtitle: "Open AIChat to begin",
                    triggerDate:  Date().addingTimeInterval( days: 1 )
                )
                //in 3 days
                try await scheduleNotifcation(
                    title: "Someone sent you a message?",
                    subtitle: "Open AIChat to respond",
                    triggerDate:  Date().addingTimeInterval(days: 3 )
                )
                // in 5 days
                try await scheduleNotifcation(
                    title: "Hey strange. We miss you!?",
                    subtitle: "Don'f forget us.",
                    triggerDate:  Date().addingTimeInterval( days: 5 )
                )
                
                logManager?.trackEvent(event: Event.weekScheduledSuccess)

            } catch {
                logManager?.trackEvent(event: Event.weekSecheduledFail(error: error))
            }
        }
    }
    private func scheduleNotifcation(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title,body: subtitle)
        let trigger = NotificationTriggerOption.date(date: triggerDate, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
    
    
    
    enum Event: LoggableEvent {
        
        case weekScheduledSuccess
        case weekSecheduledFail(error: Error)
        
        
        var eventName: String{
            
            switch self {
            case .weekScheduledSuccess:                 return "PushManager_WeekScheduled_Success"
            case .weekSecheduledFail:                   return "PushManager_WeekScheduled_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .weekSecheduledFail(error: let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
                
            case .weekSecheduledFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    
}
