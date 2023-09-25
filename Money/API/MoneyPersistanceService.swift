//
//  MoneyPersistenceService.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import Foundation
import Combine

/*
 We have opted for UserDefaults to streamline persistence, acknowledging that in production environments,
 alternatives such as CoreData or Keychain might offer more robust solutions.
 */

/// A protocol defining the methods for persisting money-related data.
protocol MoneyPersistenceProtocol {
    func saveAccount(account: Account) async
    func saveTransactions(transactions: MoneyTransaction) async
    func deleteAccount() async
    func deleteTransactions() async
}

/// An enumeration representing possible errors related to money operations.
public enum MoneyError: Error {
    case noDecodedData
}

/// A service responsible for persisting money-related data, such as account balance and transactions.
class MoneyPersistenceService: MoneyPersistenceServiceProtocol {
    
    /// An enumeration to identify the types of data being stored.
    enum DataType: String {
        case balance, transactions, advice
    }
    
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    /// Retrieves the account information asynchronously.
    /// - Returns: A result containing either the account information or an error.
    func getAccount() async -> Result<Account, Error> {
        await getData(type: .balance)
    }
    
    /// Retrieves money transactions asynchronously.
    /// - Returns: A result containing either the money transactions or an error.
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        await getData(type: .transactions)
    }
}

// MARK: - MoneyPersistenceService Extensions
extension MoneyPersistenceService {
    func deleteTransactions() async {
        await deleteData(type: .transactions)
    }
    
    func saveTransactions(transactions: MoneyTransaction) async {
        await saveData(data: transactions, type: .transactions)
    }
    
    func deleteAccount() async {
        await deleteData(type: .balance)
    }
    
    func saveAccount(account: Account) async {
        await saveData(data: account, type: .balance)
    }
}

extension MoneyPersistenceService {
    
    /// A utility method for executing asynchronous operations with proper `_isBusy` flag management.
    ///
    /// This method wraps the provided asynchronous block of code with the necessary management
    /// of the `_isBusy` flag, ensuring it is set to `true` before the operation and reset to
    /// `false` afterward, even if an error is thrown during the operation.
    ///
    /// - Parameters:
    ///   - block: An asynchronous block of code to execute.
    ///
    /// - Returns: The result of the provided asynchronous operation.
    ///
    /// - Throws: Any errors thrown by the asynchronous operation.
    private func withBusyFlag<T>(_ block: () async throws -> T) async rethrows -> T {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        return try await block()
    }
    
    /// Retrieves data of a specified type asynchronously.
    /// - Parameters:
    ///   - type: The type of data to retrieve.
    /// - Returns: A result containing either the retrieved data or an error.
    private func getData<T: Codable>(type: DataType) async -> Result<T, Error> {
        return await withBusyFlag {
            do {
                if let data = UserDefaults.standard.data(forKey: type.rawValue) {
                    let decodedData = try decoder.decode(T.self, from: data)
                    return .success(decodedData)
                }
                return .failure(MoneyError.noDecodedData)
            } catch {
                print("Error while decoding data for \(type.rawValue): \(error)")
                return .failure(error)
            }
        }
    }
    
    /// Saves data of a specified type to storage.
    /// - Parameters:
    ///   - data: The data to be saved.
    ///   - type: The type of data being saved.
    private func saveData<T: Codable>(data: T, type: DataType) async {
        return await withBusyFlag {
            do {
                let encodedData = try encoder.encode(data)
                UserDefaults.standard.set(encodedData, forKey: type.rawValue)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Deletes data of a specified type from storage.
    /// - Parameter type: The type of data to be deleted.
    private func deleteData(type: DataType) async {
        return await withBusyFlag {
            UserDefaults.standard.removeObject(forKey: type.rawValue)
        }
    }
}
