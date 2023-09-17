//
//  LaunchScreenStateManager.swift
//  Money
//
//  Created by Philippe Boudreau on 2023-08-15.
//
//  Simple state manager to overcome the limitations of SwiftUI's launch screen feature.
//

import Foundation

enum LaunchScreenState {
    case shown
    case hidden
}

final class LaunchScreenStateManager: ObservableObject {
    @MainActor @Published private(set) var state: LaunchScreenState = .shown

    @MainActor func dismissLaunchScreen() {
        state = .hidden
    }
}
