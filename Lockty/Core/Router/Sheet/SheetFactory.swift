//
//  SheetFactoru.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

/// Factory que devuelve la view correcta para cada sheet
/// Único sitio donde se mapean sheets a views
struct SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .editMode(let id):
            Text("Edit Mode \(id)")
        case .editRule(let id):
            Text("Edit Rule \(id)")
        case .editGuard(let id):
            Text("Edit Guard \(id)")
        case .filterStats:
            Text("Filter Stats")
        case .sessionDetail(let id):
            Text("Session Detail \(id)")
        case .friendDetail(let id):
            Text("Friend Detail \(id)")
        case .streakHeatmap:
            Text("Streak Heatmap")
        case .modeFlow(let id):
            Text("Mode Flow \(id)")
        case .premium(let reason):
            Text("Premium - \(reason.title)")
        case .addFriend:
            Text("Add Friend")
        case .settings:
            Text("Settings")
        }
    }
}
