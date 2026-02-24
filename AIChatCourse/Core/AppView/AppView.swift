//
//  AppView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    
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
            .onChange(of: appState.showTabBar) { _, showToBar in
                if !showToBar{
                    Task{
                        await checkUserStatus()
                    }
                }
            }
        }
    }
    
    
    
    
    func checkUserStatus() async {
        if let user = authManager.auth{
            //user is authenticated
            print("user already authenticated\(user.uid)")
        }else {
            //user is not auth
            
            do {
                let result = try await authManager.signInAnonymusly()
                print("sign in anonymusly succes \(result.user.uid)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
