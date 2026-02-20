//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI




struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            
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
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormating()
                }
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
        }
    }
    
    
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
}

#Preview {
    ChatsView()
}
