//
//  ModePill.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ModePill: View {
    let mode: Mode
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text(mode.name)
                .font(Typography.caption(weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, BaseTheme.Spacing.md)
                .padding(.vertical, BaseTheme.Spacing.xs + 2)
                .clipShape(Capsule())
                .locktyGlass(action == nil ? .regular.tint(Color(hex: mode.colorHex)) : .regular.tint(Color(hex: mode.colorHex)).interactive())
                .tappable()
        }
        .buttonStyle(NoFlashButtonStyle())
    }
}

#Preview {
    HStack(spacing: BaseTheme.Spacing.sm) {
        ModePill(mode: .preview)
        ModePill(mode: Mode(
            id: UUID(), name: "Study", iconName: "book.fill",
            colorHex: "#E3ECF8", state: ModeState.inactive.rawValue, createdAt: .now
        ), action: {print("gol")})
    }
    .padding()
    .background(Color.pageBackground)
}
