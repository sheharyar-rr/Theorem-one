//
//  MoneyServiceTests.swift
//  MoneyTests
//
//  Created by Philippe Boudreau on 2023-08-17.
//

import Foundation
import Combine

import XCTest
@testable import Money

final class MoneyServiceTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testBusyState() async {
        let service = MoneyApiService()

        var didBecomeBusy = false
        var finalState = false
        service.isBusy
            .sink {
                didBecomeBusy = didBecomeBusy || $0
                finalState = $0
            }
            .store(in: &cancellables)

        let _ = await service.getAccount()

        XCTAssertTrue(didBecomeBusy)
        XCTAssertFalse(finalState)
    }

    func testGetAccount() async throws {
        let service = MoneyApiService()

        let result = await service.getAccount()
        let unwrappedAccount = try result.get()

        XCTAssertEqual(unwrappedAccount.balance, 12312.01)
        XCTAssertEqual(unwrappedAccount.currency, "USD")
    }
    
    func testGetTransactions() async throws {
        let service = MoneyApiService()
        
        let result = await service.getTransactions()
        let unwrappedTransactions = try result.get()
        
        XCTAssertGreaterThan(unwrappedTransactions.count, 0, "Count greater than 0")
    }
    
    func testGetAdvice() async throws {
        // Setup
        let service = MoneyApiService()
        
        let result = await service.getTransactions()
        let unwrappedTransactions = try result.get()
        let transactionIds = unwrappedTransactions.data.map { $0.id }
        
        let advice = await service.getAdvice(transactionIds: transactionIds)
        
        XCTAssertNotNil(advice)
    }
}
