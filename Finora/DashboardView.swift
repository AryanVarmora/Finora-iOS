//
//  DashboardView.swift
//  Finora - COMPLETE REWRITE with fixes
//

import SwiftUI

// MARK: - Dashboard Models

struct ChartExpenseData: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
}

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}

enum TimePeriod: String {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @ObservedObject var authManager = AuthenticationManager.shared
    @ObservedObject var incomeManager = IncomeManager.shared
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showTransactionSelector = false
    @State private var showAnalytics = false
    @State private var showProfile = false
    @State private var showIncomeSettings = false
    @State private var showBudgetSettings = false
    
    var monthlyIncome: Double { incomeManager.monthlyIncome }
    var monthlyExpenses: Double { viewModel.getMonthlyTotal() }
    var totalBalance: Double { monthlyIncome - monthlyExpenses }
    
    var weeklyExpenses: [ChartExpenseData] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        ) else {
            return []
        }
        
        var weekData: [ChartExpenseData] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                continue
            }
            
            let dayName = dateFormatter.string(from: date)
            let dayExpenses = viewModel.expenses.filter {
                calendar.isDate($0.date ?? Date(), inSameDayAs: date)
            }
            
            let total = dayExpenses.reduce(0) { $0 + $1.convertedAmount }
            let safeTotal = (total.isNaN || total.isInfinite || total < 0) ? 0 : total
            
            weekData.append(ChartExpenseData(day: dayName, amount: safeTotal))
        }
        
        return weekData
    }
    
    var categoryExpenses: [CategoryData] {
        let categoryTotals = viewModel.expensesByCategory()
        
        let colorMap: [String: Color] = [
            "Food": Color(hex: "EF4444"),
            "Transportation": Color(hex: "F59E0B"),
            "Shopping": Color(hex: "3B82F6"),
            "Bills": Color(hex: "10B981"),
            "Entertainment": Color(hex: "8B5CF6"),
            "Health": Color(hex: "EC4899"),
            "Other": Color(hex: "6B7280")
        ]
        
        return categoryTotals.map { (category, amount) in
            CategoryData(
                category: category,
                amount: amount,
                color: colorMap[category] ?? .gray
            )
        }
        .filter { $0.amount > 0 }
        .sorted { $0.amount > $1.amount }
    }
    
    var recentTransactions: [ExpenseEntity] {
        viewModel.getRecentExpenses(limit: 5)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F0F9FF"),
                        Color(.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        modernHeader
                        heroBalanceCard
                        
                        // Budget Alerts
                        BudgetAlertsCard(
                            viewModel: viewModel,
                            showBudgetSettings: $showBudgetSettings
                        )
                        
                        quickStatsGrid
                        spendingChartSection
                        topCategoriesSection
                        recentTransactionsSection
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileButton
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showAddIncome) {
                IncomeSettingsView()
            }
            .sheet(isPresented: $showTransactionSelector) {
                AddTransactionSelector(
                    showAddExpense: $showAddExpense,
                    showAddIncome: $showAddIncome
                )
            }
            .sheet(isPresented: $showBudgetSettings) {
                BudgetSettingsView()
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsView()
            }
            .sheet(isPresented: $showProfile) {
                ModalProfileView()
            }
            .sheet(isPresented: $showIncomeSettings) {
                IncomeSettingsView()
            }
            .onAppear {
                viewModel.fetchExpenses()
                incomeManager.loadIncome()
                BudgetManager.shared.loadBudgets()
            }
            .refreshable {
                viewModel.fetchExpenses()
                BudgetManager.shared.loadBudgets()
            }
            .overlay(alignment: .bottomTrailing) {
                floatingAddButton
            }
        }
    }
    
    // MARK: - Modern Header
    
    private var modernHeader: some View {
        HStack(spacing: 12) {
            MonogramView(
                fullName: authManager.currentUser?.fullName ?? "User",
                size: 50
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(authManager.currentUser?.fullName ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(currentMonth)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(currentYear)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Hero Balance Card
    
    private var heroBalanceCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(String(format: "$%.2f", totalBalance))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                balanceTrendIndicator
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack(spacing: 20) {
                Button(action: {
                    showIncomeSettings = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green.opacity(0.8))
                            Text("Income")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        HStack(spacing: 4) {
                            Text(String(format: "$%.2f", monthlyIncome))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if monthlyIncome == 0 {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                Image(systemName: "pencil.circle")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red.opacity(0.8))
                    }
                    
                    Text(String(format: "$%.2f", monthlyExpenses))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "3B82F6"),
                        Color(hex: "2563EB"),
                        Color(hex: "1E40AF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: -50)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: 100, y: 80)
            }
        )
        .cornerRadius(24)
        .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var balanceTrendIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: totalBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
            Text(String(format: "%.1f%%", abs((monthlyExpenses / max(monthlyIncome, 1)) * 100)))
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(totalBalance >= 0 ? .green : .red)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }
    
    // MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                title: "Transactions",
                value: "\(viewModel.expenses.count)",
                icon: "list.bullet.rectangle",
                color: Color(hex: "8B5CF6")
            )
            
            QuickStatCard(
                title: "Avg/Day",
                value: String(format: "$%.0f", monthlyExpenses / 30),
                icon: "calendar",
                color: Color(hex: "EC4899")
            )
            
            QuickStatCard(
                title: "Categories",
                value: "\(categoryExpenses.count)",
                icon: "square.grid.2x2",
                color: Color(hex: "F59E0B")
            )
        }
    }
    
    // MARK: - Spending Chart Section
    
    private var spendingChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Spending")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showAnalytics = true
                }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(Color(hex: "3B82F6"))
                }
            }
            
            CustomBarChart(data: weeklyExpenses)
                .frame(height: 180)
                .padding(.vertical, 8)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Top Categories Section
    
    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Categories")
                .font(.headline)
                .fontWeight(.bold)
            
            if categoryExpenses.isEmpty {
                EmptyCategoriesView()
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryExpenses.prefix(3)) { category in
                        ModernCategoryRow(category: category, total: monthlyExpenses)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Recent Transactions Section
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: ExpenseListView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(Color(hex: "3B82F6"))
                }
            }
            
            if recentTransactions.isEmpty {
                EmptyTransactionsView {
                    showAddExpense = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(recentTransactions, id: \.id) { expense in
                        ModernTransactionRow(expense: expense)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button(action: {
            showTransactionSelector = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "3B82F6"),
                        Color(hex: "2563EB")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(color: Color(hex: "3B82F6").opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Toolbar Buttons
    
    private var profileButton: some View {
        Button(action: {
            showProfile = true
        }) {
            MonogramView(
                fullName: authManager.currentUser?.fullName ?? "User",
                size: 40
            )
        }
    }
    
    // MARK: - Helper Properties
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Category Row

struct ModernCategoryRow: View {
    let category: CategoryData
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (category.amount / total) * 100
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(category.color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: categoryIcon(category.category))
                    .font(.system(size: 20))
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.category)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(category.color)
                            .frame(
                                width: geometry.size.width * CGFloat(min(percentage, 100) / 100),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.0f", category.amount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(String(format: "%.0f%%", percentage))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Shopping": return "bag"
        case "Bills": return "doc.text"
        case "Entertainment": return "tv"
        case "Health": return "cross.case"
        case "Other": return "folder"
        default: return "folder"
        }
    }
}

// MARK: - Modern Transaction Row

struct ModernTransactionRow: View {
    let expense: ExpenseEntity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title ?? "Untitled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(expense.date ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("-$\(String(format: "%.2f", expense.convertedAmount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "EF4444"))
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var categoryColor: Color {
        let colorMap: [String: Color] = [
            "Food": Color(hex: "EF4444"),
            "Transportation": Color(hex: "F59E0B"),
            "Shopping": Color(hex: "3B82F6"),
            "Bills": Color(hex: "10B981"),
            "Entertainment": Color(hex: "8B5CF6"),
            "Health": Color(hex: "EC4899"),
            "Other": Color(hex: "6B7280")
        ]
        return colorMap[expense.category ?? "Other"] ?? .gray
    }
    
    private var categoryIcon: String {
        switch expense.category ?? "Other" {
        case "Food": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Shopping": return "bag"
        case "Bills": return "doc.text"
        case "Entertainment": return "tv"
        case "Health": return "cross.case"
        default: return "folder"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Empty States

struct EmptyCategoriesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No categories yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Add expenses to see breakdown")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct EmptyTransactionsView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No transactions yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Button(action: action) {
                Text("Add Your First Expense")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "3B82F6"),
                                Color(hex: "2563EB")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    DashboardView()
}
