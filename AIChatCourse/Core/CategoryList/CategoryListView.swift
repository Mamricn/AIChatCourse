//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 20/02/2026.
//

import SwiftUI

struct CategoryListView: View {
    
    @Binding var path: [NavigationPathOption]
    
    var category: CharacterOption = .default
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = AvatarModel.mocks
    
    
    var body: some View {
        List{
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormating()
            
            
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
        .ignoresSafeArea(edges: .all)
        .listStyle(PlainListStyle())
    }
    
    private func onAvatarPressed(avatar: AvatarModel){
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
}

#Preview {
    CategoryListView(path: .constant([]))
}
