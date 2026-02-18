//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/02/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @State private var isCompletingProfileSetup: Bool = false
    
    var selectedColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading,spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            Text("We've set up for profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                title: "Finish",
                isLoading: isCompletingProfileSetup,
                action: onFinishButtonPressed
            )
        })
        .toolbar(.hidden, for: .navigationBar)
        .padding(16)
    }
    
    
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        
        Task{
            try await Task.sleep(for: .seconds(3))
            isCompletingProfileSetup = false
            
            // other option to complete onboarding
            //makes show bar to true so onboarding is false and shows tabbar
            root.updateViewState(showTabBarView: true)
        }
  
    }
}
#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
}
