//
//  DashboardView.swift
//  Finora
//
//  Created by Aryan Varmora on 11/20/25.
//


//
//  DashboardView.swift
//  Finora
//
//  Created by Aryan Varmora on 2025
//

import SwiftUI
import Charts

struct DashboardView: View {
    @State private var selectedPeriod: TimePeriod = .week
    @State private var totalBalance: Double = 12450.75
    @State private var monthlyIncome: Double = 8500.00
    @State private var monthlyExpenses: Double = 3249.25
    
    // Sample data for charts
    let weeklyExpenses = [
        ExpenseData(day: "Mon", amount: 450),
        ExpenseData(day: "Tue", amount: 380),
        ExpenseData(day: "Wed", amount: 520),
        ExpenseData(day: "Thu", amount: 290),
        ExpenseData(day: "Fri", amount: 680),
        ExpenseData(day: "Sat", amount: 420),
        ExpenseData(day: "Sun", amount: 310)
    ]
    
    let categoryExpenses = [
        CategoryData(category: "Food", amount: 1250, color: Color(hex: "EF4444")),
        CategoryData(category: "Travel", amount: 850, color: Color(hex: "F59E0B")),
        CategoryData(category: "Shopping", amount: 650, color: Color(hex: "3B82F6")),
        CategoryData(category: "Utilities", amount: 399, color: Color(hex: "10B981")),
        CategoryData(category: "Entertainment", amount: 100, color: Color(hex: "8B5CF6"))
    ]
    
    let recentTransactions = [
        Transaction(title: "Grocery Store", category: "Food", amount: -85.50, date: "Today", icon: "cart.fill", color: Color(hex: "EF4444")),
        Transaction(title: "Salary Deposit", category: "Income", amount: 8500.00, date: "Yesterday", icon: "dollarsign.circle.fill", color: Color(hex: "10B981")),
        Transaction(title: "Uber Ride", category: "Travel", amount: -24.30, date: "2 days ago", icon: "car.fill", color: Color(hex: "F59E0B")),
        Transaction(title: "Netflix Subscription", category: "Entertainment", amount: -15.99, date: "3 days ago", icon: "play.rectangle.fill", color: Color(hex: "8B5CF6")),
        Transaction(title: "Electric Bill", category: "Utilities", amount: -120.00, date: "4 days ago", icon: "bolt.fill", color: Color(hex: "10B981"))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Profile
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Aryan")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color(hex: "3B82F6"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Balance Card
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Balance")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("$\(totalBalance, specifier: "%.2f")")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "eye.fill")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        HStack(spacing: 40) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Income")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Text("$\(monthlyIncome, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Expenses")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Text("$\(monthlyExpenses, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    HStack(spacing: 15) {
                        QuickActionButton(icon: "plus.circle.fill", title: "Add Expense", color: Color(hex: "EF4444"))
                        QuickActionButton(icon: "arrow.down.circle.fill", title: "Add Income", color: Color(hex: "10B981"))
                        QuickActionButton(icon: "chart.bar.fill", title: "Analytics", color: Color(hex: "F59E0B"))
                        QuickActionButton(icon: "arrow.left.arrow.right", title: "Transfer", color: Color(hex: "8B5CF6"))
                    }
                    .padding(.horizontal)
                    
                    // Spending Overview
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Spending Overview")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 200)
                        }
                        
                        // Bar Chart
                        Chart(weeklyExpenses) { expense in
                            BarMark(
                                x: .value("Day", expense.day),
                                y: .value("Amount", expense.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(8)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Category Breakdown")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        ForEach(categoryExpenses) { category in
                            CategoryRow(category: category, total: monthlyExpenses)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // View all transactions
                            }) {
                                Text("View All")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "3B82F6"))
                            }
                        }
                        
                        ForEach(recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Quick Action Button Component
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// Category Row Component
struct CategoryRow: View {
    let category: CategoryData
    let total: Double
    
    var percentage: Double {
        (category.amount / total) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Text(category.category)
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(category.amount, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(percentage, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 45, alignment: .trailing)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

// Transaction Row Component
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(transaction.color.opacity(0.1))
                    .frame(width: 45, height: 45)
                
                Image(systemName: transaction.icon)
                    .foregroundColor(transaction.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(transaction.amount >= 0 ? "+$\(transaction.amount, specifier: "%.2f")" : "-$\(abs(transaction.amount), specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount >= 0 ? .green : .primary)
        }
        .padding(.vertical, 5)
    }
}

// Supporting Data Models
enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct ExpenseData: Identifiable {
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

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let amount: Double
    let date: String
    let icon: String
    let color: Color
}

#Preview {
    DashboardView()
}