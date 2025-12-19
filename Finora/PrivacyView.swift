//
//  PrivacyView.swift
//  Finora - Privacy Policy
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("It's private.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Data Collection")
                        .font(.headline)
                    Text("We collect only the information necessary to provide you with expense tracking services. This includes your email, name, and financial transaction data.")
                        .foregroundColor(.secondary)
                    
                    Text("Data Security")
                        .font(.headline)
                    Text("Your data is encrypted and stored securely. We use industry-standard security measures to protect your information.")
                        .foregroundColor(.secondary)
                    
                    Text("Data Sharing")
                        .font(.headline)
                    Text("We do not sell, trade, or share your personal information with third parties. Your financial data remains private.")
                        .foregroundColor(.secondary)
                    
                    Text("Your Rights")
                        .font(.headline)
                    Text("You have the right to access, modify, or delete your data at any time through your account settings.")
                        .foregroundColor(.secondary)
                    
                    Text("Contact")
                        .font(.headline)
                    Text("If you have any privacy concerns, please contact us through the app settings.")
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PrivacyView()
    }
}
