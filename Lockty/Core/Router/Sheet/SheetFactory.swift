//
//  SheetFactory.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct SheetFactory {
    static func view(for sheet: Sheet) -> AnyView {
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
        case .premium(let reason):
            AnyView(Text("Premium - \(reason.title)"))
        case .addFriend:
            AnyView(Text("Add Friend"))
        case .settings:
            AnyView(Text("Settings"))
        }
    }
}
