//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 14/02/2026.
//

import Foundation




struct AvatarModel: Hashable, Codable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authId: String?
    let dateCreated: Date?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authId = authId
        self.dateCreated = dateCreated
    }
    
    var characterDescription: String{
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    
    mutating func updateImage(imageName: String) {
        profileImageName = imageName
    }
    
    
    
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authId = "auth_id"
        case dateCreated = "date_created"
    }
    
    
    static var mock: Self{
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            AvatarModel(avatarId: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Gama", characterOption: .cat, characterAction: .drinking, characterLocation: .museum, profileImageName: Constants.randomImage, authId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shoping, characterLocation: .park, profileImageName: Constants.randomImage, authId: UUID().uuidString, dateCreated: .now)
        ]
    }
}

