//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/03/2026.
//

import SwiftUI
import SwiftfulUtilities



struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
               
                
                authSection
                userSection
                deviceSection
                
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton(.plain){
                onBackButtonPressed()
            }
            
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private var authSection: some View {
        Section {
            
            let array = authManager.auth?.eventParameters.asAlphaticalArray ?? []

            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("Auth Info")
        }
    }
    
    
    private var userSection: some View {
        Section {
            
            let array = userManager.currentUser?.eventParameters.asAlphaticalArray ?? []

            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
        
            let array = Utilities.eventParameters.asAlphaticalArray
            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("User Info")
        }
        
    }
    
    
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack{
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value){
                Text(value)
            } else {
                Text("Unknown")
            }
            
            
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
