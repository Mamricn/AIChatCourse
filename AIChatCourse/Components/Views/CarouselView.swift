//
//  CarouselView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 15/02/2026.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    
    var items: [T]
    @ViewBuilder var content: (T) -> Content
    @State private var selection: T?
    
    
    var body: some View {
        VStack(spacing: 12){
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0){
                    ForEach(items, id: \.self){ item in
                        content(item)
    //                        .fill(index % 2 == 0 ? Color.red : Color.green)
                        .scrollTransition(.interactive.threshold(.visible(0.95)), transition: { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : 0.5)
                        })
                            .containerRelativeFrame(.horizontal, alignment: .center)
                            .id(item)
                            .onChange(of: items.count, { _, _ in
                                updateSelectionIfNeeded()
                            })
                            .onAppear{
                                updateSelectionIfNeeded()
                            }
                    }
                }
            }
            .frame(height:200)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            
            HStack(spacing: 8){
                ForEach(items, id: \.self){ item in
                    Circle()
                        .fill(item == selection ? .accent : .secondary)
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
            
            
        }
    }
    
    
    private func updateSelectionIfNeeded(){
        if selection == nil  || selection == items.last{
            selection = items.first
        }
    }
}

#Preview {
    
    CarouselView(items: AvatarModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subtitle: item.characterDescription,
            imageName: item.profileImageName
        )
    }
    .padding()
}


