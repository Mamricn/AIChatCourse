//
//  ChatRowCellView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 16/02/2026.
//

import SwiftUI

struct ChatRowCellView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var imageName: String? = Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    var hasNewChat: Bool = true
    
    
    var body: some View {
        HStack(spacing: 8){
            ZStack{
                if let imageName{
                    ImageLoaderView(urlString: imageName)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(30)
                }else{
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.secondary.opacity(0.2))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
               
            VStack(alignment: .leading, spacing: 4) {
                if let headline{
                    Text(headline)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                if let subheadline{
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.3)
                        
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            
           if hasNewChat{
               Text("NEW")
                   .badgeButton()
                   .lineLimit(1)
                   .minimumScaleFactor(0.1)
                   .frame(maxWidth: 50)
            }
                
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(colorScheme.backgroundPrimary)
       
        
    }
}

#Preview {
    ZStack{
        Color.gray.ignoresSafeArea(edges: .all)
        
        List{
            ChatRowCellView()
                .removeListRowFormating()
            ChatRowCellView(hasNewChat: false)
                .removeListRowFormating()
            ChatRowCellView(imageName: nil)
                .removeListRowFormating()
            ChatRowCellView(headline: nil, hasNewChat: false)
                .removeListRowFormating()
            ChatRowCellView(subheadline: nil, hasNewChat: false)
                .removeListRowFormating()
            
        }
    }
}
