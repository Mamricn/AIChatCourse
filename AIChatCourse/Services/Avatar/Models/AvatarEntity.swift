//
//  AvatarEntity.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//

import SwiftUI
import SwiftData

@Model
class AvatarEntity {
    @Attribute(.unique) var avatarId: String
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authId: String?
    var dateCreated: Date?
    var clickCount: Int?
    var dateAdded: Date
    
    init(from model: AvatarModel){
        self.avatarId = model.id
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authId = model.authId
        self.dateCreated = model.dateCreated
        self.clickCount = model.clickCount
        self.dateAdded = .now
    }
    
    func toModel() -> AvatarModel {
        AvatarModel(
            avatarId: avatarId,
            name: name,
            characterOption: characterOption,
            characterAction: characterAction,
            characterLocation: characterLocation,
            profileImageName: profileImageName,
            authId: authId,
            dateCreated: dateCreated,
            clickCount: clickCount
        )
    }
    
    
}
