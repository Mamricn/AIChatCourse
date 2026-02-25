//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/02/2026.
//

import SwiftUI





struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var isPremium: Bool = true
    @State private var isAnynomusUser: Bool = false
    @State private var showCreatAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    
    var body: some View {
        NavigationStack{
            List{
                
                
                
                accountSection
                
                purchaseSection
            
                applicationSection

               
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreatAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
   
    
    
    
    private var accountSection: some View {
        Section {
            if isAnynomusUser{
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormating()
                
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormating()
                
            }
            
            
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormating()
            
            
        } header: {
            Text("Account")
        }

    }
    
    
    
    private var purchaseSection: some View {
        Section {
            HStack(spacing: 8){
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                Spacer(minLength: 0)
                if isPremium{
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                
            }
            .disabled(!isPremium)
            .removeListRowFormating()
        } header: {
            Text("Purchases")
        }
        
    }
    
    
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8){
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
                
            }
            .rowFormatting()
            .removeListRowFormating()
            
            HStack(spacing: 8){
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
                
            }
            .rowFormatting()
            .removeListRowFormating()
            
            
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    
                }
                .removeListRowFormating()
            
            
        } header: {
            Text("Aplication")
        } footer: {
            Text("Created by SwiftFul Thinking \n Learn more at https://swiftfulthinking.com")
                .baselineOffset(6)
        }
    }
    
    
    
    
    func setAnonymousAccountStatus(){
        isAnynomusUser = authManager.auth?.isAnonymous == true
    }
    
    
    
    func onSignOutPressed() {
        // do some logic to sign user out of app
        
        Task {
            do {
                try authManager.signOut()
                 userManager.signOut()
               await dismissScreen()
            } catch let error  {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    
    func onDeleteAccountPressed(){
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is premanet and cannot be undone. Your data will be deleted from our server forever",
            buttons: {
                AnyView (
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                // it deletes profile
                try await authManager.deleteAccount()
                // it deletes all files from account
                try await userManager.deleteCurrentUser()
               await dismissScreen()
            } catch let error  {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreatAccountView = true
    }
    
    
}



fileprivate extension View {
    
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
        
    }
}
#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(service: MockUserService(user: nil)))
        .environment(AppState())
}
#Preview("Anynonmus") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(service: MockUserService(user: .mock)))
        .environment(AppState())
}
#Preview("Not anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(service: MockUserService(user: .mock)))
        .environment(AppState())
}
