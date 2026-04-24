//
//  MostResistedCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - MostResistedCard

/// Tarjeta "Most Resisted" construida sobre StatCard.
/// Muestra un ranking de apps con barra de progreso relativa y conteo de intentos.

struct ResistedApp: Identifiable {
    let id = UUID()
    let name: String
    let icon: String        // SF Symbol
    let count: Int
}

struct MostResistedCard: View {
    let pretitle: String
    let apps: [ResistedApp]
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    var body: some View {
        StatCard(
            pretitle: pretitle,
            badge: {
                Text("Attempts")
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
            },
            content: { list },
            insight: insight,
            isLoadingInsight: isLoadingInsight
        )
    }

    // MARK: - List

    private var list: some View {
        let maxCount = CGFloat(apps.map(\.count).max() ?? 1)

        return VStack(spacing: BaseTheme.Spacing.md) {
            ForEach(apps) { app in
                HStack(spacing: BaseTheme.Spacing.sm) {
                    // Icon
                    RoundedRectangle(cornerRadius: BaseTheme.Radius.sm)
                        .fill(Color.innerBackground)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: app.icon)
                                .font(Typography.caption(weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                        }

                    // Name
                    Text(app.name)
                        .font(Typography.caption(weight: .semibold))
                        .frame(width: 70, alignment: .leading)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemFill))
                            Capsule()
                                .fill(Color(.systemGray))
                                .frame(width: geo.size.width * CGFloat(app.count) / maxCount)
                        }
                    }
                    .frame(height: 10)

                    // Count
                    Text("\(app.count)")
                        .font(Typography.caption(weight: .semibold))
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let apps: [ResistedApp] = [
        .init(name: "Instagram", icon: "camera",     count: 23),
        .init(name: "TikTok",    icon: "music.note", count: 17),
        .init(name: "X",         icon: "xmark",      count: 10),
    ]

    ScrollView {
        MostResistedCard(
            pretitle: "Most Resisted",
            apps: apps,
            insight: "Instagram attempts drop 60% on days you start before 9am. Today you started at 9:30 — tomorrow try 9:00"
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
