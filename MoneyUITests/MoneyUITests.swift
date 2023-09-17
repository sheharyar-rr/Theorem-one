//
//  MoneyUITests.swift
//  MoneyUITests
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import XCTest

final class MoneyUITests: XCTestCase {
    func testInitialState() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Account Balance"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["$12,312.01"].exists)
    }
}
