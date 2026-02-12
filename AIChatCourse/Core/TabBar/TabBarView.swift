//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    TabBarView()
}
