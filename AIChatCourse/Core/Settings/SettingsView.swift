//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 13/02/2026.
//

import SwiftUI





struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var isPremium: Bool = true
    @State private var isAnynomusUser: Bool = false
    @State private var showCreatAccountView: Bool = false

    
    
    var body: some View {
        NavigationStack{
            List{
                
                
                
                accountSection
                
                purchaseSection
            
                applicationSection

               
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreatAccountView) {
                CreateAccountView()
                    .presentationDetents([.medium])
            }
        }
    }
    
    func onSignOutPressed() {
        // do some logic to sign user out of app
        dismiss()
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
        
       
    }
    
    func onCreateAccountPressed() {
        showCreatAccountView = true
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
                    onSignOutPressed()
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

#Preview {
    SettingsView()
        .environment(AppState())
}
