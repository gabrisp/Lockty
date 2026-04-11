//
//  ProManager.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import RevenueCat

@Observable
final class PremiumManager {
    static let shared = PremiumManager()

    var isPro: Bool = false

    func refresh() async {
        guard let info = try? await Purchases.shared.customerInfo() else { return }
        await MainActor.run {
            isPro = info.entitlements["Lockty Unlimited"]?.isActive == true
        }
    }

    // MARK: - Feature gates
    func isUnlocked(_ feature: ProFeature) -> Bool {
        guard !isPro else { return true }
        return freeFeatures.contains(feature)
    }

    func require(_ feature: ProFeature, router: AppRouter, action: () -> Void) {
        if isUnlocked(feature) {
            action()
        } else {
            router.sheet.push(.premium(reason: feature))
        }
    }

    // MARK: - Límites free
    var maxModesFree: Int { 1 }

    func canCreateMode(currentCount: Int) -> Bool {
        isPro || currentCount < maxModesFree
    }

    // MARK: - Features disponibles en free
    private var freeFeatures: Set<ProFeature> {
        [.cloudSync]  // cloudSync gratis en fase 1, ajustar cuando llegue StoreKit
    }
}
