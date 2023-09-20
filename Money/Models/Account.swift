//
//  Account.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation

struct Account: Codable {
    var balance: Double
    var currency: String

    enum CodingKeys: String, CodingKey {
        case balance = "amount"
        case currency
    }
}

extension Account {
    func formattedBalance() -> String {
        return balance.formatted(.currency(code: currency))
    }
}
