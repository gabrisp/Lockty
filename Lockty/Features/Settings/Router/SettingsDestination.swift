//
//  SettingsDestination.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import Foundation

enum SettingsDestination: Hashable {
    case editDisplayName
    case editUsername
    case editEmail
    case devices
    case deviceDetail(id: UUID)
    case tabs
    case permissions
    case notifications
}
