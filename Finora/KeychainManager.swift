//
//  KeychainManager.swift
//  Finora
//
//  Created by Aryan Varmora on 12/18/25.
//


//
//  KeychainManager.swift
//  Finora
//
//  Secure storage for sensitive data using iOS Keychain
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Save to Keychain
    
    func save(_ data: Data, service: String, account: String) -> Bool {
        // Create query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func save(_ string: String, service: String, account: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, service: service, account: account)
    }
    
    // MARK: - Retrieve from Keychain
    
    func retrieve(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    func retrieveString(service: String, account: String) -> String? {
        guard let data = retrieve(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Update Keychain
    
    func update(_ data: Data, service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Delete from Keychain
    
    func delete(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Delete All
    
    func deleteAll(service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Convenience Extensions

extension KeychainManager {
    
    // Service identifiers
    private static let passwordService = "com.finora.passwords"
    private static let tokenService = "com.finora.tokens"
    
    // MARK: - Password Storage
    
    func savePassword(_ password: String, for email: String) -> Bool {
        return save(password, service: Self.passwordService, account: email)
    }
    
    func getPassword(for email: String) -> String? {
        return retrieveString(service: Self.passwordService, account: email)
    }
    
    func deletePassword(for email: String) -> Bool {
        return delete(service: Self.passwordService, account: email)
    }
    
    // MARK: - Token Storage
    
    func saveToken(_ token: String, for userID: String) -> Bool {
        return save(token, service: Self.tokenService, account: userID)
    }
    
    func getToken(for userID: String) -> String? {
        return retrieveString(service: Self.tokenService, account: userID)
    }
    
    func deleteToken(for userID: String) -> Bool {
        return delete(service: Self.tokenService, account: userID)
    }
    
    func deleteAllTokens() -> Bool {
        return deleteAll(service: Self.tokenService)
    }
}