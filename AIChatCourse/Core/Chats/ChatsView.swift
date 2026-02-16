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
                    ChatRowCellViewBuilder(
                        currentUserId: nil, //FIXME: add cuid
                        chat: chat,
                        getAvatar: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        }
                    )
                    .anyButton(.highlight, action: {
                        
                    })
                    .removeListRowFormating()
                }
            }
            
            
            
                .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
