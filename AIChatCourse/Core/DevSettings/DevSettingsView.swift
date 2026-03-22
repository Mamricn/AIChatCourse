//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 12/03/2026.
//

import SwiftUI
import SwiftfulUtilities



struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager

    
    @Environment(\.dismiss) private var dismiss
    
    @State private var createAccountTest: Bool = false
    @State private var onBoardingCommunityTest: Bool = false
    @State private var categoryRowTest: CategoryRowTestOptions = .default



    
    
    var body: some View {
        NavigationStack {
            List {
               
                abTestSection
                authSection
                userSection
                deviceSection
                
                
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
            .screenAppearAnalytics(name: "DevSettings")
            .onFirstAppear {
                loadABTest()
            }
        }
    }
    
    private func loadABTest(){
        createAccountTest = abTestManager.activeTest.createAccountTest
        onBoardingCommunityTest = abTestManager.activeTest.onboardingCommunityTest
        categoryRowTest = abTestManager.activeTest.categoryRowTest

    }
    
    
    
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton(.plain){
                onBackButtonPressed()
            }
            
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    
    private func handleCreatAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTest.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    
    private func handleOnBoardingCommunityTestChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onBoardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTest.onboardingCommunityTest,
            updateAction: { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
        )
    }
    
    private func handleOnCategoryRowOptionTestChange(oldValue: CategoryRowTestOptions, newValue: CategoryRowTestOptions) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: abTestManager.activeTest.categoryRowTest,
            updateAction: { tests in
                tests.update(categoryRowTest: newValue)
            }
        )
    }
    
    private func updateTest<T: Equatable>(
                            property: inout T,
                            newValue: T,
                            savedValue: T,
                            updateAction: (inout ActiveABTest) -> Void){
        if newValue != savedValue {
            do {
                var tests = abTestManager.activeTest
                updateAction(&tests)
                try abTestManager.override(updatedTest: tests)
            } catch {
                property = savedValue
            }
        }
    }
    
    
    private var abTestSection: some View {
        Section {
            
            Toggle("Create Acc Test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreatAccountChange)
            
            Toggle("Onboarding Community  Test", isOn: $onBoardingCommunityTest)
                .onChange(of: onBoardingCommunityTest, handleOnBoardingCommunityTestChange)
            
            Picker("Category Row Test", selection: $categoryRowTest) {
                ForEach(CategoryRowTestOptions.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: categoryRowTest, handleOnCategoryRowOptionTestChange)

           
        } header: {
            Text("AB Test")
        }
        .font(.caption)
    }
    
    
    
    
    
    private var authSection: some View {
        Section {
            
            let array = authManager.auth?.eventParameters.asAlphaticalArray ?? []

            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("Auth Info")
        }
    }
    
    
    private var userSection: some View {
        Section {
            
            let array = userManager.currentUser?.eventParameters.asAlphaticalArray ?? []

            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
        
            let array = Utilities.eventParameters.asAlphaticalArray
            ForEach(array, id: \.key){ item in
                itemRow(item: item)
            }
           
        } header: {
            Text("User Info")
        }
        
    }
    
    
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack{
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value){
                Text(value)
            } else {
                Text("Unknown")
            }
            
            
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
