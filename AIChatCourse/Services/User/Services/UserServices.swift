//
//  UserServices.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//



protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence
    
    
    init(user: UserModel? = nil){
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(user: user)
    }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistence = FileManagerUserPresistance()
}
