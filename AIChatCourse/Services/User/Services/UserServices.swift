//
//  UserServices.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 25/02/2026.
//



protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistance { get }
}

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistance
    
    
    init(user: UserModel? = nil){
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistance(user: user)
    }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistance = FileManagerUserPresistance()
}
