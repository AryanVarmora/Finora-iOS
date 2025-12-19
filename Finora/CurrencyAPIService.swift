//
//  CurrencyAPIService.swift
//  Finora - FIXED conversion logic
//

import Foundation

class CurrencyAPIService: @unchecked Sendable {
    static let shared = CurrencyAPIService()
    
    private let baseURL = "https://api.exchangerate-api.com/v4/latest/"
    private var cachedRates: [String: Double] = [:]
    private var lastFetchTime: Date?
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    private init() {}
    
    // MARK: - Fetch Exchange Rates
    nonisolated func fetchExchangeRates(baseCurrency: String = "USD", completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
        
        // Check if we have valid cached data
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheValidityDuration,
           !cachedRates.isEmpty {
            let response = ExchangeRateResponse(base: baseCurrency, rates: cachedRates)
            completion(.success(response))
            return
        }
        
        let urlString = baseURL + baseCurrency
        guard let url = URL(string: urlString) else {
            completion(.failure(CurrencyError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(CurrencyError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ExchangeRateResponse.self, from: data)
                
                // Cache the results
                self?.cachedRates = result.rates
                self?.lastFetchTime = Date()
                
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Convert Currency (FIXED)
    nonisolated func convertCurrency(
        amount: Double,
        from: String,
        to: String,
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        // Always use USD as base for consistent conversion
        fetchExchangeRates(baseCurrency: "USD") { result in
            switch result {
            case .success(let response):
                guard let fromRate = response.rates[from], let toRate = response.rates[to] else {
                    completion(.failure(CurrencyError.currencyNotFound))
                    return
                }
                
                // Convert: amount (in 'from' currency) → USD → 'to' currency
                // Example: 23000 INR → USD
                // 1 USD = 83.5 INR (fromRate)
                // 23000 INR / 83.5 = 275.45 USD
                
                let amountInUSD = amount / fromRate
                let convertedAmount = amountInUSD * toRate
                
                print("💱 Converting \(amount) \(from) → \(to)")
                print("   \(from) rate: \(fromRate)")
                print("   \(to) rate: \(toRate)")
                print("   Amount in USD: \(amountInUSD)")
                print("   Final amount: \(convertedAmount) \(to)")
                
                completion(.success(convertedAmount))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Supported Currencies
    nonisolated func getSupportedCurrencies() -> [String] {
        return [
            "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY",
            "INR", "MXN", "BRL", "ZAR", "KRW", "SGD", "HKD", "NOK",
            "SEK", "DKK", "NZD", "TRY"
        ]
    }
    
    // MARK: - Get Currency Symbol
    nonisolated func getCurrencySymbol(for currencyCode: String) -> String {
        let symbols: [String: String] = [
            "USD": "$",
            "EUR": "€",
            "GBP": "£",
            "JPY": "¥",
            "AUD": "A$",
            "CAD": "C$",
            "CHF": "Fr",
            "CNY": "¥",
            "INR": "₹",
            "MXN": "Mex$",
            "BRL": "R$",
            "ZAR": "R",
            "KRW": "₩",
            "SGD": "S$",
            "HKD": "HK$",
            "NOK": "kr",
            "SEK": "kr",
            "DKK": "kr",
            "NZD": "NZ$",
            "TRY": "₺"
        ]
        
        return symbols[currencyCode] ?? currencyCode
    }
    
    // MARK: - Get Exchange Rate
    nonisolated func getExchangeRate(from: String, to: String, completion: @escaping (Result<Double, Error>) -> Void) {
        fetchExchangeRates(baseCurrency: "USD") { result in
            switch result {
            case .success(let response):
                guard let fromRate = response.rates[from], let toRate = response.rates[to] else {
                    completion(.failure(CurrencyError.currencyNotFound))
                    return
                }
                
                // Calculate exchange rate: how many 'to' currency per 1 'from' currency
                let rate = toRate / fromRate
                completion(.success(rate))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Supporting Types

struct ExchangeRateResponse: Codable, Sendable {
    let base: String
    let rates: [String: Double]
}

enum CurrencyError: Error, LocalizedError {
    case invalidURL
    case noData
    case currencyNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .currencyNotFound:
            return "Currency not found"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
