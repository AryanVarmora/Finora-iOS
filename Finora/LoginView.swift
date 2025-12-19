//
//  LoginView.swift
//  Finora - FIXED with better alerts and local auth fallback
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showRegister: Bool = false
    
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
                            .frame(height: 60)
                        
                        // Logo and Title
                        VStack(spacing: 15) {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                            
                            Text("Welcome Back")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Sign in to continue")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.bottom, 20)
                        
                        // Login Form Card
                        VStack(spacing: 20) {
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
                                        .autocorrectionDisabled()
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
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            
                            // Register Link
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showRegister = true
                                }) {
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
            .navigationBarHidden(true)
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
    
    func loginUser() {
        // Validation
        guard !email.isEmpty else {
            alertTitle = "Email Required"
            alertMessage = "Please enter your email address"
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertTitle = "Password Required"
            alertMessage = "Please enter your password"
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            alertTitle = "Invalid Email"
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Try backend login first
        authManager.loginWithBackend(email: email, password: password) { result in
            switch result {
            case .success(let user):
                print("✅ Backend login successful")
                isLoading = false
                alertTitle = "Success"
                alertMessage = "Welcome back, \(user.fullName)!"
                showAlert = true
                
            case .failure(let error):
                print("⚠️ Backend login failed, trying local...")
                
                // Fallback to local login for old accounts
                let localResult = authManager.login(email: email, password: password)
                
                isLoading = false
                
                switch localResult {
                case .success(let user):
                    alertTitle = "Success"
                    alertMessage = "Welcome back, \(user.fullName)! (Local account)"
                    showAlert = true
                    
                case .failure(let authError):
                    alertTitle = "Login Failed"
                    
                    switch authError {
                    case .emptyFields:
                        alertMessage = "Please fill in all fields"
                    case .invalidEmail:
                        alertMessage = "Invalid email format"
                    case .invalidCredentials:
                        alertMessage = "Incorrect email or password. Please check your credentials and try again."
                    case .unknownError:
                        alertMessage = "An error occurred. Please try again later."
                    default:
                        alertMessage = error.localizedDescription
                    }
                    
                    showAlert = true
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LoginView()
}
