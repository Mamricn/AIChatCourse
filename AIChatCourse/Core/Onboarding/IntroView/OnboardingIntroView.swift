//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 14/02/2026.
//

import SwiftUI

struct OnboardingIntroView: View {
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
            .frame(maxHeight: .infinity)
            .padding(24)
            
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
    }
}

#Preview {
    NavigationStack{
        OnboardingIntroView()
    }
    .environment(AppState())
    
}
