//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 17/02/2026.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dissmis
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager

    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    @State private var isGenaerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var showAlert: AnyAppAlert?
    
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack{
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
                
                
               
                
                
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
    

    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onBackButtonPressed()
            }
    }
    
    private var nameSection: some View {
        
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    
    private func onBackButtonPressed(){
        dissmis()
    }

    private var attributesSection: some View {
        Section {
            Picker(
                selection: $characterOption) {
                    ForEach(CharacterOption.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("is a ...")
                }
            
            
            Picker(
                selection: $characterAction) {
                    ForEach(CharacterAction.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("that is ...")
                }
            
            Picker(
                selection: $characterLocation) {
                    ForEach(CharacterLocation.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                } label: {
                    Text("in the ...")
                }

        } header: {
            Text("Attributes")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8){
                ZStack{
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            onGenerateImagePressed()
                        }
                        .opacity(isGenaerating ? 0 : 1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenaerating ? 1 : 0)
                }
                .disabled(isGenaerating || avatarName.isEmpty)
                
                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack{
                            if let generatedImage{
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .removeListRowFormating()
        }
        
    }
    
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                title: "Finish",
                isLoading: isSaving,
                action: OnSavePressed
            )
            .removeListRowFormating()
            .padding(.top, 24)
            .opacity(generatedImage == nil ? 0.5 : 1)
            .disabled(generatedImage == nil)
        }
    }

    
    private func onGenerateImagePressed() {
        isGenaerating = true
        
        Task {
            
            
//            do {
//                let prompt = AvatarDescriptionBuilder(
//                    characterOption: characterOption,
//                    characterAction: characterAction,
//                    characterLocation: characterLocation
//                )
//                    .characterDescription
//                
//                generatedImage = try await aiManager.generateImage(input: prompt)
//                
//            } catch {
//                print("Error generating image: \(error)")
//            }
//            isGenaerating = false
//            
            
            
            try? await Task.sleep(nanoseconds: 99999)
            generatedImage = UIImage(systemName: "star.fill")
            
            
            isGenaerating = false
        }
    }
    
    private func OnSavePressed() {
        guard let generatedImage else { return }
        isSaving = true
        
        Task {
            
            do {
                try TextValidationHelper.checkIfMessageIsValid(text: avatarName, miniumCharacters: 3)
                let uid = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )
                //UPLOAD!
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
            
            //Dismiss screan
            dissmis()
            isSaving = false
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AvatarManager(service: MockAvatarService()))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
}
