//
//  MoneyApiService.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import Combine

class MoneyApiService: MoneyServiceProtocol {
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
    
    func getAdvice(transactionIds: [String]) async -> Advice? {
        await postData(httpBody: ["transactionIds": transactionIds], "advice")
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
    
    private func postData<T: Codable>(httpBody: [String: [String]], _ endpoint: String) async -> T? {
        _isBusy.send(true)
        defer { _isBusy.send(false) }

        let dataURL = Self.serviceBaseURL.appending(component: "transactions").appending(component: endpoint)
        var request = URLRequest(url: dataURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: httpBody)
            request.httpBody = jsonData
            let (data, _) = try await session.data(for: request)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Error getting data from \(endpoint): \(error)")
        }
        return nil
    }
}
