//
//  AdviceView.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import SwiftUI
import StoreKit

/// A view displaying financial advice and an in-app purchase option.
struct AdviceView: View {
    
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased: Bool = false
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            
            isPurchased ? Theme.Colors.successBackground : Theme.Colors.infoBackground
            
            HStack {
                icon
                
                adviceText
                
                inAppPurchaseButton
            }
            .padding(.vertical)
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
        .padding(.horizontal)
        .onChange(of: storeKit.purchasedProducts) { product in
            Task {
                if let inAppPurchase = storeKit.storeProducts.first {
                    isPurchased = (try? await storeKit.isPurchased(inAppPurchase)) ?? false
                }
            }
        }
    }
    
    /// Icon displayed based on whether the advice is purchased or not.
    var icon: some View {
        Group {
            if !isPurchased {
                Image(systemName: Theme.icons.infoIconName)
                    .foregroundColor(Theme.Colors.infoIconColor)
            } else {
                Image(systemName: Theme.icons.checkmarkIconName)
                    .foregroundColor(Theme.Colors.checkmarkIconColor)
            }
        }
        .padding(.horizontal)
        .font(.title)
    }
    
    /// Text containing advice information.
    var adviceText: some View {
        VStack(alignment: .leading) {
            Text(isPurchased ? viewModel.advice.title : Theme.Strings.defaultAdviceTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(isPurchased ? viewModel.advice.description : Theme.Strings.defaultAdviceDescription)
                .font(.footnote)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                .padding(.trailing)
            
            if !isPurchased {
                inAppPurchaseRestoreButton
            }
        }
    }
    
    /// Button for making an in-app purchase.
    var inAppPurchaseButton: some View {
        Group {
            if let inAppPurchase = storeKit.storeProducts.first, !isPurchased {
                Button(inAppPurchase.displayPrice) {
                    Task {
                        _ = try await storeKit.purchase(inAppPurchase)
                    }
                }
                .padding(.trailing)
            }
        }
    }
    
    /// Button for restoring in-app purchases.
    var inAppPurchaseRestoreButton: some View {
        Button(Theme.Strings.restorePurchasesButtonTitle) {
            Task {
                // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                // Call this function only in response to an explicit user action, such as tapping a button.
                try? await AppStore.sync()
            }
        }
        .padding(.top, 5)
        .font(.subheadline)
    }
}

#Preview {
    AdviceView(viewModel: AccountViewModel())
}
