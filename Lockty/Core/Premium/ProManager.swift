//
//  ProManager.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@Observable
final class PremiumManager {
    static let shared = PremiumManager()

    var isPro: Bool = false  // Fase 1: siempre false. Fase 3: conectar con StoreKit

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
    var maxModesFree: Int { 2 }

    func canCreateMode(currentCount: Int) -> Bool {
        isPro || currentCount < maxModesFree
    }

    // MARK: - Features disponibles en free
    private var freeFeatures: Set<ProFeature> {
        [.cloudSync]  // cloudSync gratis en fase 1, ajustar cuando llegue StoreKit
    }
}
