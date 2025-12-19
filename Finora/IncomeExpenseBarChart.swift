//
//  AnalyticsCharts.swift
//  Finora - Custom Charts for Analytics
//

import SwiftUI

// MARK: - Income vs Expense Bar Chart

struct IncomeExpenseBarChart: View {
    let income: Double
    let expenses: Double
    
    private var maxValue: Double {
        max(income, expenses, 100)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 40) {
                // Income Bar
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.0f", income))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "10B981"))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: barHeight(for: income, maxHeight: geometry.size.height - 40))
                    
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Expense Bar
                VStack(spacing: 8) {
                    Text("$\(String(format: "%.0f", expenses))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "EF4444"), Color(hex: "DC2626")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: barHeight(for: expenses, maxHeight: geometry.size.height - 40))
                    
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }
    
    private func barHeight(for value: Double, maxHeight: CGFloat) -> CGFloat {
        guard maxValue > 0 else { return 10 }
        let height = (value / maxValue) * maxHeight
        return max(height, 10)
    }
}

// MARK: - Expense Trend Chart

struct ExpenseTrendChart: View {
    let expenses: [ExpenseEntity]
    
    private var dailyTotals: [(day: String, amount: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        // Get last 7 days
        var data: [(day: String, amount: Double)] = []
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) else {
                continue
            }
            
            let dayName = dateFormatter.string(from: date)
            let dayExpenses = expenses.filter {
                calendar.isDate($0.date ?? Date(), inSameDayAs: date)
            }
            let total = dayExpenses.reduce(0) { $0 + $1.convertedAmount }
            
            data.append((dayName, total))
        }
        
        return data
    }
    
    private var maxAmount: Double {
        dailyTotals.map { $0.amount }.max() ?? 100
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(dailyTotals.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 8) {
                        if item.amount > 0 {
                            Text("$\(String(format: "%.0f", item.amount))")
                                .font(.caption2)
                                .foregroundColor(Color(hex: "3B82F6"))
                        } else {
                            Text(" ")
                                .font(.caption2)
                        }
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: barHeight(for: item.amount, maxHeight: geometry.size.height - 40))
                        
                        Text(item.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func barHeight(for amount: Double, maxHeight: CGFloat) -> CGFloat {
        guard maxAmount > 0 else { return 5 }
        let height = (amount / maxAmount) * maxHeight
        return max(height, 5)
    }
}

// MARK: - Category Pie Chart

struct CategoryPieChart: View {
    let categories: [CategoryChartData]
    
    private var total: Double {
        categories.reduce(0) { $0 + $1.amount }
    }
    
    private var slices: [(startAngle: Double, endAngle: Double, data: CategoryChartData)] {
        var currentAngle: Double = 0
        var result: [(Double, Double, CategoryChartData)] = []
        
        for category in categories {
            let percentage = category.amount / total
            let angle = percentage * 360
            result.append((currentAngle, currentAngle + angle, category))
            currentAngle += angle
        }
        
        return result
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Pie Chart
            ZStack {
                ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                    PieSlice(
                        startAngle: .degrees(slice.startAngle - 90),
                        endAngle: .degrees(slice.endAngle - 90)
                    )
                    .fill(slice.data.color)
                }
            }
            .frame(width: 140, height: 140)
            
            // Legend
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(categories.prefix(5).enumerated()), id: \.element.id) { index, category in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        
                        Text(category.category)
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.0f", category.amount))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Pie Slice Shape

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Top Expense Row

struct TopExpenseRow: View {
    let expense: ExpenseEntity
    let rank: Int
    
    private var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(medalEmoji)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title ?? "Untitled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(expense.category ?? "Other")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", expense.convertedAmount))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "EF4444"))
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: CategoryChartData
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (category.amount / total) * 100
    }
    
    private var icon: String {
        switch category.category {
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
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
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
                Text("$\(String(format: "%.0f", category.amount))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text("\(String(format: "%.0f", percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        IncomeExpenseBarChart(income: 5000, expenses: 3500)
            .frame(height: 200)
            .padding()
        
        ExpenseTrendChart(expenses: [])
            .frame(height: 200)
            .padding()
    }
}
