//
//  FirebaseAvatarService.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 28/02/2026.
//


import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    
    
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
    
    
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upTo: 5) ?? []
            
            
            
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 200)
            .getAllDocuments()

    }
    
    
    func getAvatarForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments( )
    }
    
    
    
    // checks on codingkeys AuthId and compere to userId account number
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel]{
        try await collection
            .whereField(AvatarModel.CodingKeys.authId.rawValue, isEqualTo: userId)
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    
    
    
    
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection.document(avatarId).updateData([
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    
    
}
