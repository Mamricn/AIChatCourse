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
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
              

        }
    }
}





class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        dependencies = Dependencies()
        
        return true
        
    }
}


@MainActor
struct Dependencies {
    
    let userManager: UserManager
    let authManager: AuthManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    
    
    init(){
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIService())
        avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistance())
    }
    
}



extension View {
    
    
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AppState())
    }
}
