//
//  ButtonViewModifires.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 15/02/2026.
//

import SwiftUI

//button style
struct HighlightButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay{
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.accent.opacity(0.0)
            }
            .animation(.smooth, value: configuration.isPressed)
            
    }
    
    
}

struct PressableButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            
            .animation(.smooth, value: configuration.isPressed)
            
    }
    
    
}

enum ButtonStyleOptions{
    case press, highlight, plain
}


// extension to  make it easy to use

extension View {
    
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOptions, action: @escaping () -> Void) -> some View {
        switch option {
        case .press:
            self.pressableButton(action: action)
            
        case .highlight:
            self.highlightButton(action: action)
            
        case .plain:
        self.plainButtonStyle(action: action)
        }
        
    }
    
    private func plainButtonStyle(action: @escaping () -> Void) -> some View {
       Button {
           action()
       } label: {
           self
       }
       .buttonStyle(PlainButtonStyle())
   }
   
    
     private func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HighlightButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
}


//preview how it looks like

#Preview {
    VStack{
      Text("Hello world!")
        .padding()
        .frame(maxWidth: .infinity)
        .tappableBackground()
        .anyButton(.highlight, action: {})
        .padding()
        
        
        Text("Hello, world!")
            .callToActionButton()
            .anyButton(.press, action: {})
            .padding()
            
        
        
        Text("Hello, world!")
            .callToActionButton()
            .anyButton(.plain, action: {})
            .padding()
        
    }
    .padding()

}
