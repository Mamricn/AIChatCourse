//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var showCreateAvatarView: Bool = false
    @State private var showSettingsView: Bool = false
    @State private var currentUser: UserModel? = .mock
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    

    
    
    
    var body: some View {
        NavigationStack(path: $path) {
            List{
                myInfoSection
                myAvatarsSection
                
                
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(path: $path)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            CreateAvatarView()
        }
        .task{
            await loadData()
        }
        
    }
    
    
    
    
    
    
    private func loadData() async {
        try? await Task.sleep(for: .seconds(5))
        isLoading = false
        myAvatars = AvatarModel.mocks
    }
    
    
    
    
    
    
    
    
    private var myInfoSection: some View {
        Section {
            ZStack{
                Circle()
                    .fill(currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormating()
        }
    }
    
    
    
    
    
    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group{
                    if isLoading{
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .removeListRowFormating()
            } else {
                ForEach(myAvatars, id: \.self){ avatar in
                    CustomListCellView(
                        title: avatar.name,
                        subtitle: nil,
                        imageName: avatar.profileImageName
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                        
                        
                    })
                    .removeListRowFormating()
                    
                }
                .onDelete { indexSet in
                    onDeleteAvatar(indexSet: indexSet)
                }
                
            }
            
        } header: {
            HStack(spacing: 0){
                Text("My avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton(.plain) {
                        onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    
    
    
    private var settingsButton: some View{
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton(.plain) {
                showSettingsView = true
            }
    }
    
    private func onNewAvatarButtonPressed(){
        showCreateAvatarView = true
    }
    
    private func onDeleteAvatar(indexSet: IndexSet){
        guard let index = indexSet.first else { return }
        myAvatars.remove(at: index)
    }
    
    private func onAvatarPressed(avatar: AvatarModel){
        path.append(.chat(avatarId: avatar.avatarId))
    }
}






#Preview {
    ProfileView()
        .environment(AppState())
}
