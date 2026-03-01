//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    
    @State private var featureAvatars: [AvatarModel] = []
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [AvatarModel] = []
    
    @State private var path: [NavigationPathOption] = []
    
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            List {
                
                if featureAvatars.isEmpty && popularAvatars.isEmpty {
                    ProgressView()
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .removeListRowFormating()
                }
                
                if !featureAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
              
            }
                .navigationTitle("Explore")
                .navigationDestinationForCoreModule(path: $path)
                .task {
                    await loadFeatureAvatars()
                    print("loaded feature avatars")
                }
                .task {
                    await loadPopularAvatars()
                }
        }
    }
    
    
    
    
    
    private func loadFeatureAvatars() async {
        
        guard featureAvatars.isEmpty else { return }
        
        do {
            featureAvatars =  try await avatarManager.getFeaturedAvatars()

        } catch {
            print("error loading feature avatars \(error)")
        }
    }
    
    
    private func loadPopularAvatars() async {
        
        guard popularAvatars.isEmpty else { return }
        
        do {
            popularAvatars =  try await avatarManager.getPopularAvatars()
        } catch {
            print("error loading popular avatars \(error)")
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
                    .anyButton(.plain) {
                        onAvatarPressed(avatar: avatar)
                    }
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
        .environment(AvatarManager(service: FirebaseAvatarService()))
}
