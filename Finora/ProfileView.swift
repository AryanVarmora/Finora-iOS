//
//  ProfileView.swift
//  Finora - PHASE 3 COMPLETE
//
// 

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager = AuthenticationManager.shared
    @State private var showLogoutAlert = false
    @State private var defaultCurrency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Profile Header with Monogram
                VStack(spacing: 15) {
                    MonogramView(
                        fullName: authManager.currentUser?.fullName ?? "User",
                        size: 100
                    )
                    
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.fullName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                            Text("Member since January 2025")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 20)
                
                // Settings Sections
                VStack(spacing: 16) {
                    // Currency Settings
                    settingsCard {
                        VStack(spacing: 16) {
                            sectionHeader(title: "Currency Settings", icon: "dollarsign.circle.fill", color: Color(hex: "10B981"))
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Default Currency")
                                        .font(.subheadline)
                                    Spacer()
                                    Picker("Currency", selection: $defaultCurrency) {
                                        ForEach(["USD", "EUR", "GBP", "INR", "CAD", "AUD", "JPY", "CNY", "MXN", "BRL"], id: \.self) { currency in
                                            Text(currency).tag(currency)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                Text("All amounts will be displayed in \(defaultCurrency)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    
                    // Account Actions
                    settingsCard {
                        VStack(spacing: 0) {
                            sectionHeader(title: "Account", icon: "person.circle.fill", color: Color(hex: "3B82F6"))
                            
                            Divider().padding(.vertical, 12)
                            
                            // View Analytics Button (LINKED)
                            Button(action: {
                                NotificationCenter.default.post(name: NSNotification.Name("SwitchToAnalytics"), object: nil)
                                dismiss()
                            }) {
                                settingsRow(icon: "chart.bar.fill", title: "View Analytics", color: Color(hex: "8B5CF6"))
                            }
                            
                            Divider().padding(.vertical, 12)
                            
                            NavigationLink(destination: BudgetSettingsView()) {
                                settingsRow(icon: "chart.pie.fill", title: "Budget Settings", color: Color(hex: "F59E0B"))
                            }
                            
                            Divider().padding(.vertical, 12)
                            
                            NavigationLink(destination: IncomeSettingsView()) {
                                settingsRow(icon: "banknote.fill", title: "Income Settings", color: Color(hex: "10B981"))
                            }
                        }
                    }
                    
                    // Information
                    settingsCard {
                        VStack(spacing: 0) {
                            sectionHeader(title: "Information", icon: "info.circle.fill", color: Color(hex: "6B7280"))
                            
                            Divider().padding(.vertical, 12)
                            
                            NavigationLink(destination: TermsView()) {
                                settingsRow(icon: "doc.text.fill", title: "Terms & Conditions", color: Color(hex: "3B82F6"))
                            }
                            
                            Divider().padding(.vertical, 12)
                            
                            NavigationLink(destination: PrivacyView()) {
                                settingsRow(icon: "lock.shield.fill", title: "Privacy Policy", color: Color(hex: "10B981"))
                            }
                        }
                    }
                    
                    // Sign Out
                    settingsCard {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding(.vertical, 12)
                        }
                    }
                    
                    // App Version
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: defaultCurrency) { newValue in
            UserDefaults.standard.set(newValue, forKey: "defaultCurrency")
            print("💰 Currency changed to: \(newValue)")
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
    
    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
