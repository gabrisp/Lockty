//
//  SheetRouter.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

/// Maneja el stack de sheets — permite sheets anidados
/// Cada sheet presenta el siguiente del stack
@Observable
final class SheetRouter {
    var stack: [Sheet] = []

    /// Sheet actualmente visible — el último del stack
    var current: Sheet? { stack.last }

    /// Añade un sheet encima del actual
    func push(_ sheet: Sheet) {
        stack.append(sheet)
    }

    /// Cierra el sheet actual
    func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
    }

    /// Cierra todos los sheets
    func popToRoot() {
        stack.removeAll()
    }

    /// Reemplaza el sheet actual por otro
    func replace(_ sheet: Sheet) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1] = sheet
    }

    /// Devuelve el sheet siguiente al dado — usado por SheetWrapper para anidar
    func nextSheet(after sheet: Sheet) -> Sheet? {
        guard let index = stack.firstIndex(of: sheet),
              index + 1 < stack.count else { return nil }
        return stack[index + 1]
    }
}
