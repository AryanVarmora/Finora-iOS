//
//  IncomeSettingsView.swift
//  Finora - FIXED with backend sync
//

import SwiftUI

struct IncomeSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var incomeManager = IncomeManager.shared
    
    @State private var incomeAmount: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        TextField("0", text: $incomeAmount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Enter your monthly income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Monthly Income")
                }
                
                Section {
                    HStack(spacing: 12) {
                        quickAmountButton(amount: 1000)
                        quickAmountButton(amount: 2000)
                        quickAmountButton(amount: 3000)
                    }
                    
                    HStack(spacing: 12) {
                        quickAmountButton(amount: 5000)
                        quickAmountButton(amount: 7500)
                        quickAmountButton(amount: 10000)
                    }
                } header: {
                    Text("Quick Select")
                }
                
                if incomeManager.monthlyIncome > 0 {
                    Section {
                        HStack {
                            Text("Current Income")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(String(format: "%.2f", incomeManager.monthlyIncome))")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    } header: {
                        Text("Current Setting")
                    }
                }
                
                Section {
                    Button(action: saveIncome) {
                        HStack {
                            Spacer()
                            Text(incomeManager.monthlyIncome > 0 ? "Update Income" : "Save Income")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(incomeAmount.isEmpty)
                    
                    if incomeManager.monthlyIncome > 0 {
                        Button(role: .destructive, action: deleteIncome) {
                            HStack {
                                Spacer()
                                Text("Remove Income")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Monthly Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Income", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("Success") || alertMessage.contains("saved") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if incomeManager.monthlyIncome > 0 {
                    incomeAmount = String(format: "%.0f", incomeManager.monthlyIncome)
                }
            }
        }
    }
    
    private func quickAmountButton(amount: Int) -> some View {
        Button(action: {
            incomeAmount = String(amount)
        }) {
            Text("$\(amount)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "3B82F6"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "3B82F6").opacity(0.1))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    private func saveIncome() {
        guard let amount = Double(incomeAmount), amount > 0 else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        // Save locally
        incomeManager.saveIncome(amount)
        
        // Sync to backend
        syncIncomeToBackend(amount)
        
        alertMessage = "Income saved successfully!"
        showAlert = true
    }
    
    private func deleteIncome() {
        incomeManager.deleteIncome()
        
        // Delete from backend
        deleteIncomeFromBackend()
        
        incomeAmount = ""
        alertMessage = "Income removed successfully"
        showAlert = true
    }
    
    // MARK: - Backend Sync
    
    private func syncIncomeToBackend(_ amount: Double) {
        guard let userId = AuthenticationManager.shared.currentUser?.id,
              let token = KeychainManager.shared.getToken(for: userId) else {
            print("⚠️ No token found, skipping backend sync")
            return
        }
        
        print("📤 Syncing income to backend...")
        
        // Create income payload
        let incomeData: [String: Any] = [
            "source": "Monthly Income",
            "amount": amount,
            "frequency": "monthly",
            "category": "Salary",
            "date": ISO8601DateFormatter().string(from: Date()),
            "currency": "USD",
            "isRecurring": true
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/income") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: incomeData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Backend sync failed: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("✅ Income synced to backend!")
                } else {
                    print("⚠️ Backend returned status: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    private func deleteIncomeFromBackend() {
        guard let userId = AuthenticationManager.shared.currentUser?.id,
              let token = KeychainManager.shared.getToken(for: userId) else {
            return
        }
        
        // For now, just log - proper deletion requires getting income ID first
        print("📤 Should delete income from backend")
    }
}

#Preview {
    IncomeSettingsView()
}
