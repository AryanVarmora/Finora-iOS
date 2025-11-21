//
//  RegisterView.swift
//  Finora
//
//  Created by Aryan Varmora on 11/20/25.
//


//
//  RegisterView.swift
//  Finora
//
//  Created by Aryan Varmora on 2025
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var agreeToTerms: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1E3A8A"), Color(hex: "3B82F6")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Logo and Title
                    VStack(spacing: 15) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                        
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Join Finora and start tracking")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.bottom, 10)
                    
                    // Register Form Card
                    VStack(spacing: 20) {
                        // Full Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                TextField("Enter your full name", text: $fullName)
                                    .textInputAutocapitalization(.words)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                TextField("Enter your email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                
                                if showPassword {
                                    TextField("Create a password", text: $password)
                                } else {
                                    SecureField("Create a password", text: $password)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Password strength indicator
                            if !password.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(0..<4) { index in
                                        Rectangle()
                                            .fill(passwordStrength() > index ? strengthColor() : Color.gray.opacity(0.3))
                                            .frame(height: 3)
                                            .cornerRadius(2)
                                    }
                                }
                                Text(strengthText())
                                    .font(.caption)
                                    .foregroundColor(strengthColor())
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                
                                if showConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords do not match")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Terms and Conditions
                        Toggle(isOn: $agreeToTerms) {
                            HStack(spacing: 4) {
                                Text("I agree to the")
                                    .font(.subheadline)
                                Button(action: {
                                    // Show terms
                                }) {
                                    Text("Terms & Conditions")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "3B82F6"))
                                }
                            }
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        
                        // Register Button
                        Button(action: {
                            registerUser()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                agreeToTerms ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray, Color.gray]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!agreeToTerms || isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("or")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        // Sign up with Apple
                        Button(action: {
                            // Apple sign up action
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Sign up with Apple")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Login Link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "3B82F6"))
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 10)
                    }
                    .padding(30)
                    .background(Color(.systemBackground))
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Registration Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func registerUser() {
        // Validate input
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }
        
        guard password.count >= 8 else {
            alertMessage = "Password must be at least 8 characters"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            alertMessage = "Registration successful! Please log in."
            showAlert = true
            
            // After showing alert, navigate back to login
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }
    
    func passwordStrength() -> Int {
        let length = password.count
        let hasUpperCase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowerCase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        var strength = 0
        if length >= 8 { strength += 1 }
        if hasUpperCase && hasLowerCase { strength += 1 }
        if hasNumbers { strength += 1 }
        if hasSpecialChar { strength += 1 }
        
        return strength
    }
    
    func strengthColor() -> Color {
        switch passwordStrength() {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray
        }
    }
    
    func strengthText() -> String {
        switch passwordStrength() {
        case 1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Strong"
        default: return ""
        }
    }
}

#Preview {
    RegisterView()
}
