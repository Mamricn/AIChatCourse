//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    
    var body: some View {
        NavigationStack {
            
            List{
                ForEach(chats){ chat in
                    Text(chat.id)
                }
            }
            
            
            
                .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
