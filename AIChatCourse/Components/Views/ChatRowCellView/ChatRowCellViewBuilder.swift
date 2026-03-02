//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    
    var currentUserId: String? = ""
    var chat: ChatModel = .mock
    
    
    //func to feach chat from data base
    var getAvatar: () async -> AvatarModel?
    var getLastChatMessage: () async -> ChatMessageModel?
    
    
    //chat message holder has to be same model cuz needs to hold data from database
    @State private var avatar: AvatarModel?
    @State private var lastChatMessage: ChatMessageModel?
    
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var isLoading: Bool{
        if didLoadAvatar && didLoadChatMessage {
            return false
        } else {
            return true
        }
    }
    private var hasNewChat: Bool{
        guard let lastChatMessage, let currentUserId  else { return false}
        
        return lastChatMessage.hasBeenSeenBy(userId: currentUserId)
        
    }
    
    private var subheadline: String? {
        if isLoading{
            return "xxxx xxxx xxxx xxxx"
        }
        
        if avatar == nil && lastChatMessage == nil{
            return "Error loading data."
        }
        return lastChatMessage?.content?.content
    }
    
    
    
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            // get the avatar
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task{
            // holder chatMassage getting messages from function which is downloading messages from data
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
    
    
   
}

#Preview {
    VStack{
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        }, getLastChatMessage: {
            return .mock
        })
        
        
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
             .mock
        }, getLastChatMessage: {
             .mock
        })
        
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            nil
        }, getLastChatMessage: {
            nil
        })
        
    }
}
