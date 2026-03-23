//
//  DeltaBadge.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct DeltaBadge: View {
    let text: String
    var isPositive: Bool = true

    var body: some View {
        Text(text)
            .font(Typography.caption(weight: .semibold))
            .foregroundStyle(isPositive ? Color(hex: "#1B6B35") : Color(hex: "#8A1A1A"))
            .padding(.horizontal, BaseTheme.Spacing.md)
            .padding(.vertical, BaseTheme.Spacing.sm)
            .locktyGlass(
                .regular.tint(isPositive ? Color.green.opacity(0.3) : Color.red.opacity(0.3)),
                in: .capsule
            )
            .shadow(
                color: isPositive ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                radius: 8, x: 0, y: 0
            )
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.lg) {
        DeltaBadge(text: "↑ 34m vs yesterday", isPositive: true)
        DeltaBadge(text: "↓ 12m vs yesterday", isPositive: false)
    }
    .padding()
    .background(Color.pageBackground)
}
