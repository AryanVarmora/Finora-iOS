//
//  AnalyticsView.swift
//  Finora - Complete Analytics with Income vs Expense Comparison
//

import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @ObservedObject var incomeManager = IncomeManager.shared
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var selectedTab: AnalyticsTab = .overview
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    periodSelector
                    
                    // Tab Selector
                    tabSelector
                    
                    // Content based on selected tab
                    switch selectedTab {
                    case .overview:
                        overviewSection
                    case .expenses:
                        expensesSection
                    case .categories:
                        categoriesSection
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            .onAppear {
                viewModel.fetchExpenses()
                incomeManager.loadIncome()
            }
        }
    }
    
    // MARK: - Keyboard Dismissal
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedPeriod == period ?
                            Color(hex: "3B82F6") : Color(.systemGray6)
                        )
                        .cornerRadius(20)
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 12) {
            ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tab.title)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                        
                        if selectedTab == tab {
                            Rectangle()
                                .fill(Color(hex: "3B82F6"))
                                .frame(height: 2)
                                .transition(.scale)
                        }
                    }
                    .foregroundColor(selectedTab == tab ? Color(hex: "3B82F6") : .secondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(spacing: 20) {
            // Income vs Expense Comparison
            incomeVsExpenseCard
            
            // Bar Chart
            incomeExpenseBarChart
            
            // Summary Stats
            summaryStatsGrid
            
            // Savings Rate
            savingsRateCard
        }
    }
    
    // MARK: - Income vs Expense Card
    
    private var incomeVsExpenseCard: some View {
        VStack(spacing: 16) {
            Text("Income vs Expenses")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Income
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(Color(hex: "10B981"))
                        Text("Income")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("$\(String(format: "%.2f", periodIncome))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "10B981"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "10B981").opacity(0.1))
                .cornerRadius(12)
                
                // Expenses
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text("Expenses")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("$\(String(format: "%.2f", periodExpenses))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "EF4444").opacity(0.1))
                .cornerRadius(12)
            }
            
            // Net Balance
            VStack(spacing: 4) {
                Text("Net Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("$\(String(format: "%.2f", netBalance))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(netBalance >= 0 ? Color(hex: "10B981") : Color(hex: "EF4444"))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Income vs Expense Bar Chart
    
    private var incomeExpenseBarChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Comparison")
                .font(.headline)
            
            if periodExpenses > 0 || periodIncome > 0 {
                IncomeExpenseBarChart(
                    income: periodIncome,
                    expenses: periodExpenses
                )
                .frame(height: 200)
            } else {
                emptyChartState
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Summary Stats Grid
    
    private var summaryStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            AnalyticsStatCard(
                title: "Daily Avg",
                value: "$\(String(format: "%.2f", dailyAverage))",
                icon: "calendar",
                color: Color(hex: "3B82F6")
            )
            
            AnalyticsStatCard(
                title: "Largest Expense",
                value: "$\(String(format: "%.2f", largestExpense))",
                icon: "arrow.up.circle",
                color: Color(hex: "EF4444")
            )
            
            AnalyticsStatCard(
                title: "Total Transactions",
                value: "\(filteredExpenses.count)",
                icon: "list.bullet",
                color: Color(hex: "8B5CF6")
            )
            
            AnalyticsStatCard(
                title: "Categories",
                value: "\(categoryCount)",
                icon: "square.grid.2x2",
                color: Color(hex: "F59E0B")
            )
        }
    }
    
    // MARK: - Savings Rate Card
    
    private var savingsRateCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Savings Rate")
                    .font(.headline)
                
                Spacer()
                
                Text("\(String(format: "%.0f", savingsRate))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(savingsRateColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(savingsRateGradient)
                        .frame(
                            width: geometry.size.width * CGFloat(min(max(savingsRate, 0), 100) / 100),
                            height: 12
                        )
                }
            }
            .frame(height: 12)
            
            Text(savingsRateMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Expenses Section
    
    private var expensesSection: some View {
        VStack(spacing: 20) {
            // Expense Trend
            expenseTrendCard
            
            // Top Expenses
            topExpensesCard
        }
    }
    
    private var expenseTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Trend")
                .font(.headline)
            
            if !filteredExpenses.isEmpty {
                ExpenseTrendChart(expenses: filteredExpenses)
                    .frame(height: 200)
            } else {
                emptyChartState
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var topExpensesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Expenses")
                .font(.headline)
            
            if !filteredExpenses.isEmpty {
                ForEach(Array(filteredExpenses.prefix(5).enumerated()), id: \.element.id) { index, expense in
                    TopExpenseRow(expense: expense, rank: index + 1)
                }
            } else {
                emptyState
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(spacing: 20) {
            categoryBreakdownCard
            categoryListCard
        }
    }
    
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
            
            if !categoryData.isEmpty {
                CategoryPieChart(categories: categoryData)
                    .frame(height: 250)
            } else {
                emptyChartState
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var categoryListCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.headline)
            
            if !categoryData.isEmpty {
                ForEach(categoryData.sorted(by: { $0.amount > $1.amount })) { category in
                    CategoryRow(category: category, total: periodExpenses)
                }
            } else {
                emptyState
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Empty States
    
    private var emptyChartState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No expenses yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Computed Properties
    
    private var periodIncome: Double {
        switch selectedPeriod {
        case .week:
            return incomeManager.monthlyIncome / 4.33 // Average weeks per month
        case .month:
            return incomeManager.monthlyIncome
        case .year:
            return incomeManager.monthlyIncome * 12
        }
    }
    
    private var periodExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    private var netBalance: Double {
        periodIncome - periodExpenses
    }
    
    private var savingsRate: Double {
        guard periodIncome > 0 else { return 0 }
        return (netBalance / periodIncome) * 100
    }
    
    private var savingsRateColor: Color {
        if savingsRate >= 20 {
            return Color(hex: "10B981")
        } else if savingsRate >= 10 {
            return Color(hex: "F59E0B")
        } else {
            return Color(hex: "EF4444")
        }
    }
    
    private var savingsRateGradient: LinearGradient {
        if savingsRate >= 20 {
            return LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "059669")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if savingsRate >= 10 {
            return LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "EF4444"), Color(hex: "DC2626")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var savingsRateMessage: String {
        if periodIncome == 0 {
            return "Set your income to track savings rate"
        } else if savingsRate >= 20 {
            return "Excellent! You're saving over 20% of your income"
        } else if savingsRate >= 10 {
            return "Good! Try to save at least 20% of your income"
        } else if savingsRate >= 0 {
            return "You're saving less than 10%. Try to cut expenses"
        } else {
            return "Warning: You're spending more than you earn!"
        }
    }
    
    private var dailyAverage: Double {
        let days: Double = selectedPeriod == .week ? 7 : (selectedPeriod == .month ? 30 : 365)
        return periodExpenses / days
    }
    
    private var largestExpense: Double {
        filteredExpenses.map { $0.convertedAmount }.max() ?? 0
    }
    
    private var categoryCount: Int {
        Set(filteredExpenses.compactMap { $0.category }).count
    }
    
    private var filteredExpenses: [ExpenseEntity] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
                return []
            }
            return viewModel.expenses.filter { $0.date ?? Date() >= weekAgo }
            
        case .month:
            return viewModel.expenses.filter {
                calendar.isDate($0.date ?? Date(), equalTo: now, toGranularity: .month)
            }
            
        case .year:
            return viewModel.expenses.filter {
                calendar.isDate($0.date ?? Date(), equalTo: now, toGranularity: .year)
            }
        }
    }
    
    private var categoryData: [CategoryChartData] {
        let categoryTotals = Dictionary(grouping: filteredExpenses) { $0.category ?? "Other" }
            .mapValues { $0.reduce(0) { $0 + $1.convertedAmount } }
        
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
        
        return categoryTotals.map { category, amount in
            CategoryChartData(
                id: UUID(),
                category: category,
                amount: amount,
                color: Color(hex: colorMap[category] ?? "6B7280")
            )
        }
    }
}

// MARK: - Supporting Types

enum AnalyticsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

enum AnalyticsTab: String, CaseIterable {
    case overview = "Overview"
    case expenses = "Expenses"
    case categories = "Categories"
    
    var title: String {
        rawValue
    }
}

struct CategoryChartData: Identifiable {
    let id: UUID
    let category: String
    let amount: Double
    let color: Color
}

// MARK: - Analytics Stat Card Component

struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    AnalyticsView()
}
