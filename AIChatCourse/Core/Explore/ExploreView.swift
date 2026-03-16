//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/02/2026.
//

import SwiftUI



struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager

   
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featureAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    
    
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    
    
    
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            List {
                
                if featureAvatars.isEmpty && popularAvatars.isEmpty {
                   
                    ZStack{
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicador
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormating()
                }
                
                
                if !featureAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
              
            }
                .navigationTitle("Explore")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if showDevSettingsButton {
                            devSettingsButton
                        }
                            
                    }
                }
                .screenAppearAnalytics(name: "ExploreView")
                .sheet(isPresented: $showDevSettings, content: {
                    DevSettingsView()
                })
                .navigationDestinationForCoreModule(path: $path)
                .task {
                    await loadFeatureAvatars()
                }
                .task {
                    await loadPopularAvatars()
                }
        }
    }
    
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingsPressed()
            }
    }
    
    enum Event: LoggableEvent {
        
        case devSettingsPressed
        case tryAgainStart
        case tryAgainSuccess
        case tryAgainFail(error: Error)
        
        case loadFeatureAvatarsStart
        case loadFeatureAvatarsSuccess(count: Int)
        case loadFeatureAvatarsFail(error: Error)
        
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        
        case onAvatarPressed(avatar: AvatarModel)
        case onCategoryPressed(category: CharacterOption)
        
        
        

        
        
        var eventName: String{
            
            switch self {
            case .devSettingsPressed:                 return "EploreView_devSettings_Pressed"
            case .tryAgainStart:                      return "EploreView_tryAgain_Start"
            case .tryAgainSuccess:                    return "EploreView_tryAgain_Succcess"
            case .tryAgainFail:                       return "EploreView_tryAgain_Fail"
            
            case .loadFeatureAvatarsStart :           return "EploreView_tryAgain_Start"
            case .loadFeatureAvatarsSuccess:          return "EploreView_tryAgain_Success"
            case .loadFeatureAvatarsFail:             return "EploreView_tryAgain_Fail"
        
            case .loadPopularAvatarsStart:            return "EploreView_tryAgain_Start"
            case .loadPopularAvatarsSuccess:          return "EploreView_tryAgain_Success"
            case .loadPopularAvatarsFail:             return "EploreView_tryAgain_Fail"
                
            case .onAvatarPressed:                    return "EploreView_onAvatar_Pressed"
            case .onCategoryPressed:                  return "EploreView_onCategory_Pressed"
            
            }
        }
        
        var parameters: [String : Any]? {
            
            
            switch self {
            case .loadFeatureAvatarsSuccess(count: let count), .loadPopularAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .onAvatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .onCategoryPressed(category: let category):
                return [
                    "category" : category.rawValue
                ]
                
            
            default:
                return nil
                
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeatureAvatarsFail, .loadPopularAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    
    
    
    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)

    }
    
    
    private var loadingIndicador: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)

    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8){
            Text("Error")
                .font(.headline)
            Text("Please check your intener connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)

    }
    
    private func onTryAgainPressed(){

        isLoadingPopular = true
        isLoadingFeatured = true
        logManager.trackEvent(event: Event.tryAgainStart)

        Task {
            try await Task.sleep(nanoseconds: 233344443)
            await loadFeatureAvatars()
        }
        Task {
            try await Task.sleep(nanoseconds: 234444433)
            await loadPopularAvatars()
        }
    }
    
    
    private func loadFeatureAvatars() async {

        guard featureAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeatureAvatarsStart)

        
        
        do {
            featureAvatars =  try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeatureAvatarsSuccess(count: featureAvatars.count))


        } catch {
            logManager.trackEvent(event: Event.loadFeatureAvatarsFail(error: error))

        }
        isLoadingFeatured = false
    }
    
    
    private func loadPopularAvatars() async {
        
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)

        do {
            popularAvatars =  try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        isLoadingPopular = false
    }
    
    
    
    private var featuredSection: some View{
        Section {
            ZStack{
                CarouselView(items: featureAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton(.plain) {
                        onAvatarPressed(avatar: avatar)
                    }
                }
               
            }
            .removeListRowFormating()
            
        } header: {
            Text("Featured avatars")
        }
    }
    
    
    
    
    
    
    
    
    private var categorySection: some View{
        Section {
            ZStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12){
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.rawValue.capitalized ,
                                    imageName: imageName
                                )
                                .anyButton(.plain) {
                                    
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                            
                            
                           
                        }
                        
                    }
                }
                .frame(height:140)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormating()
            
        } header: {
            Text("Categories")
        }
    }
    
    
    
    
    
    
    private var popularSection: some View{
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
            }
            .removeListRowFormating()
        } header: {
            Text("Featured")
        }
    }
    
    
    
    
    
    
    private func onAvatarPressed(avatar: AvatarModel){
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String){
        path.append(.category(category: category, imageName: imageName))
    }
}

#Preview("Has data"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(deley: 0)))
}
#Preview("No data"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
}

#Preview("Slow loading"){
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(deley: 10)))
}

