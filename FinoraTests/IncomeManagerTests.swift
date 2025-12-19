//
//  IncomeManagerTests.swift
//  Finora
//
//  Created by Aryan Varmora on 12/8/25.
//


//
//  IncomeManagerTests.swift
//  FinoraTests
//
//  Unit tests for IncomeManager
//

import XCTest
import CoreData
@testable import Finora

final class IncomeManagerTests: XCTestCase {
    
    var incomeManager: IncomeManager!
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
        incomeManager = IncomeManager.shared
        
        // Set test user
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "test-user",
            email: "test@example.com",
            password: "password",
            firstName: "Test",
            lastName: "User"
        )
        
        // Clear any existing income
        incomeManager.deleteIncome()
    }
    
    override func tearDown() {
        // Clean up
        incomeManager.deleteIncome()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = IncomeEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? testContext.execute(deleteRequest)
        
        incomeManager = nil
        testContext = nil
        AuthenticationManager.shared.currentUser = nil
        super.tearDown()
    }
    
    // MARK: - Set Income Tests
    
    func testSetIncome_Success() {
        // Given
        let amount = 5000.0
        
        // When
        incomeManager.setIncome(amount: amount)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, amount, "Monthly income should be set")
    }
    
    func testSetIncome_Update() {
        // Given - Set initial income
        incomeManager.setIncome(amount: 5000.0)
        XCTAssertEqual(incomeManager.monthlyIncome, 5000.0)
        
        // When - Update income
        incomeManager.setIncome(amount: 6000.0)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, 6000.0, "Income should be updated")
    }
    
    func testSetIncome_Zero() {
        // Given
        incomeManager.setIncome(amount: 5000.0)
        
        // When
        incomeManager.setIncome(amount: 0.0)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, 0.0, "Should be able to set income to 0")
    }
    
    func testSetIncome_Negative() {
        // When
        incomeManager.setIncome(amount: -1000.0)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, -1000.0, "Should accept negative income (debt scenario)")
    }
    
    func testSetIncome_Large() {
        // When
        let largeAmount = 1_000_000.0
        incomeManager.setIncome(amount: largeAmount)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, largeAmount, "Should handle large amounts")
    }
    
    // MARK: - Load Income Tests
    
    func testLoadIncome_NoIncome() {
        // When
        incomeManager.loadIncome()
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, 0.0, "Should default to 0 when no income set")
    }
    
    func testLoadIncome_AfterSet() {
        // Given
        incomeManager.setIncome(amount: 5000.0)
        
        // When - Create new manager instance (simulates app restart)
        let newManager = IncomeManager()
        newManager.loadIncome()
        
        // Then
        XCTAssertEqual(newManager.monthlyIncome, 5000.0, "Should load saved income")
    }
    
    func testLoadIncome_Persistence() {
        // Given - Set income and verify it's saved
        incomeManager.setIncome(amount: 7500.0)
        
        // When - Reload
        incomeManager.loadIncome()
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, 7500.0, "Income should persist after reload")
    }
    
    // MARK: - Delete Income Tests
    
    func testDeleteIncome_Success() {
        // Given - Set income first
        incomeManager.setIncome(amount: 5000.0)
        XCTAssertEqual(incomeManager.monthlyIncome, 5000.0)
        
        // When
        incomeManager.deleteIncome()
        
        // Then
        incomeManager.loadIncome()
        XCTAssertEqual(incomeManager.monthlyIncome, 0.0, "Income should be 0 after deletion")
    }
    
    func testDeleteIncome_NoIncome() {
        // When - Delete when no income exists
        incomeManager.deleteIncome()
        
        // Then - Should not crash
        incomeManager.loadIncome()
        XCTAssertEqual(incomeManager.monthlyIncome, 0.0)
    }
    
    func testDeleteIncome_ThenSet() {
        // Given
        incomeManager.setIncome(amount: 5000.0)
        incomeManager.deleteIncome()
        
        // When - Set new income after deletion
        incomeManager.setIncome(amount: 6000.0)
        
        // Then
        incomeManager.loadIncome()
        XCTAssertEqual(incomeManager.monthlyIncome, 6000.0, "Should be able to set income after deletion")
    }
    
    // MARK: - User Isolation Tests
    
    func testUserIsolation() {
        // Given - Set income for User 1
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user1",
            email: "user1@example.com",
            password: "password",
            firstName: "User",
            lastName: "One"
        )
        
        incomeManager.setIncome(amount: 5000.0)
        incomeManager.loadIncome()
        let user1Income = incomeManager.monthlyIncome
        
        // When - Switch to User 2
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user2",
            email: "user2@example.com",
            password: "password",
            firstName: "User",
            lastName: "Two"
        )
        
        incomeManager.loadIncome()
        let user2Income = incomeManager.monthlyIncome
        
        // Then
        XCTAssertEqual(user1Income, 5000.0, "User 1 should have $5000 income")
        XCTAssertEqual(user2Income, 0.0, "User 2 should have $0 income")
    }
    
    func testMultipleUsers_IndependentIncome() {
        // Given - User 1 sets income
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user1",
            email: "user1@example.com",
            password: "password",
            firstName: "User",
            lastName: "One"
        )
        
        incomeManager.setIncome(amount: 5000.0)
        
        // User 2 sets different income
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user2",
            email: "user2@example.com",
            password: "password",
            firstName: "User",
            lastName: "Two"
        )
        
        incomeManager.setIncome(amount: 7000.0)
        
        // When - Go back to User 1
        AuthenticationManager.shared.currentUser = RegisteredUser(
            id: "user1",
            email: "user1@example.com",
            password: "password",
            firstName: "User",
            lastName: "One"
        )
        
        incomeManager.loadIncome()
        let user1FinalIncome = incomeManager.monthlyIncome
        
        // Then
        XCTAssertEqual(user1FinalIncome, 5000.0, "User 1's income should not be affected by User 2")
    }
    
    // MARK: - Edge Cases
    
    func testSetIncome_MultipleTimesQuickly() {
        // When - Set income multiple times quickly
        incomeManager.setIncome(amount: 1000.0)
        incomeManager.setIncome(amount: 2000.0)
        incomeManager.setIncome(amount: 3000.0)
        incomeManager.setIncome(amount: 4000.0)
        incomeManager.setIncome(amount: 5000.0)
        
        // Then - Should use the last value
        incomeManager.loadIncome()
        XCTAssertEqual(incomeManager.monthlyIncome, 5000.0, "Should save the last value")
    }
    
    func testSetIncome_Decimal() {
        // When - Set income with decimals
        let amount = 5432.67
        incomeManager.setIncome(amount: amount)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, amount, "Should handle decimal values")
    }
    
    func testSetIncome_VerySmall() {
        // When - Set very small income
        let amount = 0.01
        incomeManager.setIncome(amount: amount)
        
        // Then
        XCTAssertEqual(incomeManager.monthlyIncome, amount, "Should handle very small amounts")
    }
    
    // MARK: - Core Data Integration Tests
    
    func testCoreData_EntityCreation() {
        // Given
        let amount = 5000.0
        
        // When
        incomeManager.setIncome(amount: amount)
        
        // Then - Verify entity was created in Core Data
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", "test@example.com")
        
        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Should have 1 income entity")
            if let income = results.first {
                XCTAssertEqual(income.amount, amount, "Amount should match")
                XCTAssertEqual(income.userId, "test@example.com", "User ID should match")
            }
        } catch {
            XCTFail("Failed to fetch income entity: \(error)")
        }
    }
    
    func testCoreData_EntityUpdate() {
        // Given - Set initial income
        incomeManager.setIncome(amount: 5000.0)
        
        // When - Update income
        incomeManager.setIncome(amount: 6000.0)
        
        // Then - Should still have only 1 entity
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", "test@example.com")
        
        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Should still have 1 income entity (updated, not duplicated)")
            if let income = results.first {
                XCTAssertEqual(income.amount, 6000.0, "Amount should be updated")
            }
        } catch {
            XCTFail("Failed to fetch income entity: \(error)")
        }
    }
    
    func testCoreData_EntityDeletion() {
        // Given - Set income
        incomeManager.setIncome(amount: 5000.0)
        
        // When - Delete income
        incomeManager.deleteIncome()
        
        // Then - Entity should be deleted
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", "test@example.com")
        
        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 0, "Income entity should be deleted")
        } catch {
            XCTFail("Failed to fetch income entity: \(error)")
        }
    }
    
    func testCoreData_Timestamps() {
        // Given
        let beforeSet = Date()
        
        // When
        incomeManager.setIncome(amount: 5000.0)
        
        // Then - Check timestamps
        let fetchRequest: NSFetchRequest<IncomeEntity> = IncomeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", "test@example.com")
        
        do {
            let results = try testContext.fetch(fetchRequest)
            if let income = results.first {
                XCTAssertNotNil(income.createdAt, "Should have createdAt timestamp")
                XCTAssertNotNil(income.updatedAt, "Should have updatedAt timestamp")
                XCTAssertGreaterThanOrEqual(income.createdAt ?? Date.distantPast, beforeSet, "createdAt should be recent")
                XCTAssertGreaterThanOrEqual(income.updatedAt ?? Date.distantPast, beforeSet, "updatedAt should be recent")
            }
        } catch {
            XCTFail("Failed to fetch income entity: \(error)")
        }
    }
    
    // MARK: - Observable Object Tests
    
    func testObservableObject_PublishesChanges() {
        // Given - Expectation for published change
        let expectation = XCTestExpectation(description: "Income change published")
        
        var receivedValue: Double = 0
        let cancellable = incomeManager.$monthlyIncome.sink { value in
            receivedValue = value
            if value == 5000.0 {
                expectation.fulfill()
            }
        }
        
        // When
        incomeManager.setIncome(amount: 5000.0)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, 5000.0, "Should publish income change")
        
        cancellable.cancel()
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSetIncome() {
        measure {
            incomeManager.setIncome(amount: 5000.0)
        }
    }
    
    func testPerformanceLoadIncome() {
        // Given - Set income first
        incomeManager.setIncome(amount: 5000.0)
        
        // Measure
        measure {
            incomeManager.loadIncome()
        }
    }
    
    func testPerformanceDeleteIncome() {
        // Given - Set income first
        incomeManager.setIncome(amount: 5000.0)
        
        // Measure
        measure {
            incomeManager.deleteIncome()
            // Set again for next iteration
            incomeManager.setIncome(amount: 5000.0)
        }
    }
}