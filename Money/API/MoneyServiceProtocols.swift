//
//  MoneyServiceProtocols.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import Combine

// This was a huge focus from SOLID principles. Over here would be a good display of the 4th principal. interface segregation principle
// We separate the principal for accounts/transactions/advice
// Also using typealias's for when we need to combine them

protocol MoneyServiceProtocol: MoneyServiceAccountProtocol, MoneyServiceTransactionProtocol, MoneyServiceAdviceProtocol {
    var isBusy: AnyPublisher<Bool, Never> { get }
}

protocol MoneyServiceAccountProtocol {
    func getAccount() async -> Result<Account, Error>
}

protocol MoneyServiceTransactionProtocol {
    func getTransactions() async -> Result<MoneyTransaction, Error>
}

protocol MoneyServiceAdviceProtocol {
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error>
}

typealias MoneyPersistanceServiceProtocol = (MoneyServiceAccountProtocol & MoneyServiceTransactionProtocol & MoneyPersistanceProtocol)
