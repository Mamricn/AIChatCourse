//
//  ChatBubbleView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 18/02/2026.
//

import SwiftUI

struct ChatBubbleView: View {
    
    
    var text: String = "This is sample text"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var showImage: Bool = true
    var imageName: String?
    let offSet: CGFloat = 14
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 8){
            
            
            if showImage {
                ZStack{
                    
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offSet)
            } else {
                
            }
            
            
            
            
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offSet : 0)
    }
}

#Preview {
    ScrollView{
        VStack(spacing: 16){
            ChatBubbleView()
            ChatBubbleView(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.Lorem ipsum dolor sit amet, consectetur adipiscing elit.Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                showImage: false,
                imageName: nil
            )
            
            ChatBubbleView(
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.Lorem ipsum dolor sit amet, consectetur adipiscing elit.Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                textColor: .white,
                backgroundColor: .accent,
                showImage: false,
                imageName: nil
            )
        }
        .padding()
    }
}
