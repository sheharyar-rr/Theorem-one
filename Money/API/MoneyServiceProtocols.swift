//
//  MoneyServiceProtocols.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import Combine

/*
  This design closely adheres to the SOLID principles, particularly emphasizing the Interface Segregation Principle (ISP).
  We've segregated the interfaces for accounts, transactions, and advice, allowing for more focused and cohesive implementations.
 */

protocol MoneyServiceProtocol: MoneyServiceAccountProtocol, MoneyServiceTransactionProtocol, MoneyServiceAdviceProtocol {
    /// A publisher that emits a boolean value indicating whether the service is currently busy or not.
    var isBusy: AnyPublisher<Bool, Never> { get }
}

protocol MoneyServiceAccountProtocol {
    /// Asynchronously retrieves the user's account information.
    /// - Returns: A `Result` containing either the account information or an error.
    func getAccount() async -> Result<Account, Error>
}

protocol MoneyServiceTransactionProtocol {
    /// Asynchronously retrieves the user's transaction history.
    /// - Returns: A `Result` containing either the transaction data or an error.
    func getTransactions() async -> Result<MoneyTransaction, Error>
}

protocol MoneyServiceAdviceProtocol {
    /// Asynchronously retrieves financial advice based on a list of transaction IDs.
    /// - Parameter transactionIds: An array of transaction IDs to use for generating advice.
    /// - Returns: A `Result` containing either financial advice or an error.
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error>
}

/// A protocol that extends the MoneyServiceProtocol and includes methods for persistence operations.
protocol MoneyPersistenceServiceProtocol: MoneyServiceAccountProtocol, MoneyServiceTransactionProtocol, MoneyPersistenceProtocol {
    // This protocol inherits methods from MoneyServiceAccountProtocol,MoneyServiceTransactionProtocol and MoneyPersistenceProtocol.
}
