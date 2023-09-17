//
//  AccountViewModelTests.swift
//  MoneyTests
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import XCTest
@testable import Money

final class AccountViewModelTests: XCTestCase {

    @MainActor func testFetchAccountData() async {
        let viewModel = AccountViewModel()

        XCTAssertEqual(viewModel.accountBalance, "-")
        XCTAssertFalse(viewModel.isBusy)

        await viewModel.fetchAccountData()

        XCTAssertNotEqual(viewModel.accountBalance, "-")
        XCTAssertFalse(viewModel.isBusy)
    }
}
