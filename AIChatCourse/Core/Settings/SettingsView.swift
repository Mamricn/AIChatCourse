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
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
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
            .screenAppearAnalytics(name: "SettingsView")
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
        // start
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                 userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)

                
               await dismissScreen()
            } catch let error  {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
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
        
        logManager.trackEvent(event: Event.deletedAccountStartConfimed)
        Task {
            do {
                let uid =  try authManager.getAuthId()
                
                // it deletes profile
                async let deleteAuth: () = authManager.deleteAccount()
                // it deletes all files from account
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatar: () = avatarManager.removeAuthorIdFromAllAvatars(userId: uid)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
                
                
                
                let (_,_,_,_) = await (try deleteAuth, try deleteUser, try deleteAvatar, try deleteChats)
                logManager.trackEvent(event: Event.deletedAccountSuccess)
                logManager.deleteUserProfile()
               await dismissScreen()
            } catch let error  {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deletedAccountConfirmedFail(error: error))

                //error
            }
        }
    }
    
    func onCreateAccountPressed() {
        showCreatAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)

        //pressed
    }
    
    
    
    enum Event: LoggableEvent {
        
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deletedAccountStartConfimed
        case deletedAccountSuccess
        case deletedAccountConfirmedFail(error: Error)
        case createAccountPressed

        
        var eventName: String{
            switch self {
            
            case .signOutStart:                     return "SettingsView_signOut_Start"
            case .signOutSuccess:                   return "SettingsView_signOut_Success"
            case .signOutFail:                      return "SettingsView_signOut_Fail"
            case .deletedAccountStartConfimed:      return "SettingsView_deletedAccount_Start"
            case .deletedAccountSuccess:            return "SettingsView_deletedAccount_Success"
            case .deletedAccountConfirmedFail:      return "SettingsView_deletedAccount_Fail"
            case .createAccountPressed:             return "SettingsView_createAccount_Pressed"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .signOutFail(let error), .deletedAccountConfirmedFail(let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
                case .signOutFail, .deletedAccountConfirmedFail:
                return .severe
            default:
                return .analytic
            }
        }
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
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}
#Preview("Anynonmus") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()

    
}
#Preview("Not anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()

}
