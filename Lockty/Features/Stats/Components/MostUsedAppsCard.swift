//
//  MostUsedAppsCard.swift
//  Lockty
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct UsedApp: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let tint: Color
    var token: ApplicationToken? = nil
}

struct MostUsedAppsCard: View {
    let pretitle: String
    let apps: [UsedApp]
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    var body: some View {
        StatCard(
            pretitle: pretitle,
            badge: {
                Text("This week")
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
            },
            content: { list },
            insight: insight,
            isLoadingInsight: isLoadingInsight
        )
    }

    private var list: some View {
        VStack(spacing: BaseTheme.Spacing.md) {
            ForEach(apps) { app in
                HStack(spacing: BaseTheme.Spacing.sm) {
                    UsageAppIcon(name: app.name, tint: app.tint, token: app.token)

                    Text(app.name)
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(app.duration)
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
        }
    }
}

#Preview {
    let apps: [UsedApp] = [
        .init(name: "Instagram", duration: "5h 12m", tint: Color(hex: "#FCE8E3")),
        .init(name: "WhatsApp", duration: "3h 48m", tint: Color(hex: "#D4F1E4")),
        .init(name: "Safari", duration: "2h 26m", tint: Color(hex: "#D6EEFF"))
    ]

    ScrollView {
        MostUsedAppsCard(
            pretitle: "Most Used Apps",
            apps: apps,
            insight: "Instagram still dominates your weekly usage. Safari becomes your second app on calmer days."
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}

struct UsageAppIcon: View {
    let name: String
    let tint: Color
    var token: ApplicationToken? = nil

    var body: some View {
        Group {
            if let token {
                Label(token)
                    .labelStyle(.iconOnly)
            } else {
                RoundedRectangle(cornerRadius: BaseTheme.Radius.sm)
                    .fill(Color.avatarGradient(for: name))
                    .overlay {
                        Text(initials)
                            .font(Typography.caption(weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
        }
        .frame(width: 36, height: 36)
        .background(token == nil ? tint.opacity(0.15) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.sm))
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
