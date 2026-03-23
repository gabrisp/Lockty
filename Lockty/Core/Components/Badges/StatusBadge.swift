//
//  StatusBadge.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct StatusBadge: View {
    let state: ModeState

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(label)
                .font(Typography.micro())
                .textCase(.uppercase)
                .tracking(0.3)
                .foregroundStyle(dotColor)
        }
        .padding(BaseTheme.Spacing.sm)
        .background(bgColor)
        .clipShape(Capsule())
    }

    private var dotColor: Color {
        switch state {
        case .active:   return .green
        case .onBreak:  return .orange
        case .inactive: return Color(.tertiaryLabel)
        }
    }

    private var bgColor: Color {
        switch state {
        case .active:   return Color.green.opacity(0.12)
        case .onBreak:  return Color.orange.opacity(0.12)
        case .inactive: return Color(.tertiarySystemFill)
        }
    }

    private var label: String {
        switch state {
        case .active:   return "Live"
        case .onBreak:  return "Break"
        case .inactive: return "Inactive"
        }
    }
}

#Preview {
    HStack(spacing: BaseTheme.Spacing.md) {
        StatusBadge(state: .active)
        StatusBadge(state: .onBreak)
        StatusBadge(state: .inactive)
    }
    .padding()
    .background(Color.pageBackground)
}
