//
//  AppView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct AppView: View {
    @AppStorage("ShowTabbarView")  var showTabBar: Bool = false
    var body: some View {
        ZStack {
            AppViewBuilder(
                showTabBar: showTabBar,
                tabbarView: {
                    TabBarView()
                },
                onboardingView: {
                    WelcomeView()
                }
            )
        }
        .animation(.smooth, value: showTabBar)
    }
}

#Preview("AppView - Tabbar") {
    AppView(showTabBar: true)
}
#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}
