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
            .onAppear {
                logManager
                .identyfyUser(userId: "xd", name: "xdd", email: "xdd@wp.pl")
                logManager.addUserPropeties(dict: UserModel.mock.eventParameters)
                
                
                logManager.trackEvent(event: Event.alpha)
                logManager.trackEvent(event: Event.beta)
                logManager.trackEvent(event: Event.gamma)
                logManager.trackEvent(event: Event.delta)

                
                
            }
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
        
        case alpha, beta, gamma, delta
        
        var eventName: String{
            
            switch self {
            case .alpha:
                return "alpha"
            case .beta:
                return "beta"
            case .gamma:
                return "gamma"
            case .delta:
                return "delta"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .alpha, .beta:
                return [
                    "aaa": true,
                    "bbb": 123
                ]
            default:
                return nil
                
            }
        }
            
            var type: LogType {
                switch self {
                case .alpha:
                    return .info
                case .beta:
                    return .analytic
                case .gamma:
                    return .warning
                case .delta:
                    return .severe
                }
            }
        
    }
        
    
    
    
    
    
    
    func checkUserStatus() async {
        if let user = authManager.auth{
            //user is authenticated
            print("user already authenticated\(user.uid)")
            
            do{
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print("Failed to log in to auth for existing user \(error)")
                try? await Task.sleep(nanoseconds: 10)
                await checkUserStatus()
                
            }
            
            
        }else {
            //user is not auth
            
            do {
                let result = try await authManager.signInAnonymusly()
                print("sign in anonymusly succes \(result.user.uid)")
                // log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)

            } catch {
                print("faild to sign in anonymusly and log in \(error)")
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
