//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 26/02/2026.
//

import SwiftUI




protocol AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}


struct MockAvatarService: AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
    
    
}


import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        //Upload image
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        //Upload avatar
        var avatar = avatar
        avatar.updateImage(imageName: url.absoluteString)
        //update avatar image name
        try  collection.document(avatar.avatarId).setData(from: avatar, merge: true)

    }
    
}


@MainActor
@Observable
class AvatarManager {
    
    
    private let services: AvatarService

    init(services: AvatarService) {
        self.services = services
    }
    
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        //Upload image
        try await services.createAvatar(avatar: avatar, image: image)
        
        //Upload avatar
    }
    
    
}
