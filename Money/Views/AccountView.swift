//
//  AccountView.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import SwiftUI

/// A view displaying the user's account information.
struct AccountView: View {
    @EnvironmentObject private var launchScreenStateManager: LaunchScreenStateManager
    @StateObject private var viewModel = AccountViewModel()

    var body: some View {
        VStack {
            accountBalance
            
            transactions
                .animation(.default, value: viewModel.isBusy)
            
            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundStyle(Theme.Colors.errorText)
                    .font(.callout)
            }
            
            // Display financial advice to the user.
            AdviceView(viewModel: viewModel)
                .animation(.default, value: viewModel.isBusy)
                
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .task {
            // Workaround to overcome the limitations of SwiftUI's launch screen feature.
            try? await Task.sleep(for: Duration.seconds(1))
            launchScreenStateManager.dismissLaunchScreen()

            // Fetch account data when the view appears.
            Task {
                await viewModel.fetchAccountData()
            }
        }
    }
    
    /// A view displaying the account balance.
    var accountBalance: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Theme.Strings.defaultAccountBalanceTitle)
                    .font(.subheadline)
                    .bold()

                HStack {
                    if viewModel.isBusy {
                        ProgressView()
                    } else {
                        Text(viewModel.accountBalance)
                            .font(.largeTitle)
                            .bold()
                    }
                }
                .animation(.default, value: viewModel.isBusy)
            }
            Spacer()
        }
        .padding([.leading, .trailing])
    }
    
    /// A list view displaying the user's financial transactions.
    var transactions: some View {
            List(viewModel.transactions) { transaction in
                HStack {
                    Text(transaction.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(transaction.formattedAmount())
                        .fontWeight(.light)
                }
                .accessibilityIdentifier("listElement")
            }
            .accessibilityIdentifier("list")
            .listStyle(.plain)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(LaunchScreenStateManager())
    }
}
