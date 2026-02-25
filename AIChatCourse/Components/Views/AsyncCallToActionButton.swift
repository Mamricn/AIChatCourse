//
//  AsyncCallToActionButton.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 18/02/2026.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    
    var title: String = "Save"
    var isLoading: Bool = true
    var action: () -> Void = { }
    var body: some View {
        ZStack{
            if isLoading{
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
                   
            }
        }
        .callToActionButton()
        .anyButton(.press) {
            action()
        }
        .disabled(isLoading)
    }
}




 private struct PreviewView: View {
    @State private var isLoading: Bool = false
    
    var body: some View {
        AsyncCallToActionButton(
            title: "Finish",
            isLoading: isLoading,
            action: {
                isLoading = true
                
                Task{
                    try? await Task.sleep(for: .milliseconds(50))
                    
                    isLoading = false
                }
            }
        )
    }
}



#Preview {
    PreviewView()
        .padding()
}
