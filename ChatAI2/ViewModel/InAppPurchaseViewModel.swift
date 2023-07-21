//
//  InAppPurchaseViewModel.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 14/7/23.
//

import Foundation
import RevenueCat

class InAppPurchaseViewModel: ObservableObject {
    static let shared = InAppPurchaseViewModel()

    private init() {
        getOfferings()
        Task {
            await checkIsActive()
        }
    }

    @Published var currentOfferings: Offering?
    @Published var isActive = false
    @Published var isPurchasing = false
    @Published var purchaseSuccess = false
    @Published var message = ""
    @Published var showAlert = false

    private func getOfferings() {
        Purchases.shared.getOfferings { offerings, err in
            if let err = err {
                print(err)
            }
            if let offering = offerings?.current {
                self.currentOfferings = offering
            }
        }
    }

    private func checkIsActive() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                isActive = customerInfo.entitlements.all["Pro"]?.isActive == true
                print("isActiveT: ", isActive)
            }
        } catch {
            print("IsActive: \(error)")
        }
    }

    func purchase(pkg: Package) {
        isPurchasing = true
        Purchases.shared.purchase(package: pkg) { (_, customerInfo, _, _) in
            if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                self.isActive = true
                self.purchaseSuccess = true
            }
            self.isPurchasing = false
        }
    }

    func restore() {
        isPurchasing = true
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                self.message = error.localizedDescription
                self.showAlert = true
            } else if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                self.isActive = true
                self.purchaseSuccess = true
            } else {
                self.message = "Restore was not successful!"
                self.showAlert = true
            }
            self.isPurchasing = false
        }
    }
}
