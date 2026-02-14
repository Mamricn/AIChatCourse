//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct WelcomeView: View {
    
    @State  var imageName: String = Constants.randomImage
    
    let termsOfService = URL(string: Constants.TermsOfServiceUrl)
    let privacyPolicy = URL(string: Constants.privacyPolicyUrl)
    
    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea(.all)
                titleSection
                .padding(.top, 24)
                ctaButton
                    .padding(16)
                policyLinks
            }
            
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI CHAT 🤙")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("YouTube @ SwiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    private var ctaButton: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get started")
                    .callToActionButton()
            }
            Text("Already have an account? Sign in!")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {

                }
        }
    }
    private var policyLinks: some View {
        HStack(spacing: 8){
            if let termsOfService {
                Link("Terms of service", destination: termsOfService)
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            if let privacyPolicy {
                Link("Privacy Policy", destination: privacyPolicy)
            }
            
        }
    }
    
}

#Preview {
    WelcomeView()
}
