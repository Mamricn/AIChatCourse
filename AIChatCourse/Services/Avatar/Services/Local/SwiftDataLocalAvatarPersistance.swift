//
//  SwiftDataLocalAvatarz.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 01/03/2026.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatar: LocalAvatarPersistence {
    
    private let container: ModelContainer
    
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init(){
        self.container = try! ModelContainer(for: AvatarEntity.self)
    }
    
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        let entity = AvatarEntity(from: avatar )
        mainContext.insert(entity)
       try  mainContext.save()
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        let descriptor = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map({$0.toModel()})
    }
}
