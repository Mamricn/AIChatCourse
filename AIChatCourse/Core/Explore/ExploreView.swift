//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct ExploreView: View {
    let avatar = AvatarModel.mock
    @State private var featureAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [AvatarModel] = AvatarModel.mocks
    
    @State private var path: [NavigationPathOption] = []
    
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            List {
                featuredSection
                categorySection
                popularSection
              
            }
                .navigationTitle("Expplore")
                .navigationDestinationForCoreModule(path: $path)
        }
    }
    
    
    
    
    
    
    
    
    private var featuredSection: some View{
        Section {
            ZStack{
                CarouselView(items: featureAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    
                }
                .anyButton(.plain) {
                    onAvatarPressed(avatar: avatar)
                }
            }
            .removeListRowFormating()
            
        } header: {
            Text("Featured avatars")
        }
    }
    
    
    
    
    
    
    
    
    private var categorySection: some View{
        Section {
            ZStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12){
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.rawValue.capitalized ,
                                    imageName: imageName
                                )
                                .anyButton(.plain) {
                                    
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                            
                            
                           
                        }
                        
                    }
                }
                .frame(height:140)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormating()
            
        } header: {
            Text("Categories")
        }
    }
    
    
    
    
    
    
    private var popularSection: some View{
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
            }
            .removeListRowFormating()
        } header: {
            Text("Featured")
        }
    }
    
    
    
    
    
    
    private func onAvatarPressed(avatar: AvatarModel){
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String){
        path.append(.category(category: category, imageName: imageName))
    }
}

#Preview {
    ExploreView()
}
