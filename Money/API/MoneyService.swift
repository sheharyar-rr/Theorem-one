//
//  MoneyService.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation
import Combine

/*
 MoneyService combines both the API and Persistence layers
 while also managing the logic for data storage and retrieval.
 It conforms to the MoneyServiceProtocol, allowing the layers above to utilize its functionality as needed.
 */

class MoneyService: MoneyServiceProtocol {
    
    var isBusy: AnyPublisher<Bool, Never>
    
    /// The API service responsible for fetching money-related data.
    private var api: MoneyServiceProtocol
    
    /// The persistence service responsible for saving and retrieving data locally.
    private var persistence: MoneyPersistenceServiceProtocol
    
    /// Initializes a `MoneyService` with optional API and persistence services.
    /// - Parameters:
    ///   - api: The API service responsible for fetching money-related data.
    ///   - persistence: The persistence service responsible for saving and retrieving data locally.
    init(api: MoneyServiceProtocol = MoneyApiService(),
         persistence: MoneyPersistenceServiceProtocol = MoneyPersistenceService()) {
        self.api = api
        self.persistence = persistence
        self.isBusy = api.isBusy
    }
    
    /// Fetches the account information asynchronously.
    /// - Returns: A result containing either the account information or an error.
    func getAccount() async -> Result<Account, Error> {
        let result = await api.getAccount()
        switch result {
        case .success(let account):
            // Save to persistence layer
            persistence.saveAccount(account: account)
            return result
        case .failure(let error):
            print("Network error in \(#function): \(error.localizedDescription)")
            return await persistence.getAccount()
        }
    }
    
    /// Fetches the money transactions asynchronously.
    /// - Returns: A result containing either the money transactions or an error.
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        let result = await api.getTransactions()
        switch result {
        case .success(let transactions):
            // Save to persistence layer
            persistence.saveTransactions(transactions: transactions)
            return result
        case .failure(let error):
            print("Network error in \(#function): \(error.localizedDescription)")
            return await persistence.getTransactions()
        }
    }
    
    /// Fetches advice based on a list of transaction IDs asynchronously.
    /// - Parameter transactionIds: The list of transaction IDs for which advice is requested.
    /// - Returns: A result containing either advice or an error.
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error> {
        await api.getAdvice(transactionIds: transactionIds)
    }
    
}
