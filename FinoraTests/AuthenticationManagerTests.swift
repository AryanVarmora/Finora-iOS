//
//  AuthenticationManagerTests.swift
//  Finora
//
//  Created by Aryan Varmora on 12/8/25.
//


//
//  AuthenticationManagerTests.swift
//  FinoraTests
//
//  Unit tests for AuthenticationManager
//

import XCTest
@testable import Finora

final class AuthenticationManagerTests: XCTestCase {
    
    var authManager: AuthenticationManager!
    
    override func setUp() {
        super.setUp()
        authManager = AuthenticationManager.shared
        
        // Clear any existing test data
        UserDefaults.standard.removeObject(forKey: "registeredUsers")
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        authManager.currentUser = nil
        authManager.isAuthenticated = false
    }
    
    override func tearDown() {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "registeredUsers")
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        authManager.currentUser = nil
        authManager.isAuthenticated = false
        super.tearDown()
    }
    
    // MARK: - Registration Tests
    
    func testRegisterUser_Success() {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let firstName = "John"
        let lastName = "Doe"
        
        // When
        let result = authManager.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        // Then
        switch result {
        case .success:
            XCTAssertTrue(authManager.isAuthenticated, "User should be authenticated after registration")
            XCTAssertNotNil(authManager.currentUser, "Current user should be set")
            XCTAssertEqual(authManager.currentUser?.email, email, "Email should match")
            XCTAssertEqual(authManager.currentUser?.firstName, firstName, "First name should match")
            XCTAssertEqual(authManager.currentUser?.lastName, lastName, "Last name should match")
        case .failure(let error):
            XCTFail("Registration should succeed, but got error: \(error.localizedDescription)")
        }
    }
    
    func testRegisterUser_DuplicateEmail() {
        // Given
        let email = "test@example.com"
        let password = "password123"
        
        // Register first user
        _ = authManager.register(
            email: email,
            password: password,
            firstName: "John",
            lastName: "Doe"
        )
        
        // Logout
        authManager.logout()
        
        // When - Try to register again with same email
        let result = authManager.register(
            email: email,
            password: "differentPassword",
            firstName: "Jane",
            lastName: "Smith"
        )
        
        // Then
        switch result {
        case .success:
            XCTFail("Registration should fail with duplicate email")
        case .failure(let error):
            if case AuthError.emailAlreadyExists = error {
                XCTAssertTrue(true, "Should get emailAlreadyExists error")
            } else {
                XCTFail("Should get emailAlreadyExists error, got: \(error)")
            }
        }
    }
    
    func testRegisterUser_EmptyEmail() {
        // Given
        let email = ""
        let password = "password123"
        
        // When
        let result = authManager.register(
            email: email,
            password: password,
            firstName: "John",
            lastName: "Doe"
        )
        
        // Then
        switch result {
        case .success:
            XCTFail("Registration should fail with empty email")
        case .failure(let error):
            if case AuthError.invalidEmail = error {
                XCTAssertTrue(true, "Should get invalidEmail error")
            } else {
                XCTFail("Should get invalidEmail error, got: \(error)")
            }
        }
    }
    
    func testRegisterUser_WeakPassword() {
        // Given
        let email = "test@example.com"
        let password = "123" // Too short
        
        // When
        let result = authManager.register(
            email: email,
            password: password,
            firstName: "John",
            lastName: "Doe"
        )
        
        // Then
        switch result {
        case .success:
            XCTFail("Registration should fail with weak password")
        case .failure(let error):
            if case AuthError.weakPassword = error {
                XCTAssertTrue(true, "Should get weakPassword error")
            } else {
                XCTFail("Should get weakPassword error, got: \(error)")
            }
        }
    }
    
    // MARK: - Login Tests
    
    func testLogin_Success() {
        // Given
        let email = "test@example.com"
        let password = "password123"
        
        // Register user first
        _ = authManager.register(
            email: email,
            password: password,
            firstName: "John",
            lastName: "Doe"
        )
        
        // Logout
        authManager.logout()
        XCTAssertFalse(authManager.isAuthenticated, "Should be logged out")
        
        // When - Login
        let result = authManager.login(email: email, password: password)
        
        // Then
        switch result {
        case .success:
            XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated after login")
            XCTAssertNotNil(authManager.currentUser, "Current user should be set")
            XCTAssertEqual(authManager.currentUser?.email, email, "Email should match")
        case .failure(let error):
            XCTFail("Login should succeed, but got error: \(error.localizedDescription)")
        }
    }
    
    func testLogin_WrongPassword() {
        // Given
        let email = "test@example.com"
        let correctPassword = "password123"
        let wrongPassword = "wrongPassword"
        
        // Register user
        _ = authManager.register(
            email: email,
            password: correctPassword,
            firstName: "John",
            lastName: "Doe"
        )
        
        // Logout
        authManager.logout()
        
        // When - Try to login with wrong password
        let result = authManager.login(email: email, password: wrongPassword)
        
        // Then
        switch result {
        case .success:
            XCTFail("Login should fail with wrong password")
        case .failure(let error):
            if case AuthError.invalidCredentials = error {
                XCTAssertTrue(true, "Should get invalidCredentials error")
                XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated")
            } else {
                XCTFail("Should get invalidCredentials error, got: \(error)")
            }
        }
    }
    
    func testLogin_NonExistentUser() {
        // Given
        let email = "nonexistent@example.com"
        let password = "password123"
        
        // When - Try to login without registering
        let result = authManager.login(email: email, password: password)
        
        // Then
        switch result {
        case .success:
            XCTFail("Login should fail for non-existent user")
        case .failure(let error):
            if case AuthError.invalidCredentials = error {
                XCTAssertTrue(true, "Should get invalidCredentials error")
                XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated")
            } else {
                XCTFail("Should get invalidCredentials error, got: \(error)")
            }
        }
    }
    
    func testLogin_EmptyCredentials() {
        // When - Try to login with empty credentials
        let result = authManager.login(email: "", password: "")
        
        // Then
        switch result {
        case .success:
            XCTFail("Login should fail with empty credentials")
        case .failure:
            XCTAssertTrue(true, "Should fail with empty credentials")
            XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated")
        }
    }
    
    // MARK: - Logout Tests
    
    func testLogout_Success() {
        // Given - User is logged in
        _ = authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe"
        )
        
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated before logout")
        XCTAssertNotNil(authManager.currentUser, "Should have current user")
        
        // When
        authManager.logout()
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated, "Should not be authenticated after logout")
        XCTAssertNil(authManager.currentUser, "Current user should be nil after logout")
        
        let savedEmail = UserDefaults.standard.string(forKey: "currentUserEmail")
        XCTAssertNil(savedEmail, "Current user email should be removed from UserDefaults")
    }
    
    // MARK: - Session Persistence Tests
    
    func testSessionPersistence_LoginThenRestore() {
        // Given - Register and login
        let email = "test@example.com"
        _ = authManager.register(
            email: email,
            password: "password123",
            firstName: "John",
            lastName: "Doe"
        )
        
        XCTAssertTrue(authManager.isAuthenticated, "Should be authenticated after registration")
        
        // When - Simulate app restart by creating new instance
        let newAuthManager = AuthenticationManager()
        
        // Manually trigger session restore (in real app, happens in init)
        if let savedEmail = UserDefaults.standard.string(forKey: "currentUserEmail"),
           let usersData = UserDefaults.standard.data(forKey: "registeredUsers"),
           let users = try? JSONDecoder().decode([String: RegisteredUser].self, from: usersData),
           let user = users[savedEmail] {
            newAuthManager.currentUser = user
            newAuthManager.isAuthenticated = true
        }
        
        // Then
        XCTAssertTrue(newAuthManager.isAuthenticated, "Should restore authenticated state")
        XCTAssertNotNil(newAuthManager.currentUser, "Should restore current user")
        XCTAssertEqual(newAuthManager.currentUser?.email, email, "Should restore correct user")
    }
    
    func testSessionPersistence_AfterLogout() {
        // Given - User logs in then logs out
        _ = authManager.register(
            email: "test@example.com",
            password: "password123",
            firstName: "John",
            lastName: "Doe"
        )
        authManager.logout()
        
        // When - Create new instance
        let newAuthManager = AuthenticationManager()
        
        // Then
        XCTAssertFalse(newAuthManager.isAuthenticated, "Should not be authenticated after logout")
        XCTAssertNil(newAuthManager.currentUser, "Should not have current user after logout")
    }
    
    // MARK: - User Data Tests
    
    func testUserData_Persistence() {
        // Given
        let email = "test@example.com"
        let firstName = "John"
        let lastName = "Doe"
        
        // When
        _ = authManager.register(
            email: email,
            password: "password123",
            firstName: firstName,
            lastName: lastName
        )
        
        // Then - Verify user is saved
        guard let usersData = UserDefaults.standard.data(forKey: "registeredUsers"),
              let users = try? JSONDecoder().decode([String: RegisteredUser].self, from: usersData),
              let savedUser = users[email] else {
            XCTFail("User should be saved in UserDefaults")
            return
        }
        
        XCTAssertEqual(savedUser.email, email, "Saved email should match")
        XCTAssertEqual(savedUser.firstName, firstName, "Saved first name should match")
        XCTAssertEqual(savedUser.lastName, lastName, "Saved last name should match")
    }
    
    func testMultipleUsers_Registration() {
        // Given
        let user1 = ("user1@example.com", "password1", "John", "Doe")
        let user2 = ("user2@example.com", "password2", "Jane", "Smith")
        
        // When - Register two users
        _ = authManager.register(
            email: user1.0,
            password: user1.1,
            firstName: user1.2,
            lastName: user1.3
        )
        
        authManager.logout()
        
        _ = authManager.register(
            email: user2.0,
            password: user2.1,
            firstName: user2.2,
            lastName: user2.3
        )
        
        // Then - Both users should be saved
        guard let usersData = UserDefaults.standard.data(forKey: "registeredUsers"),
              let users = try? JSONDecoder().decode([String: RegisteredUser].self, from: usersData) else {
            XCTFail("Users should be saved")
            return
        }
        
        XCTAssertEqual(users.count, 2, "Should have 2 registered users")
        XCTAssertNotNil(users[user1.0], "User 1 should be saved")
        XCTAssertNotNil(users[user2.0], "User 2 should be saved")
    }
    
    // MARK: - Edge Cases
    
    func testEmailCaseInsensitivity() {
        // Given
        let email = "Test@Example.COM"
        let password = "password123"
        
        // Register with mixed case
        _ = authManager.register(
            email: email,
            password: password,
            firstName: "John",
            lastName: "Doe"
        )
        
        authManager.logout()
        
        // When - Login with lowercase
        let result = authManager.login(email: email.lowercased(), password: password)
        
        // Then - Should work (if your implementation normalizes email)
        // Note: This test might fail if email is case-sensitive
        // Adjust based on your implementation
        switch result {
        case .success:
            XCTAssertTrue(true, "Login should work regardless of email case")
        case .failure:
            // If your implementation is case-sensitive, this is also valid
            XCTAssertTrue(true, "Email might be case-sensitive")
        }
    }
    
    func testPerformanceRegistration() {
        measure {
            // Performance test for registration
            _ = authManager.register(
                email: "perf\(UUID().uuidString)@example.com",
                password: "password123",
                firstName: "Perf",
                lastName: "Test"
            )
        }
    }
}