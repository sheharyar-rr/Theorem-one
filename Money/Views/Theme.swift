//
//  Theme.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-21.
//

import SwiftUI

struct Theme {
    struct Colors {
        static let primary = Color.blue
        static let errorText = Color.red
        
        static let infoBackground = Color.blue.opacity(0.2)
        static let successBackground = Color.green.opacity(0.2)
        
        static let infoIconColor = Color.blue
        
        static let checkmarkIconColor = Color.green
    }
    
    struct icons {
        static let infoIconName = "info.circle.fill"
        static let checkmarkIconName = "checkmark.circle.fill"
    }
    
    struct Strings {
        static let defaultAccountBalanceTitle = "Account Balance"
        
        static let defaultAdviceTitle = "Go Pro!"
        static let defaultAdviceDescription = "Get insight on how to save money using premium advice"
        
        static let restorePurchasesButtonTitle = "Restore Purchases"
    }
}
