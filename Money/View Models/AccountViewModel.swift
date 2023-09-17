//
//  AccountViewModel.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import Foundation
import Combine

@MainActor class AccountViewModel: ObservableObject {
    @Published private(set) var isBusy = false
    @Published private(set) var accountBalance: String = "-"

    private let moneyService = MoneyService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        moneyService.isBusy
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBusy in
                self?.isBusy = isBusy
            }
            .store(in: &cancellables)
    }

    func fetchAccountData() async {
        guard let account = await moneyService.getAccount() else { return }
        accountBalance = account.balance.formatted(.currency(code: account.currency))
    }
}
