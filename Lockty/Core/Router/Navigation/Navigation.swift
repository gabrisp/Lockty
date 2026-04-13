//
//  Navigation.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

enum NavigationDestination: Hashable {
    /// Pantalla de detalle de una sesión individual
    case sessionDetail(sessionId: UUID)

    /// Pantalla de todas las sesiones — filtrable por modo
    case allSessions(modeId: UUID?)

    /// Pantalla de detalle de un modo
    case modeDetail(mode: Mode)

    /// Pantalla de creación de un modo nuevo
    case createMode
}

