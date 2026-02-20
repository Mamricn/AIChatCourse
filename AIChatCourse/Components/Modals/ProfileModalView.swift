//
//  ProfileModalView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 19/02/2026.
//

import SwiftUI

struct ProfileModalView: View {
    
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXMarkPressed: () -> Void = { }
    
    
    var body: some View {
        VStack{
            if let imageName{
                ImageLoaderView(
                    urlString: imageName,
                    forceTransitionAnimation: true
                )
                    .aspectRatio(1, contentMode: .fit)
                    
                
            }
            VStack(alignment: .leading, spacing: 4){
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                if let headline {
                    Text(headline)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            
            
        }
        .background(.thinMaterial)
        .cornerRadius(16)
        .overlay(
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(Color.black)
                .padding(4)
                .tappableBackground()
                .padding(8)
            , alignment: .topTrailing
        )
        .anyButton(.plain) {
            onXMarkPressed()
        }
        
    }
    
}

#Preview ("Modal w/ Image"){
    ZStack{
        Color.gray.ignoresSafeArea(edges: .all)
        
        ProfileModalView()
            .padding()
    }
}
#Preview ("Modal w/out Image"){
    ZStack{
        Color.gray.ignoresSafeArea(edges: .all)
        
        ProfileModalView()
            .padding()
    }
}
