//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 17/02/2026.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager



    
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_  isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24){
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("Don't lose your data! Connect to an SSO provider to save your account.")
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
                .frame(height: 50)
                .anyButton(.press) {
                    onSignInApplePressed()
                }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
    
    enum Event: LoggableEvent {
        
        case appleAuthStart
        case appleAuthSuceess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)

        
        var eventName: String{
            
            switch self {
            case .appleAuthStart:              return "CreateAccountView_appleAuthStart_Start"
            case .appleAuthSuceess:            return "CreateAccountView_appleAuthSuceess_Success"
            case .appleAuthLoginSuccess:       return "CreateAccountView_appleAuth_LoginSuccess"
            case .appleAuthFail:               return "CreateAccountView_appleAuthFail_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .appleAuthSuceess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFail(let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func onSignInApplePressed(){
        Task{
            do{
                logManager.trackEvent(event: Event.appleAuthStart)
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuceess(user: result.user, isNewUser: result.isNewUser))
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                
                onDidSignIn?(result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))
                
                dismiss()
                
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))

            }
        }
    }
}

#Preview {
    CreateAccountView()
}
