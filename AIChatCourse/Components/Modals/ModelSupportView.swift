//
//  ModelSupportView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 20/02/2026.
//

import SwiftUI

struct ModelSupportView<Content: View>: View {
    
   @Binding var showModel: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack{
            if showModel {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea(edges: .all)
                    .transition(AnyTransition.opacity.animation(.smooth))
                    .onTapGesture {
                        showModel = false
                    }
                    .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
                    .zIndex(2)

            }
        }
        .zIndex(9999)
        .animation(.bouncy, value: showModel)
    }
}

extension View {
    func showModel(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
        .overlay(
            ModelSupportView(showModel: showModal) {
                content()
            }
        )
    }
}




private struct PreviewView: View {
    
    @State private var showModal: Bool = false
    
    var body: some View {
        
        Button("Click me ") {
            showModal = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModel(showModal: $showModal) {
            RoundedRectangle(cornerRadius: 30)
                .padding(40)
                .padding(.vertical, 100)
                .onTapGesture {
                    showModal = false
                }
                .transition(.move(edge: .top))
        }
    }
}




#Preview {
    PreviewView()
}
