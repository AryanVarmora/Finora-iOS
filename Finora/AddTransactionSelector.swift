//
//  AddTransactionSelector.swift
//  Finora
//
//  Created by Aryan Varmora on 12/6/25.
//


//
//  AddTransactionSelector.swift
//  Finora - Bottom Sheet to Choose Income or Expense
//

import SwiftUI

struct AddTransactionSelector: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showAddExpense: Bool
    @Binding var showAddIncome: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            // Title
            Text("Add Transaction")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.vertical, 20)
            
            // Options
            VStack(spacing: 16) {
                // Add Expense Option
                addExpenseButton
                
                // Add Income Option
                addIncomeButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
    
    // MARK: - Add Expense Button
    
    private var addExpenseButton: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAddExpense = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "EF4444").opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Expense")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Record money spent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Add Income Button
    
    private var addIncomeButton: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAddIncome = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "10B981").opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "10B981"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Income")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Record money earned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AddTransactionSelector(
        showAddExpense: .constant(false),
        showAddIncome: .constant(false)
    )
}