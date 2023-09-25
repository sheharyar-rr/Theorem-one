//
//  MoneyApiService.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import Combine

/// A service responsible for interacting with the Money API to retrieve financial data.
class MoneyApiService {
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()
    
    private let serviceBaseURL: URL = URL(string: "https://8kq890lk50.execute-api.us-east-1.amazonaws.com/prd/accounts/0172bd23-c0da-47d0-a4e0-53a3ad40828f")!
    private let client: HTTPClient
    
    /// Initializes a `MoneyApiService` with an optional custom HTTP client, defaulting to `URLSessionHTTPClient`.
    /// - Parameter client: An HTTP client used to make network requests.
    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }
}

extension MoneyApiService: MoneyServiceProtocol {
    
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
    
    /// Retrieves the account information asynchronously.
    /// - Returns: A result containing either the account information or an error.
    func getAccount() async -> Result<Account, Error> {
        return await withBusyFlag {
            let url = serviceBaseURL.appending(component: "balance")
            return await client.GETRequest(url: url)
        }
    }
    
    /// Retrieves money transactions asynchronously.
    /// - Returns: A result containing either the money transactions or an error.
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        return await withBusyFlag {
            let url = serviceBaseURL.appending(component: "transactions")
            return await client.GETRequest(url: url)
        }
    }
    
    /// Retrieves financial advice asynchronously based on a list of transaction IDs.
    /// - Parameter transactionIds: An array of transaction IDs.
    /// - Returns: A result containing either financial advice or an error.
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error> {
        return await withBusyFlag {
            let url = serviceBaseURL.appending(component: "transactions").appending(component: "advice")
            let body = ["transactionIds": transactionIds]
            return await client.POSTRequest(url: url, body: body)
        }
    }
}
