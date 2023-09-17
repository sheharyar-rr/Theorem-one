//
//  MoneyApp.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//

import SwiftUI

@main
struct MoneyApp: App {
    // Workaround to overcome the limitations of SwiftUI's launch screen feature.
    @StateObject private var launchScreenStateManager = LaunchScreenStateManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AccountView()

                if launchScreenStateManager.state != .hidden {
                    LaunchScreenView()
                }
            }
            .animation(.default, value: launchScreenStateManager.state)
            .environmentObject(launchScreenStateManager)
        }
    }
}
