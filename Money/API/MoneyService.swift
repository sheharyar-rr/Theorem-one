//
//  MoneyService.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation
import Combine

class MoneyService: MoneyServiceProtocol {
    
    var isBusy: AnyPublisher<Bool, Never>
    
    private var api: MoneyServiceProtocol
    private var persistance: MoneyPersistanceServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(Api: MoneyServiceProtocol = MoneyApiService(),
         persistance: MoneyPersistanceServiceProtocol = MoneyPersistanceService()) {
        self.api = Api
        self.persistance = persistance
        self.isBusy = api.isBusy
    }
    
    func getAccount() async -> Result<Account, Error> {
        let result = await api.getAccount()
        switch result {
        case .success(let account):
            // Save to persistence layer
            persistance.saveAccount(account: account)
            return result
        case .failure(_):
            return await persistance.getAccount()
        }
    }
    
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        let result = await api.getTransactions()
        switch result {
        case .success(let transactions):
            // Save to persistence layer
            persistance.saveTransactions(transactions: transactions)
            return result
        case .failure(_):
            return await persistance.getTransactions()
        }
    }
    
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error> {
        await api.getAdvice(transactionIds: transactionIds)
    }
    
}
