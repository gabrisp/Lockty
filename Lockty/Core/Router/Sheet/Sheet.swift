//
//  Sheet.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

enum Sheet: Identifiable, Hashable {
    /// Sheet de edición de un modo — nombre, icono, apps, rules, schedule
    case editMode(modeId: UUID)

    /// Sheet de edición de una rule individual — condition, guards, onGuardFail
    case editRule(ruleId: UUID)

    /// Sheet de edición de un guard individual — tipo, config
    case editGuard(guardId: UUID)

    /// Sheet de filtros de Stats — período, modos, apps
    case filterStats

    /// Sheet de detalle de una sesión — duración, breaks, apps intentadas
    case sessionDetail(sessionId: UUID)

    /// Sheet de detalle de un amigo — permisos por modo, actividad reciente
    case friendDetail(userId: UUID)

    /// Sheet del heatmap de racha — calendario de actividad
    case streakHeatmap

    /// Sheet del flow diagram de un modo — diagrama visual de rules y transiciones
    case modeFlow(modeId: UUID)

    /// Sheet de premium contextual — copy e icono específico por feature bloqueada
    case premium(reason: ProFeature)

    /// Sheet para añadir un amigo por username
    case addFriend

    /// Sheet de settings — perfil, social, devices, legal
    case settings

    var id: String { "\(self)" }
}
