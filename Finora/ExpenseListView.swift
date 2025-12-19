//
//  ExpenseListView.swift
//  Finora - OPTIMIZED (fixes type-check timeout)
//

import SwiftUI

struct ExpenseListView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var searchText = ""
    @State private var selectedCategory = "All Categories"
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showTransactionSelector = false
    
    let categories = ["All Categories", "Food", "Travel", "Shopping", "Utilities", "Entertainment", "Healthcare", "Education", "Other"]
    
    var filteredExpenses: [ExpenseEntity] {
        var result = viewModel.expenses
        
        // Filter by category
        if selectedCategory != "All Categories" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBarView
                
                // Category Filter
                categoryFilterView
                
                // Expense List
                expenseListView
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingAddIncome) {
                IncomeSettingsView()
            }
            .sheet(isPresented: $showTransactionSelector) {
                AddTransactionSelector(
                    showAddExpense: $showingAddExpense,
                    showAddIncome: $showingAddIncome
                )
            }
            .onAppear {
                viewModel.fetchExpenses()
            }
            .refreshable {
                viewModel.fetchExpenses()
            }
        }
    }
    
    // MARK: - Subviews (broken into separate computed properties)
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search expenses...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private func categoryChip(_ category: String) -> some View {
        Button(action: {
            selectedCategory = category
        }) {
            Text(category)
                .font(.subheadline)
                .fontWeight(selectedCategory == category ? .semibold : .regular)
                .foregroundColor(selectedCategory == category ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedCategory == category ?
                    Color(hex: "3B82F6") : Color(.systemGray6)
                )
                .cornerRadius(20)
        }
    }
    
    private var expenseListView: some View {
        Group {
            if filteredExpenses.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredExpenses, id: \.id) { expense in
                        ExpenseRow(expense: expense)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                deleteButton(for: expense)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Expenses Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? "Tap + to add your first expense" : "Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Button(action: { showTransactionSelector = true }) {
                    Text("Add Expense")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "3B82F6"))
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func deleteButton(for expense: ExpenseEntity) -> some View {
        Button(role: .destructive) {
            viewModel.deleteExpense(expense)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private var addButton: some View {
        Button(action: { showTransactionSelector = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "3B82F6"))
        }
    }
}

// MARK: - Expense Row Component

struct ExpenseRow: View {
    let expense: ExpenseEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            categoryIcon
            
            // Expense Details
            expenseDetails
            
            Spacer()
            
            // Amount
            amountView
        }
        .padding(.vertical, 8)
    }
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(categoryColor.opacity(0.15))
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(categoryColor)
        }
    }
    
    private var expenseDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(expense.title ?? "Untitled")
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Text(expense.category ?? "Other")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var amountView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Show converted amount (USD)
            Text("-$\(String(format: "%.2f", expense.convertedAmount))")
                .font(.headline)
                .foregroundColor(Color(hex: "EF4444"))
            
            // Show original currency if not USD
            if expense.currency != "USD" {
                Text("\(String(format: "%.0f", expense.amount)) \(expense.currency ?? "")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text(expense.currency ?? "USD")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var categoryColor: Color {
        let colorMap: [String: String] = [
            "Food": "EF4444",
            "Travel": "F59E0B",
            "Shopping": "3B82F6",
            "Utilities": "10B981",
            "Entertainment": "8B5CF6",
            "Healthcare": "EC4899",
            "Education": "6366F1",
            "Other": "6B7280"
        ]
        return Color(hex: colorMap[expense.category ?? "Other"] ?? "6B7280")
    }
    
    private var icon: String {
        switch expense.category ?? "Other" {
        case "Food": return "fork.knife"
        case "Travel": return "airplane"
        case "Shopping": return "bag"
        case "Utilities": return "bolt"
        case "Entertainment": return "tv"
        case "Healthcare": return "cross.case"
        case "Education": return "book"
        default: return "folder"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: expense.date ?? Date())
    }
}

#Preview {
    ExpenseListView()
}
