//
//  StoreKitManager.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import StoreKit

/// An enumeration representing possible errors related to the StoreKitManager.
public enum StoreError: Error {
    case failedVerification
}

/// A manager class responsible for handling in-app purchases and managing product data.
class StoreKitManager: ObservableObject {
    
    /// An array of available products for in-app purchases.
    @Published var storeProducts: [Product] = []
    
    /// An array of purchased products by the user.
    @Published var purchasedProducts: [Product] = []
    
    /// A task responsible for listening to in-app purchase transaction updates.
    var updateListenerTask: Task<Void, Error>? = nil
    
    /// A dictionary representing product identifiers and their corresponding product names.
    private let productDict: [String: String]
    
    /// Initializes a new instance of StoreKitManager.
    init() {
        // Check the path for the plist
        if let plistPath = Bundle.main.path(forResource: "inAppPlist", ofType: "plist"),
           let plist = FileManager.default.contents(atPath: plistPath) {
            productDict = (try? PropertyListSerialization.propertyList(from: plist,
                                                                       format: nil) as? [String : String]) ?? [:]
        } else {
            productDict = [:]
        }
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    /// Deinitializes the StoreKitManager instance.
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Listens for in-app purchase transactions and handles their verification and processing.
    /// - Returns: A detached task responsible for transaction monitoring.
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Transaction is verified, deliver the content to the user
                    await self.updateCustomerProductStatus()
                    
                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    // Storekit has a transaction that fails verification, don't delvier content to the user
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    /// Requests product information for in-app purchases in the background.
    @MainActor
    func requestProducts() async {
        do {
            storeProducts = try await Product.products(for: productDict.values)
        } catch {
            print("Failed - error retrieving products \(error)")
        }
    }
    
    /// Verifies the result of a transaction and throws an error if verification fails.
    /// - Parameter result: The verification result to be checked.
    /// - Returns: The verified result if successful.
    /// - Throws: A `StoreError.failedVerification` error if verification fails.
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
    
    /// Updates the status of purchased products for the current customer.
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedCourses: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let course = storeProducts.first(where: { $0.id == transaction.productID}) {
                    purchasedCourses.append(course)
                }
                
            } catch {
                print("Transaction failed verification")
            }
            
            self.purchasedProducts = purchasedCourses
        }
    }
    
    /// Initiates the purchase of a specific product.
    /// - Parameter product: The product to be purchased.
    /// - Returns: The transaction associated with the purchase, or `nil` if the purchase fails.
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        // Check the results
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
        
    }
    
    /// Checks if a specific product has been purchased by the user.
    /// - Parameter product: The product to be checked for purchase status.
    /// - Returns: `true` if the product is purchased; otherwise, `false`.
    func isPurchased(_ product: Product) async throws -> Bool {
        return purchasedProducts.contains(product)
    }
    
}

