//
//  ModalProfileView.swift
//  Finora
//
//  Created by Aryan Varmora on 12/7/25.
//

//
//  ModalProfileView.swift
//  Finora - PHASE 3: All settings improvements
//

import SwiftUI

struct ModalProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authManager = AuthenticationManager.shared
    @State private var defaultCurrency: String = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD"
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section with Monogram
                Section {
                    HStack(spacing: 16) {
                        MonogramView(
                            fullName: authManager.currentUser?.fullName ?? "User",
                            size: 60
                        )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.fullName ?? "User")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Currency Settings Section
                Section {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        ForEach(["USD", "EUR", "GBP", "INR", "CAD", "AUD", "JPY", "CNY", "MXN", "BRL"], id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                } header: {
                    Text("Currency Settings")
                } footer: {
                    Text("All amounts will be displayed in \(defaultCurrency)")
                }
                
                // Account Actions Section
                Section {
                    Button(action: {
                        // View Analytics
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToAnalytics"), object: nil)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color(hex: "8B5CF6"))
                                .frame(width: 24)
                            Text("View Analytics")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    NavigationLink(destination: TermsView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Color(hex: "3B82F6"))
                                .frame(width: 24)
                            Text("Terms & Conditions")
                        }
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(Color(hex: "10B981"))
                                .frame(width: 24)
                            Text("Privacy Policy")
                        }
                    }
                } header: {
                    Text("Information")
                }
                
                // Logout Section
                Section {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } footer: {
                    Text("Made with ❤️ by Finora Team")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
    }
}

#Preview {
    ModalProfileView()
}
