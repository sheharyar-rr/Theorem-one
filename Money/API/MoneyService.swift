//
//  MoneyService.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation
import Combine

protocol MoneyServiceProtocol {
    var isBusy: AnyPublisher<Bool, Never> { get }

    func getAccount() async -> Account?
    func getTransactions() async -> MoneyTransaction?
    func getAdvice(transactionIds: [String]) async -> Advice?
}

class MoneyService: MoneyServiceProtocol {
    
    var isBusy: AnyPublisher<Bool, Never>
    
    private var api: MoneyServiceProtocol
    private var persistance: MoneyServiceProtocol & MoneyPersistanceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(Api: MoneyServiceProtocol = MoneyApiService(), persistance: (MoneyServiceProtocol & MoneyPersistanceProtocol) = MoneyPersistanceService()) {
        self.api = Api
        self.persistance = persistance
        
        self.isBusy = api.isBusy
    }
    
    func getAccount() async -> Account? {
        if let account = await api.getAccount() {
            // Save to persistence layer
            persistance.saveAccount(account: account)
            return account
        } else {
            return await persistance.getAccount()
        }
    }
    
    func getTransactions() async -> MoneyTransaction? {
        if let transactions = await api.getTransactions() {
            // Save to persistence layer
            persistance.saveTransactions(transactions: transactions)
            return transactions
        } else {
            return await persistance.getTransactions()
        }
    }
    
    func getAdvice(transactionIds: [String]) async -> Advice? {
        await api.getAdvice(transactionIds: transactionIds)
    }
    
}
