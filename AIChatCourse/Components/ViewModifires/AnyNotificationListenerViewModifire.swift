//
//  AnyNotificationListenerViewModifire.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 18/03/2026.
//


import Foundation
import SwiftUI


struct AnyNotificationListenerViewModifire: ViewModifier {
    
    
    let notificationName: Notification.Name
    let onNotificationRecipe: @MainActor (Notification) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName ), perform: { notification in
                onNotificationRecipe(notification)
            })
    }
}
extension View {
    func onNotificationReceived(name: Notification.Name, action: @MainActor @escaping(Notification) -> Void) -> some View {
        modifier(AnyNotificationListenerViewModifire(notificationName: name, onNotificationRecipe: action))
    }
}

//    .onReceive(Notification.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { notification in
//        Task {
//            await checkUserStatus()
//        }
//    })
