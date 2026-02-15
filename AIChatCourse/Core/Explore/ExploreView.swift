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
    
    var body: some View {
        NavigationStack {
            List {
                featuredSection
                categorySection

            }
                .navigationTitle("Expplore")
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
                            CategoryCellView(
                                title: category.rawValue.capitalized ,
                                imageName: Constants.randomImage
                            )
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
}

#Preview {
    ExploreView()
}
