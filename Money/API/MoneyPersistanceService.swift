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

public enum MoneyError: Error {
    case noDecodedData
}

class MoneyPersistanceService: MoneyPersistanceServiceProtocol {
    
    enum dataType: String {
        case balance, transactions, advice
    }
    
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func getAccount() async -> Result<Account, Error> {
        await getData(type: .balance)
    }
    
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        await getData(type: .transactions)
    }
}

extension MoneyPersistanceService {
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
    
    private func getData<T: Codable>(type: dataType) async -> Result<T, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        do {
            if let data = UserDefaults.standard.data(forKey: type.rawValue) {
                let decodedData = try decoder.decode(T.self, from: data)
                return .success(decodedData)
            }
            return .failure(MoneyError.noDecodedData)
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    private func saveData<T: Codable>(data: T, type: dataType) {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
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
