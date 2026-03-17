//
//  OnFirstAppearViewModifire.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 17/03/2026.
//



import SwiftUI

struct OnFirstAppearViewModifire : ViewModifier {
    @State private var didAppear: Bool = false
    let action: () -> Void
    
    
    func body(content: Content) -> some View {
        
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }
}


struct OnTaskAppearViewModifire : ViewModifier {
    @State private var didAppear: Bool = false
    let action: ( ) async -> Void
    
    
    func body(content: Content) -> some View {
        
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await action()
            }
    }
}


extension View {
    func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifire(action: action))
    }
    func onFirstTask(action: @escaping () async -> Void) -> some View {
        modifier(OnTaskAppearViewModifire(action: action))
    }
}
