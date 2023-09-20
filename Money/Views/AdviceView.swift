//
//  AdviceView.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-18.
//

import SwiftUI
import StoreKit

struct AdviceView: View {
    
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased: Bool = false
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        ZStack {
            
            isPurchased ? Color.green.opacity(0.2) : Color.blue.opacity(0.2)
            
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
    
    var icon: some View {
        Group {
            if !isPurchased {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
        .font(.title)
    }
    
    var adviceText: some View {
        VStack(alignment: .leading) {
            Text(isPurchased ? viewModel.advice.title : "Go Pro!")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(isPurchased ? viewModel.advice.description : "Get insight on how to save money using premium advice")
                .font(.footnote)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                .padding(.trailing
                )
            
            if !isPurchased {
                inAppPurchaseRestoreButton
            }
        }
    }
    
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
    
    var inAppPurchaseRestoreButton: some View {
        Button("Restore Purchases") {
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
