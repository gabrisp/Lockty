//
//  Navigation.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

enum NavigationDestination: Hashable {
    /// Pantalla de detalle de un modo — overview, stats, rules
    case modeDetail(modeId: UUID)

    /// Pantalla de detalle de una sesión individual
    case sessionDetail(sessionId: UUID)

    /// Pantalla de todas las sesiones — filtrable por modo
    case allSessions(modeId: UUID?)
}

/// Maneja el stack de navegación push (NavigationStack)
/// Una instancia por tab
@Observable
final class NavigationRouter {
    var path = NavigationPath()

    /// Navega a una pantalla nueva
    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }

    /// Vuelve a la pantalla anterior
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Vuelve al root del tab
    func popToRoot() {
        path.removeLast(path.count)
    }
}
