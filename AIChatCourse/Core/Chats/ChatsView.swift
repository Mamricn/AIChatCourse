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
    @Environment(LogManager.self) private var logManager

    
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
            .screenAppearAnalytics(name: "ChatsView")
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
            logManager.trackEvent(event: Event.loadRecentsAvatarsStart)
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadRecentsAvatarsSuccess(avatarCount: recentAvatars.count))

        } catch {
            logManager.trackEvent(event: Event.loadRecentsAvatarsFail(error: error))
        }
    }
    
    
    
    private func loadChats() async {
        do {
            logManager.trackEvent(event: Event.loadRecentsChatStart)
            let uid = try authManager.getAuthId()
           chats =  try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModyfired, ascending: true)
//                .sorted(by: {$0.dateModyfired > $1.dateModyfired})
            logManager.trackEvent(event: Event.loadRecentsChatSuccess(chatsCount: chats.count))

        } catch {
            logManager.trackEvent(event: Event.loadRecentsChatFail(error: error))
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
                                    .frame(minHeight: 60)
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
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
        logManager.trackEvent(event: Event.chatPressed(chat: chat))

    }
    
    private func onAvatarPressed(avatar: AvatarModel) {

        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))

    }
    
    
    enum Event: LoggableEvent {
        
        case loadRecentsAvatarsStart
        case loadRecentsAvatarsSuccess(avatarCount: Int)
        case loadRecentsAvatarsFail(error: Error)
        
        case loadRecentsChatStart
        case loadRecentsChatSuccess(chatsCount: Int)
        case loadRecentsChatFail(error: Error)
        
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        
        var eventName: String{
            
            switch self {
            case .loadRecentsAvatarsStart:        return "ChatsView_loadRecentsAvatars_Start"
            case .loadRecentsAvatarsSuccess:      return "ChatsView_loadRecentsAvatars_Success"
            case .loadRecentsAvatarsFail:         return "ChatsView_loadRecentsAvatars_Fail"
                
            case .loadRecentsChatStart:           return "ChatsView_loadRecentsChat_Start"
            case .loadRecentsChatSuccess:         return "ChatsView_loadRecentsChat_Success"
            case .loadRecentsChatFail:            return "ChatsView_loadRecentsChat_Fail"
            
            case .chatPressed:                   return "ChatsView_chatPressed"
            case .avatarPressed:                   return "ChatsView_avatarPressed"
            
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .loadRecentsAvatarsFail(error: let error), .loadRecentsChatFail(error: let error):
                return error.eventParameters
            case .loadRecentsAvatarsSuccess(avatarCount: let avatar):
                return [
                    "avatars_count" : avatar
                ]
            case .loadRecentsChatSuccess(chatsCount: let chatsCount):
                return [
                    "chat_count" : chatsCount
                ]
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .loadRecentsAvatarsFail, .loadRecentsChatFail: 
                return .severe
            default:
                return .analytic
            }
        }
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
