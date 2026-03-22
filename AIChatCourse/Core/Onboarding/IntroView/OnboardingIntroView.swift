//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 14/02/2026.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(ABTestManager.self) private var abTestManager
    
    var body: some View {
        VStack{
            
            Group{
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                
                +
                Text("with AI generated reponses.")
            }
            .baselineOffset(6)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: .infinity)
            .padding(24)
            
            NavigationLink {
                if abTestManager.activeTest.onboardingCommunityTest{
                    OnboardingCommunityView()
                }else {
                    OnboardingColorView()
                }
                
                
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")

    }
}

#Preview("Orignal") {
    NavigationStack{
        OnboardingIntroView()
    }
    .previewEnvironment()
}
#Preview("Onb Comm  Test"){
    NavigationStack{
        OnboardingIntroView()
    }
    .environment(ABTestManager(service: MockABTestService(createAccountTest: false, onboardingCommunityTest: true)))
    .previewEnvironment()
}
