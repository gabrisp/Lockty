//
//  TransitionBadge.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct TransitionBadge: View {
    let transition: Transition

    var body: some View {
        Text(label)
            .font(Typography.micro())
            .textCase(.uppercase)
            .tracking(0.4)
            .foregroundStyle(fgColor)
            .padding(BaseTheme.Spacing.sm)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.sm))
    }

    private var label: String {
        switch transition {
        case .activate:   return "Activate"
        case .startBreak: return "Break"
        case .stop:       return "Stop"
        }
    }

    private var bgColor: Color {
        switch transition {
        case .activate:   return Color.green.opacity(0.15)
        case .startBreak: return Color.orange.opacity(0.15)
        case .stop: return Color.red.opacity(0.12)
        }
    }

    private var fgColor: Color {
        switch transition {
        case .activate:   return Color(hex: "#1B6B35")
        case .startBreak: return Color(hex: "#92620A")
        case .stop:       return Color(hex: "#8A1A1A")
        }
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.md) {
        HStack {
            TransitionBadge(transition: .activate)
            TransitionBadge(transition: .startBreak)
            TransitionBadge(transition: .stop)
        }
    }
    .padding()
    .background(Color.pageBackground)
}
