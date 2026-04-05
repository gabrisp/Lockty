//
//  SettingsRouter.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

@Observable
final class SettingsRouter {
    var path = NavigationPath()

    func push(_ destination: SettingsDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
