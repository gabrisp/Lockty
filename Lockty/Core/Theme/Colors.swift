//
//  Colors.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

extension Color {

    // MARK: - Hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    // MARK: - Semantic backgrounds (grouped hierarchy)
    // Página:        secondarySystemGroupedBackground  (blanco en light)
    // Card outer:    systemGroupedBackground           (gris en light)
    // Card inner:    secondarySystemGroupedBackground  (blanco en light)
    static var pageBackground: Color      { Color(.secondarySystemGroupedBackground) }
    static var cardBackground: Color      { Color(.systemGroupedBackground) }
    static var innerBackground: Color     { Color(.secondarySystemGroupedBackground) }

    // MARK: - Avatar gradient
    static func avatarGradient(for name: String) -> LinearGradient {
        let palettes: [[Color]] = [
            [Color(hex: "#4facfe"), Color(hex: "#00f2fe")],
            [Color(hex: "#667eea"), Color(hex: "#764ba2")],
            [Color(hex: "#f093fb"), Color(hex: "#f5576c")],
            [Color(hex: "#FFB347"), Color(hex: "#FF6B6B")],
            [Color(hex: "#43e97b"), Color(hex: "#38f9d7")],
            [Color(hex: "#fa709a"), Color(hex: "#fee140")],
        ]
        let index = abs(name.hashValue) % palettes.count
        return LinearGradient(
            colors: palettes[index],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
