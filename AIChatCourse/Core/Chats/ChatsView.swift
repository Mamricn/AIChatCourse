//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI




struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var recentAvatars: [AvatarModel] = AvatarModel.mocks
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            
            List{
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                
                ChatSection
                
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
        }
    }
    
    private var ChatSection: some View {
        Section {
            if chats.isEmpty {
                Text("Your chats will appear here")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .removeListRowFormating()
            } else {
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
        } header: {
            Text("Chats")
        }

    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack(spacing: 8){
                    ForEach(recentAvatars, id: \.self){ avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8){
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .anyButton(.plain) {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .removeListRowFormating()
        } header: {
            Text("Recents")
        }
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    ChatsView()
}
