//
//  MoneyPersistanceService.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import Foundation
import Combine

protocol MoneyPersistanceProtocol {
    func saveAccount(account: Account)
    func saveTransactions(transactions: MoneyTransaction)
    
    func deleteAccount()
    func deleteTransactions()
}

class MoneyPersistanceService: MoneyServiceProtocol {
    
    enum dataType: String {
        case balance, transactions, advice
    }
    
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()
    
    func getAccount() async -> Account? {
        await getData(type: .balance)
    }
    
    func getTransactions() async -> MoneyTransaction? {
        await getData(type: .transactions)
    }
    
    func getAdvice(transactionIds: [String]) async -> Advice? {
        // Doesn't support it yet, but functionality can be added
        return nil
    }
}

extension MoneyPersistanceService: MoneyPersistanceProtocol {
    func deleteTransactions() {
        deleteData(type: .transactions)
    }
    
    func saveTransactions(transactions: MoneyTransaction) {
        saveData(data: transactions, type: .transactions)
    }
    
    func deleteAccount() {
        deleteData(type: .balance)
    }
    
    func saveAccount(account: Account) {
        saveData(data: account, type: .balance)
    }
}

extension MoneyPersistanceService {
    
    private func getData<T: Codable>(type: dataType) async -> T? {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let decoder = JSONDecoder()
        do {
            if let data = UserDefaults.standard.data(forKey: type.rawValue) {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func saveData<T: Codable>(data: T, type: dataType) {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(data)
            UserDefaults.standard.set(encodedData, forKey: type.rawValue)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteData(type: dataType) {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        UserDefaults.standard.removeObject(forKey: type.rawValue)
    }
}
