//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 09/02/2026.
//

import SwiftUI
import Firebase

@main
struct AIChatCourseApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.userManager)
                .environment(delegate.authManager)
        }
    }
}





class AppDelegate: NSObject, UIApplicationDelegate {
    
    var userManager: UserManager!
    var authManager: AuthManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        
        
        return true
        
    }
}
