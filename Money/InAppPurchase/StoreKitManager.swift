//
//  StoreKitManager.swift
//  Money
//
//  Created by Sheharyar Irfan on 2023-09-19.
//

import Foundation
import StoreKit

public enum StoreError: Error {
    case failedVerification
}

class StoreKitManager: ObservableObject {
    
    @Published var storeProducts: [Product] = []
    @Published var purchasedProducts : [Product] = []
    
    var updateListenerTask: Task<Void, Error>? = nil
    private let productDict: [String : String]
    
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
    
    deinit {
        updateListenerTask?.cancel()
    }
    
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
    
    // Request the products in the background
    @MainActor
    func requestProducts() async {
        do {
            storeProducts = try await Product.products(for: productDict.values)
        } catch {
            print("Failed - error retrieving products \(error)")
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let signedType):
            return signedType
        }
    }
    
    // Update the customers products
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
    
    func isPurchased(_ product: Product) async throws -> Bool {
        return purchasedProducts.contains(product)
    }
    
}

