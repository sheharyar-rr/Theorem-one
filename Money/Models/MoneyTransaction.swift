//
//  Transaction.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import Foundation

struct MoneyTransaction: Codable {
    var total: Double
    var count: Int
    var last: Bool
    var data: [TransactionDetail]
}

struct TransactionDetail: Codable, Identifiable, Equatable {
    var amount: Double
    var currency: String
    var id: String
    var title: String
    
    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
}
