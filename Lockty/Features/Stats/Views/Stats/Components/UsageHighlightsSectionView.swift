//
//  UsageHighlightsSection.swift
//  Lockty
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct UsageHighlightApp: Identifiable {
    let id = UUID()
    let name: String
    let tint: Color
    let time: String
    var token: ApplicationToken? = nil
}

struct UsageHighlightsSection: View {
    let weekUsage: String
    let weeklyPickups: Int
    let apps: [UsageHighlightApp]

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            // HStack(spacing: BaseTheme.Spacing.lg) {
            //     StatCard(pretitle: "This week", value: "19h 24m")
            //     StatCard(pretitle: "Pickups", value: "142")
            // }
            HStack(spacing: BaseTheme.Spacing.lg) {
                UsageMiniStatCard(pretitle: "This week", value: weekUsage, caption: "On your phone")
                UsageMiniStatCard(pretitle: "Pickups", value: "\(weeklyPickups)", caption: "App checks")
            }

            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Most used")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BaseTheme.Spacing.sm) {
                        ForEach(apps) { app in
                            UsageHighlightAppCard(app: app)
                        }
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
                .padding(.horizontal, -BaseTheme.Spacing.lg)
            }
        }
    }
}

private struct UsageMiniStatCard: View {
    let pretitle: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            Text(pretitle)
                .font(Typography.caption())
                .foregroundStyle(Color(.secondaryLabel))

            Text(value)
                .font(Typography.largeTitle(weight: .bold))
                .foregroundStyle(Color(.label))

            Text(caption)
                .font(Typography.caption())
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .locktyRadius(BaseTheme.Radius.card)
    }
}

private struct UsageHighlightAppCard: View {
    let app: UsageHighlightApp

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            UsageAppIcon(name: app.name, tint: app.tint, token: app.token)
                .frame(width: 46, height: 46)

            Text(app.name)
                .font(Typography.body(weight: .semibold))
                .foregroundStyle(Color(.label))
                .lineLimit(1)

            Text(app.time)
                .font(Typography.caption())
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(width: 120, alignment: .leading)
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .locktyRadius(BaseTheme.Radius.card)
    }
}

#Preview {
    UsageHighlightsSection(
        weekUsage: "19h 24m",
        weeklyPickups: 142,
        apps: [
            .init(name: "Instagram", tint: Color(hex: "#FCE8E3"), time: "5h 12m"),
            .init(name: "WhatsApp", tint: Color(hex: "#D4F1E4"), time: "3h 48m"),
            .init(name: "Safari", tint: Color(hex: "#D6EEFF"), time: "2h 26m")
        ]
    )
    .padding(BaseTheme.Spacing.lg)
    .background(Color.pageBackground)
}
