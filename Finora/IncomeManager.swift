//
//  IncomeManager.swift
//  Finora - User Income Management
//

import Foundation
import CoreData
import Combine

class IncomeManager: ObservableObject {
    @Published var monthlyIncome: Double = 0.0
    
    static let shared = IncomeManager()
    
    private var viewContext: NSManagedObjectContext {
        CoreDataManager.shared.context
    }
    
    private var currentUserId: String {
        AuthenticationManager.shared.currentUser?.id ?? ""
    }
    
    private init() {
        loadIncome()
    }
    
    // MARK: - Load Income
    
    func loadIncome() {
        guard !currentUserId.isEmpty else {
            monthlyIncome = 0.0
            return
        }
        
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        request.fetchLimit = 1
        
        do {
            if let incomeEntity = try viewContext.fetch(request).first {
                monthlyIncome = incomeEntity.amount
                print("✅ Loaded income for \(currentUserId): $\(monthlyIncome)")
            } else {
                monthlyIncome = 0.0
                print("ℹ️ No income set for \(currentUserId), defaulting to $0")
            }
        } catch {
            print("❌ Error loading income: \(error)")
            monthlyIncome = 0.0
        }
    }
    
    // MARK: - Save Income
    
    func saveIncome(_ amount: Double) {
        guard !currentUserId.isEmpty else {
            print("❌ No user logged in")
            return
        }
        
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        do {
            let existingIncome = try viewContext.fetch(request).first
            
            if let existing = existingIncome {
                // Update existing income
                existing.amount = amount
                existing.timestamp = Date()
                print("✅ Updated income for \(currentUserId): $\(amount)")
            } else {
                // Create new income record
                let newIncome = IncomeEntity(context: viewContext)
                newIncome.id = UUID()
                newIncome.userId = currentUserId
                newIncome.amount = amount
                newIncome.source = "Monthly Income"
                newIncome.date = Date()
                newIncome.timestamp = Date()
                newIncome.isRecurring = true
                newIncome.frequency = "monthly"
                newIncome.category = "Salary"
                print("✅ Created new income for \(currentUserId): $\(amount)")
            }
            
            CoreDataManager.shared.saveContext()
            monthlyIncome = amount
            
        } catch {
            print("❌ Error saving income: \(error)")
        }
    }
    
    // MARK: - Delete Income
    
    func deleteIncome() {
        guard !currentUserId.isEmpty else { return }
        
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        do {
            let incomes = try viewContext.fetch(request)
            for income in incomes {
                viewContext.delete(income)
            }
            CoreDataManager.shared.saveContext()
            monthlyIncome = 0.0
            print("✅ Deleted income for \(currentUserId)")
        } catch {
            print("❌ Error deleting income: \(error)")
        }
    }
    
    // MARK: - Get Income History (for future analytics)
    
    func getIncomeHistory() -> [IncomeEntity] {
        guard !currentUserId.isEmpty else { return [] }
        
        let request: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", currentUserId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IncomeEntity.timestamp, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("❌ Error fetching income history: \(error)")
            return []
        }
    }
}

// MARK: - IncomeEntity Extension (Computed Properties)

extension IncomeEntity {
    var wrappedUserId: String {
        userId ?? ""
    }
    
    var wrappedSource: String {
        source ?? "Income"
    }
    
    var wrappedDate: Date {
        date ?? Date()
    }
    
    var wrappedCategory: String {
        category ?? "Other"
    }
    
    var wrappedFrequency: String {
        frequency ?? "monthly"
    }
}
