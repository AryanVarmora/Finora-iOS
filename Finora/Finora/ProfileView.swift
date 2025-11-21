//
//  ProfileView.swift
//  Finora
//
//  Created by Aryan Varmora on 11/20/25.
//


//
//  ProfileView.swift
//  Finora
//
//  Created by Aryan Varmora on 2025
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var notificationsEnabled = true
    @State private var biometricsEnabled = true
    @State private var darkModeEnabled = false
    
    let user = UserProfile(
        name: "Aryan Varmora",
        email: "aryan@finora.app",
        memberSince: "January 2025",
        profileImage: "person.crop.circle.fill"
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profile Header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: user.profileImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text("Member since \(user.memberSince)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                    
                    Button(action: {
                        showEditProfile = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    }
                }
                .padding(.vertical, 20)
                
                // Statistics Cards
                HStack(spacing: 15) {
                    StatCard(title: "Total Expenses", value: "$3,249", icon: "arrow.up.circle.fill", color: Color(hex: "EF4444"))
                    StatCard(title: "Total Income", value: "$8,500", icon: "arrow.down.circle.fill", color: Color(hex: "10B981"))
                }
                .padding(.horizontal)
                
                // Account Settings Section
                VStack(spacing: 0) {
                    SectionHeader(title: "Account Settings")
                    
                    SettingsRow(icon: "person.fill", title: "Personal Information", color: Color(hex: "3B82F6")) {
                        // Navigate to personal info
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "key.fill", title: "Change Password", color: Color(hex: "F59E0B")) {
                        // Navigate to change password
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "dollarsign.circle.fill", title: "Currency Preferences", color: Color(hex: "10B981")) {
                        // Navigate to currency settings
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Preferences Section
                VStack(spacing: 0) {
                    SectionHeader(title: "Preferences")
                    
                    ToggleSettingsRow(
                        icon: "bell.fill",
                        title: "Push Notifications",
                        subtitle: "Receive expense reminders",
                        color: Color(hex: "8B5CF6"),
                        isOn: $notificationsEnabled
                    )
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    ToggleSettingsRow(
                        icon: "faceid",
                        title: "Biometric Authentication",
                        subtitle: "Use Face ID or Touch ID",
                        color: Color(hex: "EF4444"),
                        isOn: $biometricsEnabled
                    )
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    ToggleSettingsRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        subtitle: "Switch to dark theme",
                        color: Color(hex: "6366F1"),
                        isOn: $darkModeEnabled
                    )
                }
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Data & Privacy Section
                VStack(spacing: 0) {
                    SectionHeader(title: "Data & Privacy")
                    
                    SettingsRow(icon: "doc.text.fill", title: "Export Data", color: Color(hex: "3B82F6")) {
                        // Export data action
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "shield.fill", title: "Privacy Policy", color: Color(hex: "10B981")) {
                        // Show privacy policy
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "doc.plaintext.fill", title: "Terms of Service", color: Color(hex: "F59E0B")) {
                        // Show terms
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Support Section
                VStack(spacing: 0) {
                    SectionHeader(title: "Support")
                    
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", color: Color(hex: "6366F1")) {
                        // Navigate to help
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "envelope.fill", title: "Contact Support", color: Color(hex: "8B5CF6")) {
                        // Contact support
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    SettingsRow(icon: "star.fill", title: "Rate App", color: Color(hex: "F59E0B")) {
                        // Rate app
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Logout Button
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "EF4444").opacity(0.1))
                    .foregroundColor(Color(hex: "EF4444"))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // App Version
                Text("Finora v1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                
                Spacer()
                    .frame(height: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                // Perform logout
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: user)
        }
    }
}

// Section Header Component
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

// Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

// Toggle Settings Row Component
struct ToggleSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// User Profile Model
struct UserProfile {
    let name: String
    let email: String
    let memberSince: String
    let profileImage: String
}

// Edit Profile View (Placeholder)
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let user: UserProfile
    @State private var name: String
    @State private var email: String
    
    init(user: UserProfile) {
        self.user = user
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("Profile Picture")) {
                    Button(action: {
                        // Change profile picture
                    }) {
                        HStack {
                            Text("Change Profile Picture")
                            Spacer()
                            Image(systemName: "photo")
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}