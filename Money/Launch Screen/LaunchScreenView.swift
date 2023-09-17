//
//  LaunchScreenView.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenStateManager: LaunchScreenStateManager

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Text("Formula\nMoney")
                        .foregroundColor(.white)
                        .font(.system(size: 48))
                    Spacer()
                }
                .padding(.leading, 36)
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(LaunchScreenStateManager())
    }
}
