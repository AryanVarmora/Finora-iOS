//
//  ExpenseViewModelTests.swift
//  Finora
//
//  Created by Aryan Varmora on 12/8/25.
//


//
//  ExpenseViewModelTests.swift
//  FinoraTests
//
//  Unit tests for ExpenseViewModel
//

import XCTest
import CoreData
@testable import Finora

final class ExpenseViewModelTests: XCTestCase {
    
    var viewModel: ExpenseViewModel!
    
    override func setUp() {
        super.setUp()
        
        viewModel = ExpenseViewModel()
        
        // Set test user
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "test-user",
            email: "test@example.com",
            password: "password",
            firstName: "Test",
            lastName: "User"
        )
    }
    
    override func tearDown() {
        // Clean up all test expenses
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", "test@example.com")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try CoreDataManager.shared.context.execute(deleteRequest)
            try CoreDataManager.shared.context.save()
        } catch {
            print("Error cleaning up: \(error)")
        }
        
        viewModel = nil
        AuthenticationManager.shared.currentUser = nil
        super.tearDown()
    }
    
    // MARK: - Add Expense Tests
    
    func testAddExpense_Success() {
        // Given
        let initialCount = viewModel.expenses.count
        let title = "Test Expense"
        let amount = 100.0
        let category = "Food"
        let currency = "USD"
        
        // When
        viewModel.addExpense(
            title: title,
            amount: amount,
            category: category,
            date: Date(),
            currency: currency
        )
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        viewModel.fetchExpenses()
        XCTAssertGreaterThan(viewModel.expenses.count, initialCount, "Should have added expense")
    }
    
    func testAddExpense_WithConversion() {
        // Given
        let title = "CAD Expense"
        let amount = 100.0
        let category = "Food"
        let currency = "CAD"
        
        // When
        viewModel.addExpense(
            title: title,
            amount: amount,
            category: category,
            date: Date(),
            currency: currency
        )
        
        // Wait for API call
        let expectation = XCTestExpectation(description: "Currency conversion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.0)
        
        // Then
        viewModel.fetchExpenses()
        if let addedExpense = viewModel.expenses.first {
            XCTAssertEqual(addedExpense.amount, amount, "Original amount should match")
            XCTAssertGreaterThan(addedExpense.convertedAmount, 0, "Should have converted amount")
        }
    }
    
    func testAddExpense_MultipleExpenses() {
        // Given
        let count = 5
        
        // When
        for i in 0..<count {
            viewModel.addExpense(
                title: "Expense \(i)",
                amount: Double(i * 10),
                category: "Food",
                date: Date(),
                currency: "USD"
            )
        }
        
        // Wait
        let expectation = XCTestExpectation(description: "Multiple expenses added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // Then
        viewModel.fetchExpenses()
        XCTAssertGreaterThanOrEqual(viewModel.expenses.count, count, "Should have added expenses")
    }
    
    // MARK: - Delete Expense Tests
    
    func testDeleteExpense_Success() {
        // Given
        viewModel.addExpense(
            title: "To Delete",
            amount: 50.0,
            category: "Food",
            date: Date(),
            currency: "USD"
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        viewModel.fetchExpenses()
        let initialCount = viewModel.expenses.count
        guard let expenseToDelete = viewModel.expenses.first else {
            XCTFail("Should have an expense")
            return
        }
        
        // When
        viewModel.deleteExpense(expenseToDelete)
        
        // Wait
        let expectation2 = XCTestExpectation(description: "Expense deleted")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        // Then
        viewModel.fetchExpenses()
        XCTAssertEqual(viewModel.expenses.count, initialCount - 1, "Should have deleted")
    }
    
    // MARK: - Fetch Tests
    
    func testFetchExpenses_EmptyInitially() {
        // When
        viewModel.fetchExpenses()
        
        // Then
        XCTAssertTrue(viewModel.expenses.isEmpty || viewModel.expenses.allSatisfy { $0.userId == "test@example.com" })
    }
    
    func testFetchExpenses_AfterAdding() {
        // Given
        viewModel.addExpense(
            title: "Test",
            amount: 100.0,
            category: "Food",
            date: Date(),
            currency: "USD"
        )
        
        let expectation = XCTestExpectation(description: "Expense added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        viewModel.fetchExpenses()
        
        // Then
        XCTAssertGreaterThan(viewModel.expenses.count, 0, "Should have expenses")
    }
    
    // MARK: - User Isolation Tests
    
    func testUserIsolation() {
        // Given - User 1
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user1",
            email: "user1@example.com",
            password: "password",
            firstName: "User",
            lastName: "One"
        )
        
        let viewModel1 = ExpenseViewModel()
        viewModel1.addExpense(
            title: "User 1 Expense",
            amount: 100.0,
            category: "Food",
            date: Date(),
            currency: "USD"
        )
        
        let expectation1 = XCTestExpectation(description: "User 1 expense")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 2.0)
        
        viewModel1.fetchExpenses()
        let user1Count = viewModel1.expenses.count
        
        // When - User 2
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user2",
            email: "user2@example.com",
            password: "password",
            firstName: "User",
            lastName: "Two"
        )
        
        let viewModel2 = ExpenseViewModel()
        viewModel2.fetchExpenses()
        let user2Count = viewModel2.expenses.count
        
        // Then
        XCTAssertGreaterThan(user1Count, 0, "User 1 should have expenses")
        XCTAssertEqual(user2Count, 0, "User 2 should have no expenses")
        
        // Cleanup
        for expense in viewModel1.expenses {
            viewModel1.deleteExpense(expense)
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceAddExpense() {
        measure {
            viewModel.addExpense(
                title: "Performance",
                amount: 100.0,
                category: "Food",
                date: Date(),
                currency: "USD"
            )
        }
    }
    
    func testPerformanceFetchExpenses() {
        // Setup
        for i in 0..<20 {
            viewModel.addExpense(
                title: "Expense \(i)",
                amount: Double(i),
                category: "Food",
                date: Date(),
                currency: "USD"
            )
        }
        
        let expectation = XCTestExpectation(description: "Setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.0)
        
        // Measure
        measure {
            viewModel.fetchExpenses()
        }
    }
}