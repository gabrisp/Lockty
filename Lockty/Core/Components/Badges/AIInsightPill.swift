//
//  AIInsightPill.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct AIInsightPill: View {
    let text: String
    var style: Style = .purple
    var onInfoTap: (() -> Void)? = nil

    enum Style {
        case purple, green, amber, blue, red, dark

        var background: Color {
            switch self {
            case .purple: return Color(hex: "#F7F4FF")
            case .green:  return Color(hex: "#F0FBF3")
            case .amber:  return Color(hex: "#FFF8EC")
            case .blue:   return Color(hex: "#F0F6FF")
            case .red:    return Color(hex: "#FFF2F2")
            case .dark:   return Color(.label)
            }
        }

        var foreground: Color {
            switch self {
            case .purple: return Color(hex: "#5E35B1")
            case .green:  return Color(hex: "#1B6B35")
            case .amber:  return Color(hex: "#92620A")
            case .blue:   return Color(hex: "#1A4F8A")
            case .red:    return Color(hex: "#8A1A1A")
            case .dark:   return Color(.systemBackground)
            }
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: BaseTheme.Spacing.sm) {
            Text(text)
                .font(Typography.caption())
                .foregroundStyle(style.foreground)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let onInfoTap {
                AIBadge(action: onInfoTap)
            }
        }
        .padding(BaseTheme.Spacing.xl)
        .background(style.background)
        .locktyRadius(BaseTheme.Radius.md)
    }
}

#Preview {
    VStack(spacing: BaseTheme.Spacing.md) {
        AIInsightPill(
            text: "You resisted Instagram twice as well as yesterday. This is your longest Friday session ever.",
            style: .purple
        ) { print("info tapped") }

        AIInsightPill(
            text: "Your peak focus is consistently 10–11am — 3 Fridays in a row.",
            style: .green
        ) { print("info tapped") }

        AIInsightPill(
            text: "Tuesdays keep slipping — 4 weeks in a row.",
            style: .amber
        ) { print("info tapped") }

        AIInsightPill(
            text: "9 days to beat your best streak.",
            style: .blue
        ) { print("info tapped") }

        AIInsightPill(
            text: "Instagram attempts drop 60% on days you start before 9am.",
            style: .red
        ) { print("info tapped") }

        AIInsightPill(
            text: "Tomorrow looks good. Conditions are right for a strong session.",
            style: .dark
        ) { print("info tapped") }
    }
    .padding()
    .background(Color.pageBackground)
}
