//
//  AppRouter.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@Observable
final class AppRouter {

    // MARK: - Routers
    var navigation = NavigationRouter()
    var sheet = SheetRouter()

    // MARK: - Tab activo
    var selectedTab: Tab = .modes

    // MARK: - Premium
    var premium: PremiumManager = .shared

    // MARK: - Tab enum
    enum Tab: String, CaseIterable, Hashable {
        case modes
        case stats
        case social

        var label: String {
            switch self {
            case .modes:  return "Modes"
            case .stats:  return "Stats"
            case .social: return "Social"
            }
        }
    }

    // MARK: - Navegación
    func openMode(_ id: UUID) {
        navigation.push(.modeDetail(modeId: id))
    }

    func editMode(_ id: UUID) {
        navigation.push(.modeDetail(modeId: id))
        sheet.push(.editMode(modeId: id))
    }

    func openSettings() {
        sheet.push(.settings)
    }

    func openAddFriend() {
        sheet.push(.addFriend)
    }

    // MARK: - Premium
    func requirePro(_ feature: ProFeature, action: () -> Void) {
        premium.require(feature, router: self, action: action)
    }

    func openPremium(reason: ProFeature) {
        sheet.push(.premium(reason: reason))
    }
}
