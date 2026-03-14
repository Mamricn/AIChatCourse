//
//  AppView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    
    @State var appState: AppState = AppState()
    
    
    var body: some View {
        ZStack {
            AppViewBuilder(
                showTabBar: appState.showTabBar,
                tabbarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView()
                }
            )
            .environment(appState)
            .task{
               await checkUserStatus()
            }
            .screenAppearAnalytics(name: "AppView")
            .onChange(of: appState.showTabBar) { _, showToBar in
                if !showToBar{
                    Task{
                        await checkUserStatus()
                    }
                }
            }
        }
    }
    
    
    enum Event: LoggableEvent {
        
        case existingAuthStart
        case existingFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)

        var eventName: String{
            
            switch self {
            case .existingAuthStart:         return "AppView_ExistingAuth_Start"
            case .existingFail:              return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:             return "AppView_AnonymousAuth_Start"
            case .anonAuthSuccess:           return "AppView_AnonymousAuth_Success"
            case .anonAuthFail:              return "AppView_AnonymousAuth_Fail"


            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .existingFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
            
            var type: LogType {
                switch self {
                    
                case .existingFail, .anonAuthFail:
                    return .severe
                default:
                    return .analytic
                }
            }
        
    }
        
    
    
    
    
    
    
    func checkUserStatus() async {
        if let user = authManager.auth{
            //user is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do{
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingFail(error: error))
                try? await Task.sleep(nanoseconds: 10)
                await checkUserStatus()
                
            }
            
            
        }else {
            //user is not auth
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await authManager.signInAnonymusly()
                logManager.trackEvent(event: Event.anonAuthSuccess)
                // log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)

            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(nanoseconds: 10)
                await checkUserStatus()
                
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()

}
#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()



}
