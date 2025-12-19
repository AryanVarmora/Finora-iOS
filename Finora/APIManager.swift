//
//  APIManager.swift
//  Finora
//
//  Created by Aryan Varmora on 12/18/25.
//


//
//  APIManager.swift
//  Finora
//
//  Network layer for backend communication
//

import Foundation
import UIKit

class APIManager {
    static let shared = APIManager()
    
    // CHANGE THIS to your deployed backend URL
    private let baseURL = "http://localhost:3000/api"
    // For local testing: "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - Authentication
    
    func register(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/auth/register"
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]
        
        makeRequest(endpoint: endpoint, method: "POST", body: body, completion: completion)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/auth/login"
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        makeRequest(endpoint: endpoint, method: "POST", body: body, completion: completion)
    }
    
    func getCurrentUser(token: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let endpoint = "\(baseURL)/auth/me"
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "GET", completion: completion)
    }
    
    // MARK: - Expenses
    
    func getExpenses(token: String, completion: @escaping (Result<ExpensesResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/expenses"
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "GET", completion: completion)
    }
    
    func createExpense(token: String, expense: APIExpenseData, completion: @escaping (Result<ExpenseResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/expenses"
        
        let body: [String: Any] = [
            "title": expense.title,
            "amount": expense.amount,
            "category": expense.category,
            "currency": expense.currency,
            "date": ISO8601DateFormatter().string(from: expense.date),
            "convertedAmount": expense.convertedAmount,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]
        
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "POST", body: body, completion: completion)
    }
    
    func updateExpense(token: String, expenseId: String, expense: APIExpenseData, completion: @escaping (Result<ExpenseResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/expenses/\(expenseId)"
        
        let body: [String: Any] = [
            "title": expense.title,
            "amount": expense.amount,
            "category": expense.category,
            "currency": expense.currency,
            "date": ISO8601DateFormatter().string(from: expense.date),
            "convertedAmount": expense.convertedAmount
        ]
        
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "PUT", body: body, completion: completion)
    }
    
    func deleteExpense(token: String, expenseId: String, completion: @escaping (Result<SuccessResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/expenses/\(expenseId)"
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "DELETE", completion: completion)
    }
    
    func syncExpenses(token: String, expenses: [APIExpenseData], lastSync: Date?, completion: @escaping (Result<SyncResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/expenses/sync"
        
        var body: [String: Any] = [
            "expenses": expenses.map { $0.toDictionary() }
        ]
        
        if let lastSync = lastSync {
            body["lastSync"] = ISO8601DateFormatter().string(from: lastSync)
        }
        
        makeAuthenticatedRequest(endpoint: endpoint, token: token, method: "POST", body: body, completion: completion)
    }
    
    // MARK: - Private Helpers
    
    private func makeRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        DispatchQueue.main.async {
                            completion(.failure(APIError.serverError(errorResponse.message)))
                        }
                        return
                    }
                }
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func makeAuthenticatedRequest<T: Decodable>(endpoint: String, token: String, method: String, body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(.failure(APIError.unauthorized))
                    }
                    return
                }
                
                if httpResponse.statusCode >= 400 {
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        DispatchQueue.main.async {
                            completion(.failure(APIError.serverError(errorResponse.message)))
                        }
                        return
                    }
                }
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Models
// MARK: - Models

struct AuthResponse: Codable, Sendable {
    let success: Bool
    let message: String
    let token: String
    let user: UserInfo
}

struct UserInfo: Codable, Sendable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let fullName: String
}

struct APIExpenseData: Codable, Sendable {
    let title: String
    let amount: Double
    let category: String
    let currency: String
    let date: Date
    let convertedAmount: Double
    var _id: String?
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "amount": amount,
            "category": category,
            "currency": currency,
            "date": ISO8601DateFormatter().string(from: date),
            "convertedAmount": convertedAmount
        ]
        if let id = _id {
            dict["_id"] = id
        }
        return dict
    }
}

struct ExpenseResponse: Codable, Sendable {
    let success: Bool
    let message: String?
    let expense: ServerExpense
}

struct ExpensesResponse: Codable, Sendable {
    let success: Bool
    let count: Int
    let expenses: [ServerExpense]
}

struct ServerExpense: Codable, Sendable {
    let _id: String
    let userId: String
    let title: String
    let amount: Double
    let category: String
    let currency: String
    let date: Date
    let convertedAmount: Double
    let lastModified: Date
}

struct SyncResponse: Codable, Sendable {
    let success: Bool
    let message: String
    let serverExpenses: [ServerExpense]
}

struct SuccessResponse: Codable, Sendable {
    let success: Bool
    let message: String
}

struct ErrorResponse: Codable, Sendable {
    let error: String
    let message: String
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .serverError(let message):
            return message
        }
    }
}
