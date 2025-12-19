//
//  TermsView.swift
//  Finora - Terms & Conditions
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms & Conditions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("These are the terms and conditions.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By using Finora, you agree to these terms and conditions.")
                        .foregroundColor(.secondary)
                    
                    Text("2. Use of Service")
                        .font(.headline)
                    Text("You may use Finora for personal expense tracking and financial management.")
                        .foregroundColor(.secondary)
                    
                    Text("3. User Responsibilities")
                        .font(.headline)
                    Text("You are responsible for maintaining the confidentiality of your account information.")
                        .foregroundColor(.secondary)
                    
                    Text("4. Data Usage")
                        .font(.headline)
                    Text("Your financial data is stored securely and will not be shared without your consent.")
                        .foregroundColor(.secondary)
                    
                    Text("5. Modifications")
                        .font(.headline)
                    Text("We reserve the right to modify these terms at any time.")
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Terms")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        TermsView()
    }
}
