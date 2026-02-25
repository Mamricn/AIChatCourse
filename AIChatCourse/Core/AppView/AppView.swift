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
        .environment(UserManager(service: MockUserService(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))

}
#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(service: MockUserService(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))


}
