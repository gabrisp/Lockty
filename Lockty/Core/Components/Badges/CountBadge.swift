//
//  CountBadge.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct CountBadge: View {
    let count: Int
    var style: Style = .red

    enum Style {
        case red, blue, green, orange

        var background: Color {
            switch self {
            case .red:    return .red
            case .blue:   return .blue
            case .green:  return .green
            case .orange: return .orange
            }
        }
    }

    var body: some View {
        Text("\(count)")
            .font(Typography.caption(weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(style.background)
            .clipShape(Circle())
    }
}

#Preview {
    HStack(spacing: BaseTheme.Spacing.md) {
        CountBadge(count: 2, style: .red)
        CountBadge(count: 3, style: .blue)
        CountBadge(count: 5, style: .green)
        CountBadge(count: 1, style: .orange)
    }
    .padding()
    .background(Color.pageBackground)
}
