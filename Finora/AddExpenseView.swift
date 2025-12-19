//
//  AddExpenseView.swift
//  Finora - COMPLETE FIX: Emoji + Text everywhere
//

import SwiftUI
import CoreData

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ExpenseViewModel()
    private let currencyService = CurrencyAPIService.shared
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var selectedCurrency: String = "USD"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isConverting = false
    @State private var previewConvertedAmount: Double = 0
    
    let categories = ["Food", "Transportation", "Shopping", "Bills", "Entertainment", "Health", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    
                    // Category Picker with Emoji + Text
                    HStack {
                        Text("Category")
                        Spacer()
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    HStack {
                                        Text(categoryEmoji(category))
                                        Text(category)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(categoryEmoji(selectedCategory))
                                Text(selectedCategory)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Amount") {
                    HStack {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .onChange(of: amount) { _ in
                                updateConversionPreview()
                            }
                        
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencyService.getSupportedCurrencies(), id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedCurrency) { _ in
                            updateConversionPreview()
                        }
                    }
                    
                    if selectedCurrency != "USD" && !amount.isEmpty {
                        if isConverting {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Converting...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if previewConvertedAmount > 0 {
                            Text("≈ $\(String(format: "%.2f", previewConvertedAmount)) USD")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Date") {
                    DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
            .alert("Expense", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("Success") || alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateConversionPreview() {
        guard !amount.isEmpty,
              let amountValue = Double(amount),
              selectedCurrency != "USD" else {
            previewConvertedAmount = 0
            return
        }
        
        isConverting = true
        
        currencyService.convertCurrency(amount: amountValue, from: selectedCurrency, to: "USD") { result in
            DispatchQueue.main.async {
                isConverting = false
                if case .success(let converted) = result {
                    previewConvertedAmount = converted
                }
            }
        }
    }
    
    private func saveExpense() {
        guard !title.isEmpty, let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter valid details"
            showAlert = true
            return
        }
        
        // If currency is USD, save directly
        if selectedCurrency == "USD" {
            let expense = ExpenseEntity(context: CoreDataManager.shared.context)
            expense.id = UUID()
            expense.userId = AuthenticationManager.shared.currentUser?.id ?? ""
            expense.title = title
            expense.amount = amountValue
            expense.category = selectedCategory
            expense.date = date
            expense.currency = "USD"
            expense.convertedAmount = amountValue
            expense.notes = notes.isEmpty ? nil : notes
            expense.timestamp = Date()
            
            do {
                try CoreDataManager.shared.context.save()
                viewModel.syncExpenseToBackend(expense)
                alertMessage = "Expense added successfully!"
                showAlert = true
            } catch {
                alertMessage = "Failed to save expense: \(error.localizedDescription)"
                showAlert = true
            }
        } else {
            // Convert currency to USD
            isConverting = true
            
            currencyService.convertCurrency(amount: amountValue, from: selectedCurrency, to: "USD") { result in
                DispatchQueue.main.async {
                    isConverting = false
                    
                    switch result {
                    case .success(let convertedValue):
                        let expense = ExpenseEntity(context: CoreDataManager.shared.context)
                        expense.id = UUID()
                        expense.userId = AuthenticationManager.shared.currentUser?.id ?? ""
                        expense.title = title
                        expense.amount = amountValue
                        expense.category = selectedCategory
                        expense.date = date
                        expense.currency = selectedCurrency
                        expense.convertedAmount = convertedValue
                        expense.notes = notes.isEmpty ? nil : notes
                        expense.timestamp = Date()
                        
                        do {
                            try CoreDataManager.shared.context.save()
                            viewModel.syncExpenseToBackend(expense)
                            alertMessage = "Expense added successfully!\n\(selectedCurrency) \(String(format: "%.2f", amountValue)) = $\(String(format: "%.2f", convertedValue)) USD"
                            showAlert = true
                        } catch {
                            alertMessage = "Failed to save expense: \(error.localizedDescription)"
                            showAlert = true
                        }
                        
                    case .failure(let error):
                        alertMessage = "Currency conversion failed: \(error.localizedDescription)\nPlease try again."
                        showAlert = true
                    }
                }
            }
        }
    }
    
    private func categoryEmoji(_ category: String) -> String {
        switch category {
        case "Food": return "🍴"
        case "Transportation": return "🚗"
        case "Shopping": return "🛍️"
        case "Bills": return "💡"
        case "Entertainment": return "🎬"
        case "Health": return "🏥"
        default: return "📌"
        }
    }
}

#Preview {
    AddExpenseView()
}
