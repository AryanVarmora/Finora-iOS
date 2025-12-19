//
//  BudgetManagerTests.swift
//  Finora
//
//  Created by Aryan Varmora on 12/8/25.
//


//
//  BudgetManagerTests.swift
//  FinoraTests
//
//  Unit tests for BudgetManager
//

import XCTest
import CoreData
@testable import Finora

final class BudgetManagerTests: XCTestCase {
    
    var budgetManager: BudgetManager!
    var expenseViewModel: ExpenseViewModel!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory Core Data stack
        let container = NSPersistentContainer(name: "FinoraModel", managedObjectModel: CoreDataManager.shared.createModel())
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (description, error) in
            XCTAssertNil(error, "Core Data stack should load")
        }
        
        testContext = container.viewContext
        budgetManager = BudgetManager.shared
        expenseViewModel = ExpenseViewModel()
        
        // Set test user
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "test-user",
            email: "test@example.com",
            password: "password",
            firstName: "Test",
            lastName: "User"
        )
        
        // Clear any existing budgets
        budgetManager.loadBudgets()
        for budget in budgetManager.budgets {
            budgetManager.deleteBudget(for: budget.category)
        }
    }
    
    override func tearDown() {
        // Clean up
        budgetManager.deleteAllBudgets()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExpenseEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? testContext.execute(deleteRequest)
        
        budgetManager = nil
        expenseViewModel = nil
        testContext = nil
        AuthenticationManager.shared.currentUser = nil
        super.tearDown()
    }
    
    // MARK: - Set Budget Tests
    
    func testSetBudget_Success() {
        // Given
        let category = "Food"
        let limit = 300.0
        
        // When
        budgetManager.setBudget(category: category, limit: limit)
        
        // Then
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 1, "Should have 1 budget")
        
        if let budget = budgetManager.getBudget(for: category) {
            XCTAssertEqual(budget.category, category, "Category should match")
            XCTAssertEqual(budget.monthlyLimit, limit, "Limit should match")
        } else {
            XCTFail("Budget should exist")
        }
    }
    
    func testSetBudget_Update() {
        // Given - Set initial budget
        let category = "Food"
        budgetManager.setBudget(category: category, limit: 300.0)
        
        // When - Update budget
        budgetManager.setBudget(category: category, limit: 500.0)
        
        // Then
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 1, "Should still have 1 budget")
        XCTAssertEqual(budgetManager.getLimit(for: category), 500.0, "Limit should be updated")
    }
    
    func testSetBudget_MultipleCategories() {
        // When - Set budgets for multiple categories
        budgetManager.setBudget(category: "Food", limit: 300.0)
        budgetManager.setBudget(category: "Travel", limit: 500.0)
        budgetManager.setBudget(category: "Shopping", limit: 200.0)
        
        // Then
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 3, "Should have 3 budgets")
        XCTAssertEqual(budgetManager.getLimit(for: "Food"), 300.0)
        XCTAssertEqual(budgetManager.getLimit(for: "Travel"), 500.0)
        XCTAssertEqual(budgetManager.getLimit(for: "Shopping"), 200.0)
    }
    
    // MARK: - Get Budget Tests
    
    func testGetBudget_Exists() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // When
        let budget = budgetManager.getBudget(for: "Food")
        
        // Then
        XCTAssertNotNil(budget, "Budget should exist")
        XCTAssertEqual(budget?.category, "Food")
    }
    
    func testGetBudget_NotExists() {
        // When
        let budget = budgetManager.getBudget(for: "NonExistent")
        
        // Then
        XCTAssertNil(budget, "Budget should not exist")
    }
    
    func testGetLimit() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // When
        let limit = budgetManager.getLimit(for: "Food")
        
        // Then
        XCTAssertEqual(limit, 300.0, "Limit should match")
    }
    
    func testGetLimit_NotExists() {
        // When
        let limit = budgetManager.getLimit(for: "NonExistent")
        
        // Then
        XCTAssertEqual(limit, 0.0, "Should return 0 for non-existent budget")
    }
    
    func testHasBudget() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // Then
        XCTAssertTrue(budgetManager.hasBudget(for: "Food"), "Should have budget for Food")
        XCTAssertFalse(budgetManager.hasBudget(for: "Travel"), "Should not have budget for Travel")
    }
    
    // MARK: - Spending Tests
    
    func testGetSpending_NoExpenses() {
        // Given - Budget set but no expenses
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // When
        let spending = budgetManager.getSpending(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(spending, 0.0, "Spending should be 0 with no expenses")
    }
    
    func testGetSpending_WithExpenses() {
        // Given - Budget and expenses
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Groceries",
            amount: 50.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        expenseViewModel.addExpense(
            title: "Restaurant",
            amount: 30.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expenses added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let spending = budgetManager.getSpending(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(spending, 80.0, "Spending should be 80.0")
    }
    
    func testGetSpending_OnlyCurrentMonth() {
        // Given - Budget and expenses from different months
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // Current month expense
        expenseViewModel.addExpense(
            title: "This Month",
            amount: 50.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        // Last month expense (should not count)
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        expenseViewModel.addExpense(
            title: "Last Month",
            amount: 100.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: lastMonth
        )
        
        let expectation = XCTestExpectation(description: "Expenses added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let spending = budgetManager.getSpending(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(spending, 50.0, "Should only count current month")
    }
    
    // MARK: - Progress Tests
    
    func testGetProgress_Zero() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        // When
        let progress = budgetManager.getProgress(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(progress, 0.0, "Progress should be 0 with no expenses")
    }
    
    func testGetProgress_Fifty() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 150.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let progress = budgetManager.getProgress(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(progress, 0.5, accuracy: 0.01, "Progress should be 50%")
    }
    
    func testGetProgress_CappedAt100() {
        // Given - Spending exceeds budget
        budgetManager.setBudget(category: "Food", limit: 100.0)
        
        expenseViewModel.addExpense(
            title: "Expensive",
            amount: 200.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let progress = budgetManager.getProgress(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(progress, 1.0, "Progress should cap at 1.0 (100%)")
    }
    
    func testGetProgressPercentage() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 90.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let percentage = budgetManager.getProgressPercentage(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(percentage, 30, "Percentage should be 30%")
    }
    
    // MARK: - Budget Status Tests
    
    func testIsOverBudget_False() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 250.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let isOver = budgetManager.isOverBudget(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertFalse(isOver, "Should not be over budget")
    }
    
    func testIsOverBudget_True() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expensive",
            amount: 350.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let isOver = budgetManager.isOverBudget(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertTrue(isOver, "Should be over budget")
    }
    
    func testIsNearBudget_False() {
        // Given - 50% spent
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 150.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let isNear = budgetManager.isNearBudget(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertFalse(isNear, "Should not be near budget at 50%")
    }
    
    func testIsNearBudget_True() {
        // Given - 85% spent
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 255.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let isNear = budgetManager.isNearBudget(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertTrue(isNear, "Should be near budget at 85%")
    }
    
    func testGetRemaining() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 100.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let remaining = budgetManager.getRemaining(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(remaining, 200.0, "Remaining should be 200")
    }
    
    func testGetRemaining_OverBudget() {
        // Given - Over budget
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expensive",
            amount: 400.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let remaining = budgetManager.getRemaining(for: "Food", viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(remaining, 0.0, "Remaining should be 0 when over budget")
    }
    
    // MARK: - Delete Budget Tests
    
    func testDeleteBudget_Success() {
        // Given
        budgetManager.setBudget(category: "Food", limit: 300.0)
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 1)
        
        // When
        budgetManager.deleteBudget(for: "Food")
        
        // Then
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 0, "Budget should be deleted")
        XCTAssertFalse(budgetManager.hasBudget(for: "Food"), "Should not have budget")
    }
    
    func testDeleteBudget_NonExistent() {
        // When - Delete non-existent budget
        budgetManager.deleteBudget(for: "NonExistent")
        
        // Then - Should not crash
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 0)
    }
    
    func testDeleteAllBudgets() {
        // Given - Multiple budgets
        budgetManager.setBudget(category: "Food", limit: 300.0)
        budgetManager.setBudget(category: "Travel", limit: 500.0)
        budgetManager.setBudget(category: "Shopping", limit: 200.0)
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 3)
        
        // When
        budgetManager.deleteAllBudgets()
        
        // Then
        budgetManager.loadBudgets()
        XCTAssertEqual(budgetManager.budgets.count, 0, "All budgets should be deleted")
    }
    
    // MARK: - Alert Tests
    
    func testGetAlerts_None() {
        // Given - Budget with low spending
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 50.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let alerts = budgetManager.getAlerts(viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(alerts.count, 0, "Should have no alerts at 17%")
    }
    
    func testGetAlerts_NearLimit() {
        // Given - 85% spent
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expense",
            amount: 255.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let alerts = budgetManager.getAlerts(viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(alerts.count, 1, "Should have 1 alert")
        if let alert = alerts.first {
            XCTAssertEqual(alert.type, .nearLimit, "Should be near limit alert")
            XCTAssertEqual(alert.category, "Food")
        }
    }
    
    func testGetAlerts_Exceeded() {
        // Given - Over budget
        budgetManager.setBudget(category: "Food", limit: 300.0)
        
        expenseViewModel.addExpense(
            title: "Expensive",
            amount: 350.0,
            category: "Food",
            currency: "USD",
            notes: "",
            date: Date()
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        expenseViewModel.fetchExpenses()
        let alerts = budgetManager.getAlerts(viewModel: expenseViewModel)
        
        // Then
        XCTAssertEqual(alerts.count, 1, "Should have 1 alert")
        if let alert = alerts.first {
            XCTAssertEqual(alert.type, .exceeded, "Should be exceeded alert")
            XCTAssertEqual(alert.category, "Food")
        }
    }
    
    // MARK: - User Isolation Tests
    
    func testUserIsolation() {
        // Given - User 1 sets budget
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user1",
            email: "user1@example.com",
            password: "password",
            firstName: "User",
            lastName: "One"
        )
        
        budgetManager.setBudget(category: "Food", limit: 300.0)
        budgetManager.loadBudgets()
        let user1Count = budgetManager.budgets.count
        
        // When - Switch to User 2
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user2",
            email: "user2@example.com",
            password: "password",
            firstName: "User",
            lastName: "Two"
        )
        
        budgetManager.loadBudgets()
        let user2Count = budgetManager.budgets.count
        
        // Then
        XCTAssertEqual(user1Count, 1, "User 1 should have 1 budget")
        XCTAssertEqual(user2Count, 0, "User 2 should have 0 budgets")
    }
}