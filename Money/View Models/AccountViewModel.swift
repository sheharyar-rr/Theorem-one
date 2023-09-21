//
//  AccountViewModel.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation
import Combine

/// A view model responsible for managing account-related data and interactions.

@MainActor
class AccountViewModel: ObservableObject {
    @Published private(set) var isBusy = false
    @Published private(set) var accountBalance: String = "-"
    @Published private(set) var transactions: [TransactionDetail] = []
    @Published private(set) var advice: Advice = .init(title: "", description: "")
    @Published private(set) var error = ""
    
    private let moneyService: MoneyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes an `AccountViewModel` with an optional money service.
    /// - Parameter moneyService: The service responsible for money-related interactions.
    init(moneyService: MoneyServiceProtocol = MoneyService()) {
        self.moneyService = moneyService
        
        self.moneyService.isBusy
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBusy in
                self?.isBusy = isBusy
            }
            .store(in: &cancellables)
    }
    
    /// Fetches account-related data asynchronously.
    func fetchAccountData() async {
        let result = await moneyService.getAccount()
        switch result {
        case .success(let account):
            accountBalance = account.formattedBalance()
        case .failure(let failure):
            error = failure.localizedDescription
        }
        
        let transactionsResult = await moneyService.getTransactions()
        switch transactionsResult {
        case .success(let transactions):
            self.transactions = transactions.data
            await fetchAdvice(ids: transactions.transactionIds())
        case .failure(let failure):
            self.error = failure.localizedDescription
        }
    }
    
    /// Fetches advice based on a list of transaction IDs.
    /// - Parameter ids: The list of transaction IDs for which advice is requested.
    func fetchAdvice(ids: [String]) async {
        let adviceResult = await moneyService.getAdvice(transactionIds: ids)
        switch adviceResult {
        case .success(let advice):
            self.advice = advice
        case .failure(let failure):
            self.error = failure.localizedDescription
        }
    }
}
