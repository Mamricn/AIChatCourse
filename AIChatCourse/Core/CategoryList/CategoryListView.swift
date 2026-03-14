//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 20/02/2026.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager

    
    @Binding var path: [NavigationPathOption]
    
    var category: CharacterOption = .default
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = []
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = true
    
    
    var body: some View {
        List{
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormating()
            
            
            if isLoading{
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormating()
                    
            } else if avatars.isEmpty{
                Text("No avatars found 😭")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormating()
                
            } else {
                ForEach(avatars, id: \.self){ avatar in
                    CustomListCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormating()
                    
                }
            }
            
            
            
            
        }
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea(edges: .all)
        .listStyle(PlainListStyle())
        .task {
            await loadAvatars()
        }
    }
    
    enum Event: LoggableEvent {
        
        case loadAvatarStart
        case loadAvatarSuccess
        case loadAvatarFail(error: Error)
        case avatarPressed(avatar: AvatarModel)

        
        
        var eventName: String{
            
            switch self {
            case .loadAvatarStart:        return "CategoryList_LoadAvatars_Start"
            case .loadAvatarSuccess:      return "CategoryList_LoadAvatars_Success"
            case .loadAvatarFail:        return "CategoryList_LoadAvatars_Fail"
            case .avatarPressed:        return "CategoryList_Avatar_Pressed"

            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .loadAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
        
    
    
    
    
    
    private func loadAvatars() async {
        do {
            logManager.trackEvent(event: Event.loadAvatarStart)
            avatars = try await avatarManager.getAvatarForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarSuccess)

        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
            showAlert = AnyAppAlert(error: error)
        }
        
        isLoading = false
    }
    
    
    private func onAvatarPressed(avatar: AvatarModel){
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
}

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
}
#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
}
#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(deley: 10)))
}
#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(deley: 5, showError: true)))
}


//
//
//aha czyli kilkam wybiera z niego avatarId przypisuje do path array potem otwiera to bo się znajduje w enum i tam jest zapisane żeby otworzyć ChatView(avatarId: "teacher01") I juz w data base sa profile I szuka tego z avatarId == teacher01 I go otwiera dobrze rozumiem?


