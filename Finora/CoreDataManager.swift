//
//  CoreDataManager.swift
//  Finora
//
//  Created by Aryan Varmora on 2025
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        // Create entity description programmatically
        let modelURL = Bundle.main.url(forResource: "Finora", withExtension: "momd")
        let model: NSManagedObjectModel
        
        if let url = modelURL, let managedObjectModel = NSManagedObjectModel(contentsOf: url) {
            model = managedObjectModel
        } else {
            // Create model programmatically if file doesn't exist
            model = createManagedObjectModel()
        }
        
        let container = NSPersistentContainer(name: "Finora", managedObjectModel: model)
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    // Create Core Data model programmatically
    private func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create ExpenseEntity
        let expenseEntity = NSEntityDescription()
        expenseEntity.name = "ExpenseEntity"
        expenseEntity.managedObjectClassName = "ExpenseEntity"
        
        // Add attributes
        var properties: [NSAttributeDescription] = []
        
        // ID
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        properties.append(idAttribute)
        
        // Title
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        properties.append(titleAttribute)
        
        // Amount
        let amountAttribute = NSAttributeDescription()
        amountAttribute.name = "amount"
        amountAttribute.attributeType = .doubleAttributeType
        amountAttribute.isOptional = false
        amountAttribute.defaultValue = 0.0
        properties.append(amountAttribute)
        
        // Category
        let categoryAttribute = NSAttributeDescription()
        categoryAttribute.name = "category"
        categoryAttribute.attributeType = .stringAttributeType
        categoryAttribute.isOptional = false
        properties.append(categoryAttribute)
        
        // Currency
        let currencyAttribute = NSAttributeDescription()
        currencyAttribute.name = "currency"
        currencyAttribute.attributeType = .stringAttributeType
        currencyAttribute.isOptional = false
        currencyAttribute.defaultValue = "USD"
        properties.append(currencyAttribute)
        
        // Notes
        let notesAttribute = NSAttributeDescription()
        notesAttribute.name = "notes"
        notesAttribute.attributeType = .stringAttributeType
        notesAttribute.isOptional = true
        properties.append(notesAttribute)
        
        // Date
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false
        properties.append(dateAttribute)
        
        // User ID (for multi-user support)
        let userIdAttribute = NSAttributeDescription()
        userIdAttribute.name = "userId"
        userIdAttribute.attributeType = .stringAttributeType
        userIdAttribute.isOptional = true  // Optional for backwards compatibility
        properties.append(userIdAttribute)
        
        // Created At
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false
        properties.append(createdAtAttribute)
        
        // Converted Amount
        let convertedAmountAttribute = NSAttributeDescription()
        convertedAmountAttribute.name = "convertedAmount"
        convertedAmountAttribute.attributeType = .doubleAttributeType
        convertedAmountAttribute.isOptional = false
        convertedAmountAttribute.defaultValue = 0.0
        properties.append(convertedAmountAttribute)
        
        expenseEntity.properties = properties
        
        // Create IncomeEntity
        let incomeEntity = NSEntityDescription()
        incomeEntity.name = "IncomeEntity"
        incomeEntity.managedObjectClassName = "IncomeEntity"
        
        var incomeProperties: [NSAttributeDescription] = []
        
        // ID
        let incomeIdAttribute = NSAttributeDescription()
        incomeIdAttribute.name = "id"
        incomeIdAttribute.attributeType = .UUIDAttributeType
        incomeIdAttribute.isOptional = false
        incomeProperties.append(incomeIdAttribute)
        
        // User ID
        let incomeUserIdAttribute = NSAttributeDescription()
        incomeUserIdAttribute.name = "userId"
        incomeUserIdAttribute.attributeType = .stringAttributeType
        incomeUserIdAttribute.isOptional = false
        incomeProperties.append(incomeUserIdAttribute)
        
        // Amount
        let incomeAmountAttribute = NSAttributeDescription()
        incomeAmountAttribute.name = "amount"
        incomeAmountAttribute.attributeType = .doubleAttributeType
        incomeAmountAttribute.isOptional = false
        incomeAmountAttribute.defaultValue = 0.0
        incomeProperties.append(incomeAmountAttribute)
        
        // Created At
        let incomeCreatedAtAttribute = NSAttributeDescription()
        incomeCreatedAtAttribute.name = "createdAt"
        incomeCreatedAtAttribute.attributeType = .dateAttributeType
        incomeCreatedAtAttribute.isOptional = false
        incomeProperties.append(incomeCreatedAtAttribute)
        
        // Updated At
        let incomeUpdatedAtAttribute = NSAttributeDescription()
        incomeUpdatedAtAttribute.name = "updatedAt"
        incomeUpdatedAtAttribute.attributeType = .dateAttributeType
        incomeUpdatedAtAttribute.isOptional = false
        incomeProperties.append(incomeUpdatedAtAttribute)
        
        incomeEntity.properties = incomeProperties
        
        // Create BudgetEntity
        let budgetEntity = NSEntityDescription()
        budgetEntity.name = "BudgetEntity"
        budgetEntity.managedObjectClassName = "BudgetEntity"
        
        var budgetProperties: [NSAttributeDescription] = []
        
        // ID
        let budgetIdAttribute = NSAttributeDescription()
        budgetIdAttribute.name = "id"
        budgetIdAttribute.attributeType = .UUIDAttributeType
        budgetIdAttribute.isOptional = false
        budgetProperties.append(budgetIdAttribute)
        
        // User ID
        let budgetUserIdAttribute = NSAttributeDescription()
        budgetUserIdAttribute.name = "userId"
        budgetUserIdAttribute.attributeType = .stringAttributeType
        budgetUserIdAttribute.isOptional = false
        budgetProperties.append(budgetUserIdAttribute)
        
        // Category
        let budgetCategoryAttribute = NSAttributeDescription()
        budgetCategoryAttribute.name = "category"
        budgetCategoryAttribute.attributeType = .stringAttributeType
        budgetCategoryAttribute.isOptional = false
        budgetProperties.append(budgetCategoryAttribute)
        
        // Monthly Limit
        let budgetMonthlyLimitAttribute = NSAttributeDescription()
        budgetMonthlyLimitAttribute.name = "monthlyLimit"
        budgetMonthlyLimitAttribute.attributeType = .doubleAttributeType
        budgetMonthlyLimitAttribute.isOptional = false
        budgetMonthlyLimitAttribute.defaultValue = 0.0
        budgetProperties.append(budgetMonthlyLimitAttribute)
        
        // Created At
        let budgetCreatedAtAttribute = NSAttributeDescription()
        budgetCreatedAtAttribute.name = "createdAt"
        budgetCreatedAtAttribute.attributeType = .dateAttributeType
        budgetCreatedAtAttribute.isOptional = false
        budgetProperties.append(budgetCreatedAtAttribute)
        
        // Updated At
        let budgetUpdatedAtAttribute = NSAttributeDescription()
        budgetUpdatedAtAttribute.name = "updatedAt"
        budgetUpdatedAtAttribute.attributeType = .dateAttributeType
        budgetUpdatedAtAttribute.isOptional = false
        budgetProperties.append(budgetUpdatedAtAttribute)
        
        budgetEntity.properties = budgetProperties
        
        model.entities = [expenseEntity, incomeEntity, budgetEntity]
        
        return model
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    // CREATE
    func createExpense(
        title: String,
        amount: Double,
        category: String,
        currency: String,
        notes: String,
        date: Date,
        convertedAmount: Double? = nil
    ) -> ExpenseEntity {
        let expense = ExpenseEntity(context: context)
        expense.id = UUID()
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.currency = currency
        expense.notes = notes
        expense.date = date
        expense.createdAt = Date()
        expense.convertedAmount = convertedAmount ?? amount
        
        saveContext()
        return expense
    }
    
    // READ ALL
    func fetchAllExpenses() -> [ExpenseEntity] {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
    
    // READ WITH FILTER
    func fetchExpenses(category: String? = nil, searchText: String? = nil) -> [ExpenseEntity] {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if let category = category, !category.isEmpty, category != "All Categories" {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", searchText, searchText))
        }
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching filtered expenses: \(error)")
            return []
        }
    }
    
    // READ BY DATE RANGE
    func fetchExpenses(from startDate: Date, to endDate: Date) -> [ExpenseEntity] {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching expenses by date: \(error)")
            return []
        }
    }
    
    // UPDATE
    func updateExpense(
        expense: ExpenseEntity,
        title: String? = nil,
        amount: Double? = nil,
        category: String? = nil,
        currency: String? = nil,
        notes: String? = nil,
        date: Date? = nil,
        convertedAmount: Double? = nil
    ) {
        if let title = title { expense.title = title }
        if let amount = amount { expense.amount = amount }
        if let category = category { expense.category = category }
        if let currency = currency { expense.currency = currency }
        if let notes = notes { expense.notes = notes }
        if let date = date { expense.date = date }
        if let convertedAmount = convertedAmount { expense.convertedAmount = convertedAmount }
        
        saveContext()
    }
    
    // DELETE
    func deleteExpense(_ expense: ExpenseEntity) {
        context.delete(expense)
        saveContext()
    }
    
    // DELETE ALL (for testing)
    func deleteAllExpenses() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExpenseEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Error deleting all expenses: \(error)")
        }
    }
    
    // MARK: - Statistics
    func getTotalExpenses() -> Double {
        let expenses = fetchAllExpenses()
        return expenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    func getTotalExpenses(forCategory category: String) -> Double {
        let expenses = fetchExpenses(category: category)
        return expenses.reduce(0) { $0 + $1.convertedAmount }
    }
    
    func getExpensesByCategory() -> [String: Double] {
        let expenses = fetchAllExpenses()
        var categoryTotals: [String: Double] = [:]
        
        for expense in expenses {
            let category = expense.category ?? "Other"
            categoryTotals[category, default: 0] += expense.convertedAmount
        }
        
        return categoryTotals
    }
    
    func getRecentExpenses(limit: Int = 10) -> [ExpenseEntity] {
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = limit
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching recent expenses: \(error)")
            return []
        }
    }
}
