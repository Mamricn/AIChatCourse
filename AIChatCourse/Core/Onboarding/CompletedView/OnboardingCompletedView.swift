//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/02/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var isCompletingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlert?
    
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
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)

    }
    
    enum Event: LoggableEvent {
        
        case FinishStart
        case FinishSuccess(hex: String)
        case FinishFail(error: Error)

        
        
        var eventName: String{
            
            switch self {
            case .FinishStart:               return "OnboardingCompletedView_Finish_Start"
            case .FinishSuccess:             return "OnboardingCompletedView_Finish_Success"
            case .FinishFail:                return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .FinishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .FinishFail(error: let error):
                return error.eventParameters
            default:
                return nil
                
        }
            }
        var type: LogType {
            switch self {
            case .FinishFail:
                return .severe
            default:
                return .analytic
            }}
    }
    
    
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.FinishStart)
        
        Task { 
            
            do {
                let hex = selectedColor.asHex()
                try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
                logManager.trackEvent(event: Event.FinishSuccess(hex: hex))

                
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
                
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.FinishFail(error: error))

            }
            
            
            
           
            
            // other option to complete onboarding
            //makes show bar to true so onboarding is false and shows tabbar
//            root.updateViewState(showTabBarView: true)
        }
  
    }
}
#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
}
