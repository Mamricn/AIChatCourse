//
//  UserAuthInfo+Firebase.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 22/02/2026.
//

import FirebaseAuth

extension UserAuthInfo {
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}
