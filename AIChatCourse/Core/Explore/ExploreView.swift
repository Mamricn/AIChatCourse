//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
   
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featureAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true

    
    @State private var path: [NavigationPathOption] = []
    
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            List {
                
                if featureAvatars.isEmpty && popularAvatars.isEmpty {
                   
                    ZStack{
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicador
                        } else {
                            errorMessageView
                        }
                    }
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
                }
                .task {
                    await loadPopularAvatars()
                }
        }
    }
    

    
    
    private var loadingIndicador: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)

    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8){
            Text("Error")
                .font(.headline)
            Text("Please check your intener connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)

    }
    
    private func onTryAgainPressed(){
        isLoadingPopular = true
        isLoadingFeatured = true
        Task {
            try await Task.sleep(nanoseconds: 233344443)
            await loadFeatureAvatars()
        }
        Task {
            try await Task.sleep(nanoseconds: 234444433)
            await loadPopularAvatars()
        }
    }
    
    
    private func loadFeatureAvatars() async {
        
        guard featureAvatars.isEmpty else { return }
        
        do {
            featureAvatars =  try await avatarManager.getFeaturedAvatars()

        } catch {
            print("error loading feature avatars \(error)")
        }
        isLoadingFeatured = false
    }
    
    
    private func loadPopularAvatars() async {
        
        guard popularAvatars.isEmpty else { return }
        
        do {
            popularAvatars =  try await avatarManager.getPopularAvatars()
        } catch {
            print("error loading popular avatars \(error)")
        }
        isLoadingPopular = false
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
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String){
        path.append(.category(category: category, imageName: imageName))
    }
}

#Preview("Has data"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(deley: 0)))
}
#Preview("No data"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
}

#Preview("Slow loading"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(deley: 10)))
}

