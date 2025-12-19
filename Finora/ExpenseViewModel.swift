//
//  ExpenseViewModel.swift
//  Finora
//
//  Expense management with backend sync
//

import Foundation
import CoreData
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchExpenses()
    }
    
    // MARK: - Fetch Expenses (Local)
    
    func fetchExpenses() {
        guard let userId = AuthenticationManager.shared.currentUser?.id else {
            print("❌ No user logged in")
            return
        }
        
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            expenses = try coreDataManager.context.fetch(request)
            print("✅ Fetched \(expenses.count) local expenses")
        } catch {
            print("❌ Error fetching expenses: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Add Expense (Local + Backend)
    
    func addExpense(title: String, amount: Double, category: String, date: Date, currency: String) {
        guard let userId = AuthenticationManager.shared.currentUser?.id else {
            print("❌ No user logged in")
            return
        }
        
        // Create expense in Core Data
        let expense = ExpenseEntity(context: coreDataManager.context)
        expense.id = UUID()
        expense.userId = userId
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.currency = currency
        expense.convertedAmount = amount
        expense.timestamp = Date()
        
        // Save to Core Data
        do {
            try coreDataManager.context.save()
            print("✅ Expense saved to Core Data")
            fetchExpenses()
            
            // Sync to backend
            syncExpenseToBackend(expense)
            
        } catch {
            print("❌ Error saving expense: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete Expense (Local + Backend)
    
    func deleteExpense(_ expense: ExpenseEntity) {
        // Delete from backend first (if it has a server ID)
        if let serverId = expense.serverId {
            deleteExpenseFromBackend(serverId)
        }
        
        // Delete from Core Data
        coreDataManager.context.delete(expense)
        
        do {
            try coreDataManager.context.save()
            print("✅ Expense deleted from Core Data")
            fetchExpenses()
        } catch {
            print("❌ Error deleting expense: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Backend Sync
    
    // MARK: - Backend Sync (Public for AddExpenseView)
    
    func syncExpenseToBackend(_ expense: ExpenseEntity) {
        guard let token = KeychainManager.shared.getToken(for: expense.userId ?? "") else {
            print("⚠️ No token found, skipping backend sync")
            return
        }
        
        print("📤 Syncing expense to backend...")
        
        let expenseData = APIExpenseData(
            title: expense.title ?? "",
            amount: expense.amount,
            category: expense.category ?? "",
            currency: expense.currency ?? "USD",
            date: expense.date ?? Date(),
            convertedAmount: expense.convertedAmount
        )
        
        APIManager.shared.createExpense(token: token, expense: expenseData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Expense synced to backend!")
                    print("   Server ID: \(response.expense._id)")
                    
                    // Save server ID to Core Data
                    expense.serverId = response.expense._id
                    try? self.coreDataManager.context.save()
                    
                case .failure(let error):
                    print("❌ Failed to sync expense: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteExpenseFromBackend(_ serverId: String) {
        guard let userId = AuthenticationManager.shared.currentUser?.id,
              let token = KeychainManager.shared.getToken(for: userId) else {
            print("⚠️ No token found, skipping backend delete")
            return
        }
        
        print("📤 Deleting expense from backend...")
        
        APIManager.shared.deleteExpense(token: token, expenseId: serverId) { result in
            switch result {
            case .success:
                print("✅ Expense deleted from backend!")
            case .failure(let error):
                print("❌ Failed to delete from backend: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Fetch from Backend
    
    func syncFromBackend() {
        guard let userId = AuthenticationManager.shared.currentUser?.id,
              let token = KeychainManager.shared.getToken(for: userId) else {
            print("⚠️ No token found, cannot sync from backend")
            return
        }
        
        isLoading = true
        print("📥 Fetching expenses from backend...")
        
        APIManager.shared.getExpenses(token: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    print("✅ Received \(response.count) expenses from backend")
                    self?.mergeBackendExpenses(response.expenses)
                    
                case .failure(let error):
                    print("❌ Failed to fetch from backend: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func mergeBackendExpenses(_ serverExpenses: [ServerExpense]) {
        guard let userId = AuthenticationManager.shared.currentUser?.id else { return }
        
        for serverExpense in serverExpenses {
            // Check if expense already exists locally
            let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
            request.predicate = NSPredicate(format: "serverId == %@", serverExpense._id)
            
            if let existingExpense = try? coreDataManager.context.fetch(request).first {
                // Update existing
                existingExpense.title = serverExpense.title
                existingExpense.amount = serverExpense.amount
                existingExpense.category = serverExpense.category
                existingExpense.currency = serverExpense.currency
                existingExpense.date = serverExpense.date
                existingExpense.convertedAmount = serverExpense.convertedAmount
            } else {
                // Create new local expense
                let newExpense = ExpenseEntity(context: coreDataManager.context)
                newExpense.id = UUID()
                newExpense.serverId = serverExpense._id
                newExpense.userId = userId
                newExpense.title = serverExpense.title
                newExpense.amount = serverExpense.amount
                newExpense.category = serverExpense.category
                newExpense.currency = serverExpense.currency
                newExpense.date = serverExpense.date
                newExpense.convertedAmount = serverExpense.convertedAmount
                newExpense.timestamp = Date()
            }
        }
        
        // Save changes
        do {
            try coreDataManager.context.save()
            fetchExpenses()
            print("✅ Merged backend expenses with local data")
        } catch {
            print("❌ Error merging expenses: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    func totalExpenses() -> Double {
        expenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    func expensesByCategory() -> [String: Double] {
        var categoryTotals: [String: Double] = [:]
        
        for expense in expenses {
            let category = expense.category ?? "Other"
            categoryTotals[category, default: 0] += expense.convertedAmount
        }
        
        return categoryTotals
    }
    
    func expensesForMonth(_ date: Date) -> [ExpenseEntity] {
        let calendar = Calendar.current
        return expenses.filter { expense in
            guard let expenseDate = expense.date else { return false }
            return calendar.isDate(expenseDate, equalTo: date, toGranularity: .month)
        }
    }
    
    // MARK: - Additional Helper Methods
    
    func getMonthlyTotal() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let thisMonthExpenses = expenses.filter { expense in
            guard let expenseDate = expense.date else { return false }
            return calendar.isDate(expenseDate, equalTo: now, toGranularity: .month)
        }
        return thisMonthExpenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    func getExpensesByCategory() -> [String: Double] {
        return expensesByCategory()
    }
    
    func getRecentExpenses(limit: Int = 5) -> [ExpenseEntity] {
        return Array(expenses.prefix(limit))
    }
}
