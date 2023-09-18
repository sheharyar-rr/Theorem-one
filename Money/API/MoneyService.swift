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
}

class MoneyService: MoneyServiceProtocol {
    private let _isBusy = PassthroughSubject<Bool, Never>()
    lazy private(set) var isBusy = _isBusy.eraseToAnyPublisher()

    private static let serviceBaseURL = URL(string: "https://8kq890lk50.execute-api.us-east-1.amazonaws.com/prd/accounts/0172bd23-c0da-47d0-a4e0-53a3ad40828f")!
    private let session = URLSession.shared

    func getAccount() async -> Account? {
        await getData("balance")
    }
    
    func getTransactions() async -> MoneyTransaction? {
        await getData("transactions")
    }
    
    func getAdvice(tIds: [String]) async -> Advice? {
        await getDataa(tIDS: tIds, "transactions")
    }

    private func getData<T: Codable>(_ endpoint: String) async -> T? {
        _isBusy.send(true)
        defer { _isBusy.send(false) }

        let dataURL = Self.serviceBaseURL.appending(component: endpoint)

        do {
            let (data, _) = try await session.data(from: dataURL)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Error getting data from \(endpoint): \(error)")
        }
        return nil
    }
    
    private func getDataa<T: Codable>(tIDS: [String], _ endpoint: String) async -> T? {
        _isBusy.send(true)
        defer { _isBusy.send(false) }

        let dataURL = Self.serviceBaseURL.appending(component: endpoint).appending(component: "advice")
        var request = URLRequest(url: dataURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: ["transactionIds": tIDS])
            request.httpBody = jsonData
            let (data, response) = try await session.data(for: request)
            let obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            print(obj, response)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Error getting data from \(endpoint): \(error)")
        }
        return nil
    }
}
