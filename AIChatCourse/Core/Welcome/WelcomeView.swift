//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppState.self) private var root
    @Environment(LogManager.self) private var logManager

    
    @State  var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false
    
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
        .screenAppearAnalytics(name: "Welcome View")
        .sheet(isPresented: $showSignInView) {
            CreateAccountView(
                title: "Sign In",
                subtitle: "Connect to an existing account.",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
                .presentationDetents([.medium])
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
                    onSignInPressed()
                }
        }
    }
    
    
    private func handleDidSignIn(isNewUser: Bool){
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            // do noting, user goes through onboarding
            
             
        } else {
            //push into tabbar view
            root.updateViewState(showTabBarView: true)
            
        }
    }
    
    
    
    
    private func onSignInPressed(){
        showSignInView = true
        logManager.trackEvent(event: Event.SignInPressed)
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
    
    enum Event: LoggableEvent {

        
        case didSignIn(isNewUser: Bool)
        case SignInPressed
        
        var eventName: String{
            switch self {
                
            case .didSignIn:        return "WelcomView_didSignIn"
            case .SignInPressed:    return "WelcomView_SignInPressed"
        
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .didSignIn(let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
                
                
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
                
                
            default:
                return .analytic
            }
        }
    }
    
}

#Preview {
    WelcomeView()
        .environment(AppState())
}
