//
//  MoneyApiService.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import Combine

class MoneyApiService {
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()
    
    private let serviceBaseURL = URL(string: "https://8kq890lk50.execute-api.us-east-1.amazonaws.com/prd/accounts/0172bd23-c0da-47d0-a4e0-53a3ad40828f")!
    private let client: HTTPClient
    
    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }
}

extension MoneyApiService: MoneyServiceProtocol {
    
    func getAccount() async -> Result<Account, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "balance")
        return await client.GETRequest(url: url)
    }
    
    func getTransactions() async -> Result<MoneyTransaction, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "transactions")
        return await client.GETRequest(url: url)
    }
    
    func getAdvice(transactionIds: [String]) async -> Result<Advice, Error> {
        _isBusy.send(true)
        defer { _isBusy.send(false) }
        
        let url = serviceBaseURL.appending(component: "transactions").appending(component: "advice")
        let body = ["transactionIds": transactionIds]
        return await client.POSTRequest(url: url, body: body)
    }
}
