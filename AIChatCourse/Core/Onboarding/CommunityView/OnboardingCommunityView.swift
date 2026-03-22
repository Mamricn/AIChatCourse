//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 22/03/2026.
//



import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
        VStack{
            
            VStack(spacing: 40){
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                
                Group{
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars. \n \nAsk them questions or have casual conversation! ")

                }
                .baselineOffset(6)
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)

            
            
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")

    }
}

#Preview {
    NavigationStack{
        OnboardingCommunityView()
    }
    .previewEnvironment()
    
}
