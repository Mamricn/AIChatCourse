//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct ChatsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager

    
    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    
    @State private var recentAvatars: [AvatarModel] = []

    @State private var path: [NavigationPathOption] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .onAppear {
                 loadRecentsAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    
    private func loadRecentsAvatars()  {
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Failed to load recents")
        }
    }
    
    
    
    private func loadChats() async {
        do {
            let uid = try authManager.getAuthId()
           chats =  try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModyfired, ascending: true)
//                .sorted(by: {$0.dateModyfired > $1.dateModyfired})
        } catch {
            print("failed to load chats")
        }
        isLoadingChats = false
    }
    
    
    private var chatsSection: some View {
        Section {
            
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormating()
            }else {
                if chats.isEmpty {
                    Text("Your chats will appear here!")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .removeListRowFormating()
                } else {
                    ForEach(chats) { chat in
                        ChatRowCellViewBuilder(
                            currentUserId: authManager.auth?.uid, // Add cuid
                            chat: chat,
                            getAvatar: {
                                try? await avatarManager.getAvatar(id: chat.avatarId)

                            },
                            getLastChatMessage: {
                                try? await chatManager.getLastChatMessage(chatId: chat.id)
                            }
                        )
                        .anyButton(.highlight, action: {
                            onChatPressed(chat: chat)
                        })
                        .removeListRowFormating()
                       
                    }
                }
            }
            
           
        } header: {
            Text(chats.isEmpty ? "" :"Chats")
        }
    }
    

    
    
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton(.plain){
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormating()
        } header: {
            Text("Recents")
        }
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Has data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("no data") {
    ChatsView()
        .environment(AvatarManager(service: MockAvatarService(avatars: []), local: MockLocalAvatarPersistence(avatars: [])))
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}
#Preview("slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(deley: 5)))
        .previewEnvironment()
}
