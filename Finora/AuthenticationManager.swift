//
//  AuthenticationManager.swift
//  Finora
//
//  Created by Aryan Varmora on 12/18/25.
//


//
//  AuthenticationManager.swift
//  Finora
//
//  Complete authentication system with backend integration
//

import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: RegisteredUser?
    
    private let userDefaultsKey = "registeredUsers"
    private let currentUserKey = "currentUser"
    
    private init() {
        loadSession()
    }
    
    // MARK: - Register with Backend
    
    func registerWithBackend(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        completion: @escaping (Result<RegisteredUser, AuthError>) -> Void
    ) {
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            completion(.failure(.emptyFields))
            return
        }
        
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        guard password.count >= 8 else {
            completion(.failure(.weakPassword))
            return
        }
        
        print("📤 Sending registration to backend...")
        
        // Call backend API
        APIManager.shared.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Backend registration successful!")
                    print("🔑 Token: \(response.token.prefix(20))...")
                    print("👤 User ID: \(response.user.id)")
                    
                    // Save token to Keychain
                    let tokenSaved = KeychainManager.shared.saveToken(response.token, for: response.user.id)
                    print("💾 Token saved to Keychain: \(tokenSaved)")
                    
                    // Create local user
                    let newUser = RegisteredUser(
                        id: response.user.id,
                        email: response.user.email,
                        password: password,
                        firstName: response.user.firstName,
                        lastName: response.user.lastName
                    )
                    
                    // Save locally too (dual approach)
                    var users = self?.loadRegisteredUsers() ?? [:]
                    users[email] = newUser
                    self?.saveRegisteredUsers(users)
                    
                    // Update auth state
                    self?.currentUser = newUser
                    self?.isAuthenticated = true
                    self?.saveSession()
                    
                    print("✅ Registration complete - user logged in")
                    completion(.success(newUser))
                    
                case .failure(let error):
                    print("❌ Backend registration failed: \(error.localizedDescription)")
                    
                    // Map API errors to AuthError
                    if error.localizedDescription.contains("already exists") {
                        completion(.failure(.emailAlreadyExists))
                    } else {
                        completion(.failure(.unknownError))
                    }
                }
            }
        }
    }
    
    // MARK: - Login with Backend
    
    func loginWithBackend(
        email: String,
        password: String,
        completion: @escaping (Result<RegisteredUser, AuthError>) -> Void
    ) {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(.emptyFields))
            return
        }
        
        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }
        
        print("📤 Sending login to backend...")
        
        // Call backend API
        APIManager.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Backend login successful!")
                    print("🔑 Token: \(response.token.prefix(20))...")
                    
                    // Save token to Keychain
                    let tokenSaved = KeychainManager.shared.saveToken(response.token, for: response.user.id)
                    print("💾 Token saved to Keychain: \(tokenSaved)")
                    
                    // Create local user
                    let user = RegisteredUser(
                        id: response.user.id,
                        email: response.user.email,
                        password: password,
                        firstName: response.user.firstName,
                        lastName: response.user.lastName
                    )
                    
                    // Update auth state
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.saveSession()
                    
                    print("✅ Login complete")
                    completion(.success(user))
                    
                case .failure(let error):
                    print("❌ Backend login failed: \(error.localizedDescription)")
                    completion(.failure(.invalidCredentials))
                }
            }
        }
    }
    
    // MARK: - Local Register (Fallback)
    
    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String
    ) -> Result<RegisteredUser, AuthError> {
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            return .failure(.emptyFields)
        }
        
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        
        guard password.count >= 8 else {
            return .failure(.weakPassword)
        }
        
        // Check if user already exists
        var users = loadRegisteredUsers() ?? [:]
        
        if users[email] != nil {
            return .failure(.emailAlreadyExists)
        }
        
        // Create new user
        let newUser = RegisteredUser(
            id: UUID().uuidString,
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        // Save user
        users[email] = newUser
        saveRegisteredUsers(users)
        
        // Update auth state
        currentUser = newUser
        isAuthenticated = true
        saveSession()
        
        return .success(newUser)
    }
    
    // MARK: - Local Login (Fallback)
    
    func login(email: String, password: String) -> Result<RegisteredUser, AuthError> {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            return .failure(.emptyFields)
        }
        
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        
        // Load users
        guard let users = loadRegisteredUsers() else {
            return .failure(.invalidCredentials)
        }
        
        // Find user
        guard let user = users[email] else {
            return .failure(.invalidCredentials)
        }
        
        // Verify password
        guard user.password == password else {
            return .failure(.invalidCredentials)
        }
        
        // Login successful
        currentUser = user
        isAuthenticated = true
        saveSession()
        
        return .success(user)
    }
    
    // MARK: - Logout
    
    func logout() {
        // Delete token from Keychain
        if let userId = currentUser?.id {
            _ = KeychainManager.shared.deleteToken(for: userId)
        }
        
        currentUser = nil
        isAuthenticated = false
        clearSession()
    }
    
    // MARK: - Update Profile
    
    func updateProfile(firstName: String, lastName: String, email: String) -> Result<RegisteredUser, AuthError> {
        // Validate input
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            return .failure(.emptyFields)
        }
        
        guard isValidEmail(email) else {
            return .failure(.invalidEmail)
        }
        
        guard let currentUser = currentUser else {
            return .failure(.invalidCredentials)
        }
        
        // Load all users
        var users = loadRegisteredUsers() ?? [:]
        
        // If email changed, check if new email already exists
        if email != currentUser.email {
            if users[email] != nil {
                return .failure(.emailAlreadyExists)
            }
            // Remove old email entry
            users.removeValue(forKey: currentUser.email)
        }
        
        // Create updated user
        let updatedUser = RegisteredUser(
            id: currentUser.id,
            email: email,
            password: currentUser.password,
            firstName: firstName,
            lastName: lastName
        )
        
        // Save updated user
        users[email] = updatedUser
        saveRegisteredUsers(users)
        
        // Update current user
        self.currentUser = updatedUser
        saveSession()
        
        return .success(updatedUser)
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - UserDefaults Storage
    
    private func saveRegisteredUsers(_ users: [String: RegisteredUser]) {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadRegisteredUsers() -> [String: RegisteredUser]? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let users = try? JSONDecoder().decode([String: RegisteredUser].self, from: data) else {
            return nil
        }
        return users
    }
    
    private func saveSession() {
        if let user = currentUser,
           let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
        }
    }
    
    private func loadSession() {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(RegisteredUser.self, from: data) else {
            return
        }
        
        currentUser = user
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
    }
    
    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
    }
}

// MARK: - Models

struct RegisteredUser: Codable {
    let id: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Errors

enum AuthError: Error, LocalizedError {
    case emptyFields
    case invalidEmail
    case weakPassword
    case emailAlreadyExists
    case invalidCredentials
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill in all fields"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .invalidCredentials:
            return "Invalid email or password"
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}