//
//  BudgetManager.swift
//  Finora
//
//  Created by Aryan Varmora on 12/18/25.
//


//
//  BudgetManager.swift
//  Finora
//
//  Manages budget limits per category
//

import Foundation
import CoreData
import Combine

class BudgetManager: ObservableObject {
    static let shared = BudgetManager()
    
    @Published var budgets: [BudgetEntity] = []
    
    private var viewContext: NSManagedObjectContext {
        CoreDataManager.shared.context
    }
    
    private var currentUserId: String {
        AuthenticationManager.shared.currentUser?.id ?? ""
    }
    
    private init() {
        loadBudgets()
    }
    
    // MARK: - Load Budgets
    
    func loadBudgets() {
        guard !currentUserId.isEmpty else {
            print("❌ No user logged in")
            budgets = []
            return
        }
        
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BudgetEntity.category, ascending: true)]
        
        do {
            budgets = try viewContext.fetch(request)
            print("✅ Loaded \(budgets.count) budgets for user: \(currentUserId)")
        } catch {
            print("❌ Error loading budgets: \(error)")
            budgets = []
        }
    }
    
    // MARK: - Set Budget
    
    func setBudget(category: String, limit: Double) {
        guard !currentUserId.isEmpty else {
            print("❌ No user logged in")
            return
        }
        
        // Check if budget already exists for this category
        if let existing = getBudget(for: category) {
            // Update existing
            existing.limit = limit
            existing.timestamp = Date()
            print("✅ Updated budget for \(category): $\(limit)")
        } else {
            // Create new
            let budget = BudgetEntity(context: viewContext)
            budget.id = UUID()
            budget.userId = currentUserId
            budget.category = category
            budget.limit = limit
            budget.period = "monthly"
            budget.startDate = Date()
            budget.isActive = true
            budget.notificationsEnabled = true
            budget.timestamp = Date()
            print("✅ Created budget for \(category): $\(limit)")
        }
        
        CoreDataManager.shared.saveContext()
        loadBudgets()
    }
    
    // MARK: - Get Budget
    
    func getBudget(for category: String) -> BudgetEntity? {
        return budgets.first { $0.category ?? "" == category }
    }
    
    // MARK: - Get Budget Limit
    
    func getLimit(for category: String) -> Double {
        return getBudget(for: category)?.limit ?? 0
    }
    
    // MARK: - Check if Budget Exists
    
    func hasBudget(for category: String) -> Bool {
        return getBudget(for: category) != nil
    }
    
    // MARK: - Get Spending for Category
    
    func getSpending(for category: String, viewModel: ExpenseViewModel) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let monthExpenses = viewModel.expenses.filter {
            ($0.category ?? "") == category &&
            calendar.isDate($0.date ?? Date(), equalTo: now, toGranularity: .month)
        }
        
        return monthExpenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    // MARK: - Get Spent Amount (alias for compatibility)
    
    func getSpentAmount(for category: String) -> Double {
        let viewModel = ExpenseViewModel()
        return getSpending(for: category, viewModel: viewModel)
    }
    
    // MARK: - Get Progress
    
    func getProgress(for category: String, viewModel: ExpenseViewModel) -> Double {
        let limit = getLimit(for: category)
        guard limit > 0 else { return 0 }
        
        let spent = getSpending(for: category, viewModel: viewModel)
        return min(spent / limit, 1.0) // Cap at 100%
    }
    
    // MARK: - Get Progress Percentage
    
    func getProgressPercentage(for category: String, viewModel: ExpenseViewModel) -> Int {
        return Int(getProgress(for: category, viewModel: viewModel) * 100)
    }
    
    // MARK: - Get Budget Percentage (alias for compatibility)
    
    func getBudgetPercentage(for category: String) -> Double {
        let viewModel = ExpenseViewModel()
        return getProgress(for: category, viewModel: viewModel)
    }
    
    // MARK: - Check if Over Budget
    
    func isOverBudget(for category: String, viewModel: ExpenseViewModel) -> Bool {
        let limit = getLimit(for: category)
        guard limit > 0 else { return false }
        
        let spent = getSpending(for: category, viewModel: viewModel)
        return spent > limit
    }
    
    // MARK: - Check if Near Budget (>= 80%)
    
    func isNearBudget(for category: String, viewModel: ExpenseViewModel) -> Bool {
        return getProgress(for: category, viewModel: viewModel) >= 0.8
    }
    
    // MARK: - Get Remaining Budget
    
    func getRemaining(for category: String, viewModel: ExpenseViewModel) -> Double {
        let limit = getLimit(for: category)
        let spent = getSpending(for: category, viewModel: viewModel)
        return max(limit - spent, 0)
    }
    
    // MARK: - Delete Budget
    
    func deleteBudget(for category: String) {
        guard let budget = getBudget(for: category) else {
            print("⚠️ No budget found for \(category)")
            return
        }
        
        viewContext.delete(budget)
        CoreDataManager.shared.saveContext()
        loadBudgets()
        print("✅ Deleted budget for \(category)")
    }
    
    // MARK: - Delete All Budgets
    
    func deleteAllBudgets() {
        guard !currentUserId.isEmpty else {
            print("❌ No user logged in")
            return
        }
        
        for budget in budgets {
            viewContext.delete(budget)
        }
        
        CoreDataManager.shared.saveContext()
        loadBudgets()
        print("✅ Deleted all budgets for user")
    }
    
    // MARK: - Get All Categories with Budgets
    
    func getCategoriesWithBudgets() -> [String] {
        return budgets.compactMap { $0.category }
    }
    
    // MARK: - Get Budget Summary
    
    func getBudgetSummary(viewModel: ExpenseViewModel) -> [(category: String, limit: Double, spent: Double, percentage: Int, isOver: Bool)] {
        return budgets.compactMap { budget in
            guard let category = budget.category else { return nil }
            
            let spent = getSpending(for: category, viewModel: viewModel)
            let percentage = getProgressPercentage(for: category, viewModel: viewModel)
            let isOver = isOverBudget(for: category, viewModel: viewModel)
            
            return (
                category: category,
                limit: budget.limit,
                spent: spent,
                percentage: percentage,
                isOver: isOver
            )
        }
        .sorted { $0.percentage > $1.percentage } // Sort by highest % first
    }
    
    // MARK: - Get Alerts
    
    func getAlerts(viewModel: ExpenseViewModel) -> [BudgetAlert] {
        var alerts: [BudgetAlert] = []
        
        for budget in budgets {
            guard let category = budget.category else { continue }
            
            let spent = getSpending(for: category, viewModel: viewModel)
            let limit = budget.limit
            let percentage = getProgressPercentage(for: category, viewModel: viewModel)
            
            if spent > limit {
                alerts.append(BudgetAlert(
                    category: category,
                    type: .exceeded,
                    spent: spent,
                    limit: limit,
                    percentage: percentage
                ))
            } else if percentage >= 80 {
                alerts.append(BudgetAlert(
                    category: category,
                    type: .nearLimit,
                    spent: spent,
                    limit: limit,
                    percentage: percentage
                ))
            }
        }
        
        return alerts.sorted { $0.percentage > $1.percentage }
    }
}

// MARK: - Budget Alert Model

struct BudgetAlert: Identifiable {
    let id = UUID()
    let category: String
    let type: AlertType
    let spent: Double
    let limit: Double
    let percentage: Int
    
    enum AlertType {
        case nearLimit // >= 80%
        case exceeded  // > 100%
    }
    
    var title: String {
        switch type {
        case .nearLimit:
            return "\(category) budget: \(percentage)% used"
        case .exceeded:
            return "\(category) budget exceeded!"
        }
    }
    
    var message: String {
        switch type {
        case .nearLimit:
            let remaining = limit - spent
            return "$\(String(format: "%.2f", spent)) of $\(String(format: "%.2f", limit)) spent. $\(String(format: "%.2f", remaining)) remaining."
        case .exceeded:
            let over = spent - limit
            return "$\(String(format: "%.2f", spent)) spent. Over by $\(String(format: "%.2f", over))!"
        }
    }
    
    var icon: String {
        switch type {
        case .nearLimit:
            return "exclamationmark.triangle.fill"
        case .exceeded:
            return "exclamationmark.circle.fill"
        }
    }
    
    var color: String {
        switch type {
        case .nearLimit:
            return "F59E0B" // Orange
        case .exceeded:
            return "EF4444" // Red
        }
    }
}