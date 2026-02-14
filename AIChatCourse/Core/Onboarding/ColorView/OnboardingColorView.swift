//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 14/02/2026.
//

import SwiftUI

struct OnboardingColorView: View {
    
    @State private var selectedColor: Color? = nil
    let profileColor: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo,]
    
    var body: some View {
        ScrollView{
            colorGrid
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, content: {
            ZStack {
                if let selectedColor {
                    ctaButton
                    .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        })
        .animation(.bouncy, value: selectedColor)
    }
    
    
    
    
    private var colorGrid: some View{
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16),  count: 3) ,
            alignment: .center ,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(profileColor, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                        
                    }
                }, header: {
                    Text("Select a profile color ")
                })
            }
        )
    }
    
    private var ctaButton: some View {
        NavigationLink {
            OnboardingCompletedView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }

    }
}

#Preview {
    NavigationStack{
        OnboardingColorView()
    }
}



