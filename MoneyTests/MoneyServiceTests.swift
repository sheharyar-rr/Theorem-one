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
        let service = MoneyService()

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
        let service = MoneyService()

        let account = await service.getAccount()
        let unwrappedAccount = try XCTUnwrap(account)

        XCTAssertEqual(unwrappedAccount.balance, 12312.01)
        XCTAssertEqual(unwrappedAccount.currency, "USD")
    }
}
