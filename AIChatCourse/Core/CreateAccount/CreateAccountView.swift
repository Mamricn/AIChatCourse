//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 17/02/2026.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.authService) private var authService
    var onDidSignIn: ((_  isNewUser: Bool) -> Void)?
    
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    
    
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
    }
    
    func onSignInApplePressed(){
        Task{
            do{
                
                let result = try await authService.signInApple()
                print("Did sign in with apple!")
                onDidSignIn?(result.isNewUser)
                dismiss()
                
            } catch {
                print("error sign in with Apple")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
