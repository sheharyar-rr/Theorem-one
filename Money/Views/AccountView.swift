//
//  AccountView.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var launchScreenStateManager: LaunchScreenStateManager
    @StateObject private var viewModel = AccountViewModel()

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Account Balance")
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
            
            VStack {
                List(viewModel.transactions) { transaction in
                    HStack {
                        Text(transaction.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(transaction.formattedAmount())
                    }
                }
                .listStyle(.plain)
            }
            
            AdviceView(type: .advice, advice: viewModel.advice)
            Spacer()
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .padding(.top)
        .task {
            // Workaround to overcome the limitations of SwiftUI's launch screen feature.
            try? await Task.sleep(for: Duration.seconds(1))
            launchScreenStateManager.dismissLaunchScreen()

            Task {
                await viewModel.fetchAccountData()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(LaunchScreenStateManager())
    }
}
