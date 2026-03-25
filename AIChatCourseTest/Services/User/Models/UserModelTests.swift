//
//  UserModelTests.swift
//  AIChatCourseTest
//
//  Created by Marcin Turek on 25/03/2026.
//

import Testing
import SwiftUI
@testable import AIChatCourse

struct UserModelTests {

    @Test("UserModel initializer sets all properties correctly with random values")
    func testInitializerWithRandomValues() async throws {
        let user = UserModel(
            userId: .random(),
            email: .randomEmail(),
            isAnonymous: .random,
            creationDate: .random(),
            lastSignInDate: .random(),
            creationVersion: .random(),
            didCompleteOnboarding: .random,
            profileColorHex: "#FF5733"
        )
        
        #expect(!user.userId.isEmpty)
        #expect(user.email?.contains("@") == true)
        #expect(user.creationDate != nil)
        #expect(user.lastSignInDate != nil)
    }
    
    @Test("Codable encoding and decoding preserves values")
    func testCodableEncodeDecode() async throws {
        let original = UserModel(
            userId: .random(),
            email: .randomEmail(),
            isAnonymous: .random,
            creationDate: .random(),
            lastSignInDate: .random(),
            creationVersion: .random(),
            didCompleteOnboarding: .random,
            profileColorHex: "#123456"
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserModel.self, from: data)
        
        #expect(decoded.userId == original.userId)
        #expect(decoded.email == original.email)
        #expect(decoded.isAnonymous == original.isAnonymous)
        #expect(decoded.creationVersion == original.creationVersion)
        #expect(decoded.profileColorHex == original.profileColorHex)
    }
    
    @Test("eventParameters excludes nil values")
    func testEventParametersExcludesNil() async throws {
        let user = UserModel(
            userId: "123",
            email: nil,
            isAnonymous: nil,
            creationDate: nil,
            lastSignInDate: nil,
            creationVersion: nil,
            didCompleteOnboarding: nil,
            profileColorHex: nil
        )
        
        let params = user.eventParameters
        
        #expect(params.keys.contains("user_user_id"))
        #expect(params.keys.count == 1)
    }
    
    @Test("eventParameters includes non-nil values correctly")
    func testEventParametersIncludesNonNil() async throws {
        let user = UserModel(
            userId: "123",
            email: "test@mail.com",
            isAnonymous: true,
            creationDate: Date(),
            didCompleteOnboarding: true,
            profileColorHex: "#FFFFFF"
        )
        
        let params = user.eventParameters
        
        #expect(params["user_user_id"] as? String == "123")
        #expect(params["user_email"] as? String == "test@mail.com")
        #expect(params["user_is_anonymous"] as? Bool == true)
    }
    
    @Test("profileColorCalculated returns proper Color for valid hex")
    func testProfileColorCalculatedWithHex() async throws {
        let user = UserModel(
            userId: "1",
            profileColorHex: "#FF0000"
        )
        
        let color = user.profileColorCalculated
        
        #expect(color != .pink)
    }
    
    @Test("profileColorCalculated returns default pink when hex is nil")
    func testProfileColorCalculatedNil() async throws {
        let user = UserModel(
            userId: "1",
            profileColorHex: nil
        )
        
        #expect(user.profileColorCalculated == .pink)
    }
    
    @Test("Mock user returns first mock correctly")
    func testMockUser() async throws {
        let mock = UserModel.mock
        #expect(mock.userId == "user_001")
    }
    
    @Test("Mocks array has correct count and unique userIds")
    func testMocksArrayIntegrity() async throws {
        let mocks = UserModel.mocks
        #expect(mocks.count == 4)
        
        let ids = Set(mocks.map(\.userId))
        #expect(ids.count == mocks.count)
    }
    
    // MARK: - FAILURE / EDGE CASE TESTS
    
    @Test("Decoding invalid JSON should throw error")
    func testDecodingInvalidJSON() async throws {
        // Missing required "user_id" key
        let json = """
        {
            "email": "test@mail.com"
        }
        """.data(using: .utf8)!
        
        do {
            _ = try JSONDecoder().decode(UserModel.self, from: json)
            #expect(false) // should not reach here
        } catch {
            #expect(true) // error thrown as expected
        }
    }
    
    @Test("profileColorCalculated with invalid hex returns default pink")
    func testProfileColorCalculatedInvalidHex() async throws {
        let user = UserModel(
            userId: "1",
            profileColorHex: "INVALID_HEX"
        )
        
        #expect(user.profileColorCalculated == .pink)
    }
    
    @Test("eventParameters with all nil optionals only includes userId")
    func testEventParametersAllNil() async throws {
        let user = UserModel(
            userId: "999",
            email: nil,
            isAnonymous: nil,
            creationDate: nil,
            lastSignInDate: nil,
            creationVersion: nil,
            didCompleteOnboarding: nil,
            profileColorHex: nil
        )
        
        let params = user.eventParameters
        
        #expect(params.keys.count == 1)
        #expect(params["user_user_id"] as? String == "999")
    }
    
    @Test("Randomly generated UserModel values do not produce empty userId")
    func testRandomUserIdNotEmpty() async throws {
        let user = UserModel(
            userId: .random(),
            email: .randomEmail()
        )
        
        #expect(!user.userId.isEmpty)
    }
}
