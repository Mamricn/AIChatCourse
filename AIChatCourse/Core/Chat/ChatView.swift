//
//  ChatView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 18/02/2026.
//

import SwiftUI





struct ChatView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel? 
    @State private var currentUser: UserModel? = .mock
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?
    @State private var showProfileModel: Bool = false
    
    
//    @State private var showAlert: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?


    var avatarId: String = AvatarModel.mock.avatarId
    
    
    var body: some View {
        
        
        
        VStack(spacing: 0){
            scrollViewSection
            textFieldSection
            
            
            
        }
      .navigationTitle(avatar?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .padding(8)
                    .anyButton(.plain) {
                        onChatSettingsPressed()
                    }
            }
        }
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
    }
    
    
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            try? avatarManager.addRecentAvatar(avatar: avatar)
            
            
        } catch {
            print("Error loading avatar \(error)")
        }
    }
    
    
    private var scrollViewSection: some View {
        ScrollView{
            LazyVStack(spacing: 24){
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    
                    ChatBubbleViewBuilder(
                        
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
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
    
    
    
    
    
    private func onSendMessagePressed() {
        guard let currentUser else { return }
        
        let content = textFieldText
        
        do{
            try TextValidationHelper.checkIfMessageIsValid(text: content)
            
            let message = ChatMessageModel(
                id: UUID().uuidString,
                chatId: UUID().uuidString,
                authorId: currentUser.userId ,
                content: content,
                seenByIds: nil,
                dateCrated: .now
            )
            chatMessages.append(message)
            scrollPosition = message.id
        } catch let error {
            showAlert = AnyAppAlert(error: error)
//            showAlert = true
        }
        
        
    }
    
    
    
    
    private func onChatSettingsPressed () {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group{
                        Button("Report User / Chat", role: .destructive) {
                            
                        }
                        Button("Delete Chat", role: .destructive) {
                            
                        }
                    }
                )
            }
        )
        
        
    }
    
    private func onAvatarImagePressed () {
        showProfileModel = true
    }
}

#Preview {
    NavigationStack{
        ChatView()
            .environment(AvatarManager(service: MockAvatarService()))
    }
}
