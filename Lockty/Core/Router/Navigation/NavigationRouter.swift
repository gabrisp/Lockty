//
//  NavigationRouter.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
/// Maneja el stack de navegación push (NavigationStack)
/// Una instancia por tab
@Observable
final class NavigationRouter {
    var path = NavigationPath()

    /// Navega a una pantalla nueva
    func push(_ destination: NavigationDestination) {
        withAnimation(.easeInOut(duration: 0.3)) {
            path.append(destination)
        }
    }

    /// Vuelve a la pantalla anterior
    func pop() {
        guard !path.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            path.removeLast()
        }
    }

    /// Vuelve al root del tab
    func popToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            path.removeLast(path.count)
        }
    }
}
