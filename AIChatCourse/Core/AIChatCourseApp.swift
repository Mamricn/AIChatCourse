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
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
              

        }
    }
}





class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        
        let config: BuildConfiguration
        
        
#if MOCK
        config = .mock(isSignedIn: true)
#elseif DEV
        config = .dev
#else
        config = .prod
#endif
        
        config.configure()
        dependencies = Dependencies(config: config)
        return true
        
    }
}




enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    
    func configure() {
        switch self {
            case .mock:
            break
           case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        
        }
    }
    
}






@MainActor
struct Dependencies {
    
    let userManager: UserManager
    let authManager: AuthManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    
    
    
    init(config: BuildConfiguration){
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            logManager = LogManager(services: [
                ConsoleService(printParameters: false )
                
            ])
        case .dev:
            authManager = AuthManager(service: MockAuthService())
            userManager = UserManager(services: MockUserServices())
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            logManager = LogManager(services: [
                ConsoleService(),
                FirebaseAnalyticsService(),
                MixPanelService(token: Keys.mixPanelToken)
                
            ])
        case .prod:
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductionUserServices())
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatar())
            chatManager = ChatManager(service: FirebaseChatService())
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixPanelService(token: Keys.mixPanelToken)
            ])
        
        }
        
        

    }
    
}



extension View {
    
    
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(service: MockAIService()))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AppState())
            .environment(LogManager(services: []))
    }
}
