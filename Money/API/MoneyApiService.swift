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
    /// Retrieves the account information asynchronously.
    /// - Returns: A result containing either the account information or an error.
    func getAccount() async -> Result<Account, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "balance")
        return await client.GETRequest(url: url)
    }
    
    /// Retrieves money transactions asynchronously.
    /// - Returns: A result containing either the money transactions or an error.
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "transactions")
        return await client.GETRequest(url: url)
    }
    
    /// Retrieves financial advice asynchronously based on a list of transaction IDs.
    /// - Parameter transactionIds: An array of transaction IDs.
    /// - Returns: A result containing either financial advice or an error.
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "transactions").appending(component: "advice")
        let body = ["transactionIds": transactionIds]
        return await client.POSTRequest(url: url, body: body)
    }
}
