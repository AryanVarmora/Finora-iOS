//
//  BudgetSettingsView.swift
//  Finora - COMPLETE FIX: Emoji + Text in picker
//

import SwiftUI

struct BudgetSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var budgetManager = BudgetManager.shared
    @ObservedObject var viewModel = ExpenseViewModel()
    
    @State private var showAddBudget = false
    @State private var selectedCategory = ""
    @State private var budgetAmount = ""
    @State private var showDeleteConfirmation = false
    @State private var categoryToDelete = ""
    
    let categories = ["Food", "Transportation", "Shopping", "Bills", "Entertainment", "Health", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Budget Cards
                    if budgetManager.budgets.isEmpty {
                        emptyStateView
                    } else {
                        budgetCardsSection
                    }
                    
                    // Add Budget Button
                    addBudgetButton
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Monthly Budgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                addBudgetSheet
            }
            .onAppear {
                budgetManager.loadBudgets()
                viewModel.fetchExpenses()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.0f", totalBudget))")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.0f", totalSpent))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(totalSpent > totalBudget ? .red : Color(hex: "10B981"))
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: progressColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: min(CGFloat(spentPercentage / 100) * geometry.size.width, geometry.size.width),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Budget Cards Section
    
    private var budgetCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(budgetManager.budgets, id: \.id) { budget in
                BudgetCard(
                    category: budget.category ?? "Other",
                    emoji: categoryEmoji(budget.category ?? "Other"),
                    limit: budget.limit,
                    spent: budgetManager.getSpending(for: budget.category ?? "", viewModel: viewModel),
                    onDelete: {
                        categoryToDelete = budget.category ?? ""
                        showDeleteConfirmation = true
                    },
                    onEdit: {
                        // Edit functionality
                    }
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Budgets Set")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Create budgets to track your spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }
    
    // MARK: - Add Budget Button
    
    private var addBudgetButton: some View {
        Button(action: {
            selectedCategory = ""
            budgetAmount = ""
            showAddBudget = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Add New Budget")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Add Budget Sheet
    
    private var addBudgetSheet: some View {
        NavigationView {
            Form {
                Section("Category") {
                    // Custom Category Picker with Emoji + Text
                    HStack {
                        Text("Select Category")
                        Spacer()
                        Menu {
                            ForEach(availableCategories, id: \.self) { category in
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
                            if selectedCategory.isEmpty {
                                HStack {
                                    Text("Choose a category")
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
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
                }
                
                Section("Monthly Limit") {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        
                        TextField("0", text: $budgetAmount)
                            .keyboardType(.decimalPad)
                            .font(.title3)
                    }
                    
                    // Quick Select
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            quickSelectButton(amount: 100)
                            quickSelectButton(amount: 200)
                            quickSelectButton(amount: 300)
                        }
                        
                        HStack(spacing: 12) {
                            quickSelectButton(amount: 500)
                            quickSelectButton(amount: 1000)
                            quickSelectButton(amount: 2000)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if !selectedCategory.isEmpty && !budgetAmount.isEmpty {
                    Section {
                        Button(action: saveBudget) {
                            HStack {
                                Spacer()
                                Text("Save Budget")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showAddBudget = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func quickSelectButton(amount: Int) -> some View {
        Button(action: {
            budgetAmount = String(amount)
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
    
    private func saveBudget() {
        guard !selectedCategory.isEmpty,
              let limit = Double(budgetAmount),
              limit > 0 else {
            return
        }
        
        budgetManager.setBudget(category: selectedCategory, limit: limit)
        
        showAddBudget = false
        selectedCategory = ""
        budgetAmount = ""
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
    
    // MARK: - Computed Properties
    
    private var availableCategories: [String] {
        let usedCategories = budgetManager.budgets.compactMap { $0.category }
        return categories.filter { !usedCategories.contains($0) }
    }
    
    private var totalBudget: Double {
        budgetManager.budgets.reduce(0) { $0 + $1.limit }
    }
    
    private var totalSpent: Double {
        budgetManager.budgets.reduce(0) { total, budget in
            total + budgetManager.getSpending(for: budget.category ?? "", viewModel: viewModel)
        }
    }
    
    private var spentPercentage: Double {
        guard totalBudget > 0 else { return 0 }
        return min((totalSpent / totalBudget) * 100, 100)
    }
    
    private var progressColors: [Color] {
        if spentPercentage < 50 {
            return [Color(hex: "10B981"), Color(hex: "059669")]
        } else if spentPercentage < 80 {
            return [Color(hex: "F59E0B"), Color(hex: "D97706")]
        } else {
            return [Color(hex: "EF4444"), Color(hex: "DC2626")]
        }
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    let category: String
    let emoji: String
    let limit: Double
    let spent: Double
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    private var percentage: Double {
        guard limit > 0 else { return 0 }
        return min((spent / limit) * 100, 100)
    }
    
    private var statusColor: Color {
        if percentage < 50 {
            return Color(hex: "10B981")
        } else if percentage < 80 {
            return Color(hex: "F59E0B")
        } else if percentage < 100 {
            return Color(hex: "F97316")
        } else {
            return Color(hex: "EF4444")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Category Icon with Emoji
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Text(emoji)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category)
                        .font(.headline)
                    
                    Text("$\(String(format: "%.0f", limit))/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("$\(String(format: "%.2f", spent))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", percentage))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(statusColor)
                            .frame(
                                width: min(CGFloat(percentage / 100) * geometry.size.width, geometry.size.width),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
                
                if percentage >= 80 {
                    HStack(spacing: 4) {
                        Image(systemName: percentage >= 100 ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                            .font(.caption2)
                        Text(percentage >= 100 ? "Budget exceeded!" : "Approaching limit")
                            .font(.caption)
                    }
                    .foregroundColor(statusColor)
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    BudgetSettingsView()
}
