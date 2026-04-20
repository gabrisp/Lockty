//
//  Color+Brightness.swift
//  Lockty
//

import SwiftUI

extension Color {
    var isDark: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        return (0.299 * r + 0.587 * g + 0.114 * b) < 0.5
    }

    var contrastingLabel: Color {
        isDark ? .white : .black
    }
}
