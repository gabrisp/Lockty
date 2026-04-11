//
//  SheetFactory.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import RevenueCatUI

struct SheetFactory {
    static func view(for sheet: Sheet, user: LocalUser?) -> AnyView {
        switch sheet {
        case .editMode(let id):
            AnyView(Text("Edit Mode \(id)"))
        case .editRule(let id):
            AnyView(Text("Edit Rule \(id)"))
        case .editGuard(let id):
            AnyView(Text("Edit Guard \(id)"))
        case .filterStats:
            AnyView(Text("Filter Stats"))
        case .sessionDetail(let id):
            AnyView(Text("Session Detail \(id)"))
        case .friendDetail(let id):
            AnyView(Text("Friend Detail \(id)"))
        case .streakHeatmap:
            AnyView(Text("Streak Heatmap"))
        case .modeFlow(let id):
            AnyView(Text("Mode Flow \(id)"))
        case .premium:
            AnyView(
                PaywallView(displayCloseButton: true)
                    .onPurchaseCompleted { _ in
                        Task { await PremiumManager.shared.refresh() }
                    }
                    .onRestoreCompleted { _ in
                        Task { await PremiumManager.shared.refresh() }
                    }
            )
        case .addFriend:
            AnyView(Text("Add Friend"))
        case .settings:
            if let user {
                AnyView(SettingsView(user: user))
            } else {
                AnyView(SettingsView(user: .preview))
            }
        case .statFocusDetail:
            AnyView(Text("Focus Detail").font(Typography.title()))
        case .statTimeline:
            AnyView(Text("Timeline").font(Typography.title()))
        case .statWeekChart:
            AnyView(Text("Week Chart").font(Typography.title()))
        case .statMostResisted:
            AnyView(Text("Most Resisted").font(Typography.title()))
        }
    }
}
