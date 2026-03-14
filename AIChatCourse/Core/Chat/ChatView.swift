//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 18/02/2026.
//

import SwiftUI





struct ChatView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State  var chat: ChatModel? = nil
    
    
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?
    
    
    @State private var showProfileModel: Bool = false
//    @State private var showAlert: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var isGeneratingResponse: Bool = false
    @State private var listenerTask: Task<Void, Never>?

    var avatarId: String = AvatarModel.mock.avatarId
    
    
    var body: some View {
        
        
        
        VStack(spacing: 0){
            scrollViewSection
            textFieldSection
            
            
            
        }
      .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                HStack{
                    
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .anyButton(.plain) {
                            onChatSettingsPressed()
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "Chat View")
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModel(showModal: $showProfileModel) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenForChatMessages()
        }
        .onAppear{
            loadCurrentUser()
        }
        .onDisappear{
            listenerTask?.cancel()
            listenerTask = nil
        }
    }
    
    
    
    private func loadCurrentUser(){
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        do {
            logManager.trackEvent(event: Event.loadAvatarStart)
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
            

            
            
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func loadChat() async {
        do {
            logManager.trackEvent(event: Event.loadChatStart)
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))

        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    private func listenForChatMessages() async {
        
        
        listenerTask?.cancel()
        listenerTask = Task {
            do {
                logManager.trackEvent(event: Event.loadMessagesStart)

                guard chat != nil else { return }
                
                
                let chatId = try getChatId()
                for try await value in chatManager.streamChatMessages(chatId: chatId){
                    chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated, ascending: true)
//                        .sorted(by: {$0.dateCratedCalculated < $1.dateCratedCalculated})
                    
                }
            }
            catch{
                logManager.trackEvent(event: Event.loadMessagesFail(error: error))
            }
        }
    }
        
//        do {
//            let chatId = try getChatId()
//            for try await value in chatManager.streamChatMessages(chatId: chatId) {
//                chatMessages = value.sorted(by: {$0.dateCratedCalculated < $1.dateCratedCalculated})
//                scrollPosition = chatMessages.last?.id
//
//            }
//            
//        } catch {
//            print("Failed to attached chat message listener.")
//        }
//    }
//    
    
    
    
    
    private var scrollViewSection: some View {
        ScrollView{
            LazyVStack(spacing: 24){
                ForEach(chatMessages) { message in
                    
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }

                    
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    
                    ChatBubbleViewBuilder(
                        
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))

        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .bottom)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)

    }
    
    
    private func onMessageDidAppear(message: ChatMessageModel){
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
                
                
            } catch {
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    
    
    
    private var textFieldSection: some View {
        TextField("Say something . . .", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        onSendMessagePressed()
                    })
                , alignment: .trailing
            )
            .background(
                ZStack{
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.03), lineWidth: 1)
                }
                )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
        
    }
    
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id}),
              chatMessages.indices.contains(index - 1)
        else {
            return false
        }
        
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        
        let threshold: TimeInterval = 60 * 45
        return timeDiff > threshold
    }
    
    
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXMarkPressed: {
                showProfileModel = false
            }
        )
            .padding(40)
            .transition(.slide)
    }
    
    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }
    
    
    
    private func onSendMessagePressed() {
        
        let content = textFieldText
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
        Task {
            do{
                
                // get UserId
                let uid = try authManager.getAuthId()
                // validate textfield text
                try TextValidationHelper.checkIfMessageIsValid(text: content)
                
                if chat == nil {
                    
                   chat = try await createNewChat(uid: uid)
                }
                // if tthere is no chat throw error (should never happen)
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                let newChatMessage = AIChatModel(role: .user, content: content)
                
                let message = ChatMessageModel.newUserMessage(
                    chatId: chat.id,
                    userId: uid,
                    message: newChatMessage
                )
                
                //Upload User chat
                try await chatManager.addChatMessage(chatId: chat.id, message: message)
                
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
                
                textFieldText = ""
                
                
                
                
                //Generate AI Response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap{$0.content}
                if let avatarDescription = avatar?.characterDescription {
                    let systemMessage = AIChatModel(
                        role: .system,
                        content: "You are a \(avatarDescription)"
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                
                
                let response = try await aiManager.generateText(chats: aiChats)

                
                // create ai chat
                let newAIMessage = ChatMessageModel.newIAMessage(
                    chatId: chat.id,
                    avatarId: avatarId,
                    message: response
                )
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload Ai chat
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: newAIMessage))
               

            } catch let error {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))

            }
            isGeneratingResponse = false
        }
        
        
    }
    
    enum ChatViewError: Error {
        case noChat
    }
    
    private func createNewChat(uid: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
        // if chat is nill then create a new chat
        let newChat = ChatModel.new(
            userId: uid,
            avatarId: avatarId
        )
        try await chatManager.createNewChat(chat: newChat)
        chat = newChat
        await listenForChatMessages()
            
        return newChat
        
    }
    
    
    
    private func onChatSettingsPressed () {
        logManager.trackEvent(event: Event.chatSettingsPressed)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group{
                        Button("Report User / Chat", role: .destructive) {
                            onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    }
                )
            }
        )
        
        
    }
    
    private func onReportChatPressed(){
        Task {
            do {
                logManager.trackEvent(event: Event.reportChatStart)
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                logManager.trackEvent(event: Event.reportChatSuccess)

                
                showAlert = AnyAppAlert(
                    title: "🚨🚨 Reported ",
                    subtitle: "We will review the chat shortly. You may leave the chat at any time. Thanks for bringing this to our attention."
                )
                
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))

                showAlert = AnyAppAlert(
                    title: "Someting went wrong",
                    subtitle: "Please check your intenert connetction"
                )

            }
        }
    }
    
    
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.reportChatStart)

        Task{
            do {
                logManager.trackEvent(event: Event.reportChatStart)

                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.reportChatSuccess)

                
                dismiss()
                
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))

                showAlert = AnyAppAlert(
                    title: "Someting went wrong",
                    subtitle: "Please check your intenert connetction"
                )
            }
        }
    }
    
    private func onAvatarImagePressed () {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))

        
        showProfileModel = true
    }
    
    
    enum Event: LoggableEvent {
        
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        
        case loadMessagesStart
        case loadMessagesFail(error: Error)
        
        case messageSeenFail(error: Error)
        
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        
        case createChatStart
        case chatSettingsPressed
        
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        case deleteChatFail(error: Error)
        case avatarImagePressed(avatar: AvatarModel?)
 
        
        
        var eventName: String{
            
            switch self {
            case .loadAvatarStart:          return "ChatView_loadAvatar_Start"
            case .loadAvatarSuccess:        return "ChatView_loadAvatar_Success"
            case .loadAvatarFail:           return "ChatView_loadAvatar_Fail"
                
            case .loadChatStart:            return "ChatView_loadChat_Start"
            case .loadChatSuccess:          return "ChatView_loadChat_Success"
            case .loadChatFail:             return "ChatView_loadChat_Fail"
                
            case .loadMessagesStart:        return "ChatView_loadMessages_Start"
            case .loadMessagesFail:         return "ChatView_loadMessages_Fail"
                
            case .messageSeenFail:          return "ChatView_messageSeen_Fail"
            
            case .sendMessageStart:         return "ChatView_sendMessage_Start"
            case .sendMessageFail:          return "ChatView_sendMessage_Fail"
            case .sendMessageSent:          return "ChatView_sendMessage_Sent"
            case .sendMessageResponse:      return "ChatView_sendMessage_Response"
            case .sendMessageResponseSent:  return "ChatView_sendMessage_ResponseSent"
            
            case .createChatStart:          return "ChatView_createChat_Start"
            case .chatSettingsPressed:      return "ChatView_chatSettings_Pressed"
            
            case .reportChatStart:          return "ChatView_reportChat_Start"
            case .reportChatSuccess:         return "ChatView_reportChat_Success"
            case .reportChatFail:           return "ChatView_reportChat_Fail"
            case .deleteChatFail:           return "ChatView_deleteChat_Fail"
            case .avatarImagePressed:       return "ChatView_avatarImage_Pressed"
                
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .loadAvatarFail(error: let error), .loadChatFail(error: let error), .loadMessagesFail(error: let error), .messageSeenFail(error: let error), .sendMessageFail(error: let error), .reportChatFail(error: let error), .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict  = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
                
//                dict.merge(avatar?.eventParameters ?? [:],  uniquingKeysWith: {(existing,_) in return existing})
//                }
   
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatFail, .sendMessageFail:
                return .warning
            case .loadAvatarFail, .loadMessagesFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    
    
    
}

#Preview("working chat") {
    NavigationStack{
        ChatView()
            .environment(AvatarManager(service: MockAvatarService()))
            .previewEnvironment()
    }
}
#Preview("Slow AI generation"){
    NavigationStack{
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 20)))
            .previewEnvironment()
    }
}
#Preview("Faild AI generation"){
    NavigationStack{
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 2, showError: true)))
            .previewEnvironment()
    }
}

