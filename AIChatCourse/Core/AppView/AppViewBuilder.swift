//
//  AppViewBuilder.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showTabBar: Bool
    @ViewBuilder var tabbarView: TabbarView
    @ViewBuilder var onboardingView: OnboardingView
    var body: some View {
        ZStack {
            if showTabBar {
                tabbarView
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}



private struct PreviewView: View {
    @State private var showTabBar: Bool = false
    var body: some View {
        ZStack {
            AppViewBuilder(
                showTabBar: showTabBar,
                tabbarView: {
                    ZStack {
                        Color.red.ignoresSafeArea()
                        Text("TabBar")
                    }
                },
                onboardingView: {
                    ZStack {
                        Color.blue.ignoresSafeArea()
                        Text("Onboarding")
                    }
                }
            )
        }
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}


#Preview {
    PreviewView()
}
