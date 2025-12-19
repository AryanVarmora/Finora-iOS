//
//  PasswordHasher.swift
//  Finora
//
//  Created by Aryan Varmora on 12/18/25.
//


//
//  PasswordHasher.swift
//  Finora
//
//  Secure password hashing using SHA-256 with salt
//

import Foundation
import CryptoKit

class PasswordHasher {
    
    // MARK: - Hash Password
    
    /// Hash a password with a randomly generated salt
    static func hash(_ password: String) -> String? {
        // Generate random salt
        let salt = generateSalt()
        
        // Hash password with salt
        return hash(password, salt: salt)
    }
    
    /// Hash a password with a specific salt
    static func hash(_ password: String, salt: String) -> String? {
        guard let passwordData = password.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            return nil
        }
        
        // Combine password and salt
        var combined = Data()
        combined.append(passwordData)
        combined.append(saltData)
        
        // Hash using SHA-256
        let hashed = SHA256.hash(data: combined)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        // Return salt:hash format
        return "\(salt):\(hashString)"
    }
    
    // MARK: - Verify Password
    
    /// Verify if a password matches a stored hash
    static func verify(_ password: String, against storedHash: String) -> Bool {
        // Split stored hash into salt and hash
        let components = storedHash.split(separator: ":")
        guard components.count == 2 else { return false }
        
        let salt = String(components[0])
        let originalHash = String(components[1])
        
        // Hash the input password with the same salt
        guard let newHash = hash(password, salt: salt) else { return false }
        
        // Extract just the hash part (after the salt)
        let newHashComponents = newHash.split(separator: ":")
        guard newHashComponents.count == 2 else { return false }
        let newHashValue = String(newHashComponents[1])
        
        // Compare hashes
        return newHashValue == originalHash
    }
    
    // MARK: - Generate Salt
    
    /// Generate a random salt
    private static func generateSalt() -> String {
        let saltLength = 16
        var bytes = [UInt8](repeating: 0, count: saltLength)
        let status = SecRandomCopyBytes(kSecRandomDefault, saltLength, &bytes)
        
        guard status == errSecSuccess else {
            // Fallback to UUID if SecRandomCopyBytes fails
            return UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
        
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Password Strength
    
    /// Check password strength
    static func checkStrength(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUpperCase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowerCase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        var score = 0
        
        if length >= 8 { score += 1 }
        if length >= 12 { score += 1 }
        if hasUpperCase { score += 1 }
        if hasLowerCase { score += 1 }
        if hasNumber { score += 1 }
        if hasSpecialChar { score += 1 }
        
        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        case 5...6:
            return .strong
        default:
            return .weak
        }
    }
}

// MARK: - Password Strength Enum

enum PasswordStrength {
    case weak
    case medium
    case strong
    
    var description: String {
        switch self {
        case .weak:
            return "Weak"
        case .medium:
            return "Medium"
        case .strong:
            return "Strong"
        }
    }
    
    var color: String {
        switch self {
        case .weak:
            return "FF3B30" // Red
        case .medium:
            return "FF9500" // Orange
        case .strong:
            return "34C759" // Green
        }
    }
}