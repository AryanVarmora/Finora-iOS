//
//  LoginView.swift
//  Finora
//
//  Created by Aryan Varmora on 11/20/25.
//


//
//  LoginView.swift
//  Finora
//
//  Created by Aryan Varmora on 2025
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var rememberMe: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
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
                            .frame(height: 40)
                        
                        // Logo and Title
                        VStack(spacing: 15) {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                            
                            Text("Finora")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Smarter spending. Brighter future.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.bottom, 20)
                        
                        // Login Form Card
                        VStack(spacing: 20) {
                            Text("Welcome Back")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
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
                                        TextField("Enter your password", text: $password)
                                    } else {
                                        SecureField("Enter your password", text: $password)
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
                            }
                            
                            // Remember Me & Forgot Password
                            HStack {
                                Toggle(isOn: $rememberMe) {
                                    Text("Remember me")
                                        .font(.subheadline)
                                }
                                .toggleStyle(CheckboxToggleStyle())
                                
                                Spacer()
                                
                                Button(action: {
                                    // Forgot password action
                                }) {
                                    Text("Forgot Password?")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "3B82F6"))
                                }
                            }
                            
                            // Login Button
                            Button(action: {
                                loginUser()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            
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
                            
                            // Sign in with Apple
                            Button(action: {
                                // Apple sign in action
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                    Text("Sign in with Apple")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Register Link
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                
                                NavigationLink(destination: RegisterView()) {
                                    Text("Sign Up")
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
            .alert("Login Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func loginUser() {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            alertMessage = "Login successful!"
            showAlert = true
            // Navigate to dashboard
        }
    }
}

// Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Color(hex: "3B82F6") : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

// Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView()
}
