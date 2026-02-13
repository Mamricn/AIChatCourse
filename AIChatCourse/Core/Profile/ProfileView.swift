//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @State var showSettingsView: Bool = false
    var body: some View {
        NavigationStack {
            Text("Profile")
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                       settingsButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
    }
    
    private var settingsButton: some View{
        Button {
            showSettingsView = true
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
    }
}

#Preview {
    ProfileView()
}
