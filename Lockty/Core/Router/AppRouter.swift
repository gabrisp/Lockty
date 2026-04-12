//
//  AppRouter.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@Observable
final class AppRouter {

    // MARK: - Auth
    var authState: AuthState = .loading
    var currentUser: LocalUser? = nil

    enum AuthState: Equatable {
        case loading
        case onboarding
        case authenticated
    }

    // MARK: - Routers
    var navigation = NavigationRouter()
    var sheet = SheetRouter()
    var settings = SettingsRouter()

    // MARK: - Tab activo
    var selectedTab: Tab = .modes

    // MARK: - Premium
    var premium: PremiumManager = .shared

    // MARK: - Tab enum
    enum Tab: String, CaseIterable, Hashable {
        case modes
        case stats
        // case social  // comentado hasta activar el social

        var label: String {
            switch self {
            case .modes: return "Modos"
            case .stats: return "Stats"
            // case .social: return "Social"
            }
        }
    }

    // MARK: - Navegación
    func editMode(_ mode: Mode) {
        sheet.push(.editMode(modeId: mode.id))
    }

    func openSettings(_ destination: SettingsDestination? = nil) {
        sheet.push(.settings)
        if let destination { settings.push(destination) }
    }

    func openAddFriend() {
        sheet.push(.addFriend)
    }

    // MARK: - Stats sheets
    func openStatFocusDetail(date: Date) { sheet.push(.statFocusDetail(date: date)) }
    func openStatTimeline(date: Date)    { sheet.push(.statTimeline(date: date)) }
    func openStatWeekChart()             { sheet.push(.statWeekChart) }
    func openStatMostResisted()          { sheet.push(.statMostResisted) }

    // MARK: - Premium
    func requirePro(_ feature: ProFeature, action: () -> Void) {
        premium.require(feature, router: self, action: action)
    }

    func openPremium(reason: ProFeature) {
        sheet.push(.premium(reason: reason))
    }
}
