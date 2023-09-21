//
//  MoneyPeristanceTests.swift
//  MoneyTests
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import XCTest
import Combine

@testable import Money

final class MoneyPeristanceTests: XCTestCase {
    
    var SUT = MoneyPersistenceService()

    override func tearDownWithError() throws {
        SUT.deleteAccount()
        SUT.deleteTransactions()
    }

    func testSaveAndGetAccount() async throws {
       
        SUT.saveAccount(account: Account(balance: 10, currency: "USD"))
        
        let account = await SUT.getAccount()
        let unwrappedAccount = try account.get()

        XCTAssertEqual(unwrappedAccount.balance, 10)
        XCTAssertEqual(unwrappedAccount.currency, "USD")
    }
    
    func testSaveAndGetTransaction() async throws {
       
        let transactionsToTest = [TransactionDetail(amount: 10, currency: "USD", id: "123", title: "Test Transaction")]
        SUT.saveTransactions(transactions: MoneyTransaction(total: 1, count: 1, last: true, data: transactionsToTest))
        
        let transaction = await SUT.getTransactions()
        let unwrappedTransaction = try transaction.get()

        XCTAssertEqual(unwrappedTransaction.total, 1)
        XCTAssertEqual(unwrappedTransaction.data, transactionsToTest)
    }

}
