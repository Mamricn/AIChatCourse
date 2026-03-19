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
    @Environment(LogManager.self) private var logManager

    
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
            .screenAppearAnalytics(name: "CreateAvatarView")
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
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private func onBackButtonPressed(){
        
        logManager.trackEvent(event: Event.backButtonPressed)
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
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8){
                ZStack{
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
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
                    .frame(maxWidth: .infinity, maxHeight: 400)
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
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
    
    
    enum Event: LoggableEvent {
        
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)
        
        

        
        var eventName: String{
            
            switch self {
            case .backButtonPressed:          return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:         return "CreateAvatarView_GenerateImage_Start"
            case .generateImageSuccess:       return "CreateAvatarView_GenerateImage_Success"
            case .generateImageFail:          return "CreateAvatarView_GenerateImage_Fail"
            case .saveAvatarStart:            return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:          return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:             return "CreateAvalarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case  .saveAvatarFail:
                return .warning
            case .generateImageFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    
    

    
    private func onGenerateImagePressed() {
       
        isGenaerating = true
        logManager.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription

                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            isGenaerating = false

            
            
//            try? await Task.sleep(nanoseconds: 99999)
//            generatedImage = UIImage(systemName: "star.fill")
//            
//            
//            isGenaerating = false
        }
    }
    
    private func OnSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }

        
        isSaving = true
       
        
        Task {
            
            do {
                //start
                try TextValidationHelper.checkIfMessageIsValid(text: avatarName, miniumCharacters: 3)
                let uid = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )
                //success
                //UPLOAD!
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
                showAlert = AnyAppAlert(error: error) //fail
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
        .previewEnvironment()
}
