//
//  BlockedAppGrid.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - BlockedAppGrid

/// Grid 4 columnas de apps bloqueadas, con AI insight opcional al final.
/// Construido sobre StatCard para consistencia de estilos.

private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: BaseTheme.Spacing.sm), count: 4)

struct BlockedAppGrid: View {
    let apps: [BlockedApp]
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    var body: some View {
        StatCard(
            pretitle: "Blocked Apps",
            insight: insight,
            isLoadingInsight: isLoadingInsight
        ) {
            LazyVGrid(columns: gridColumns, spacing: BaseTheme.Spacing.sm) {
                ForEach(apps) { app in
                    AppCell(app: app)
                }
            }
        }
    }
}

// MARK: - AppCell

private struct AppCell: View {
    let app: BlockedApp

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.sm) {
            RoundedRectangle(cornerRadius: BaseTheme.Radius.sm)
                .fill(Color.innerBackground)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: app.iconSymbol)
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                }

            Text(app.name)
                .font(Typography.micro())
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .padding(.vertical, BaseTheme.Spacing.sm)
    }
}

// MARK: - Preview

#Preview {
    let apps: [BlockedApp] = [
        .init(name: "Instagram", bundleId: "a", iconSymbol: "camera"),
        .init(name: "Facebook",  bundleId: "b", iconSymbol: "person.2"),
        .init(name: "Facebook",  bundleId: "c", iconSymbol: "person.2"),
        .init(name: "Facebook",  bundleId: "d", iconSymbol: "person.2"),
        .init(name: "Facebook",  bundleId: "e", iconSymbol: "person.2"),
        .init(name: "Twitter",   bundleId: "f", iconSymbol: "bird"),
        .init(name: "LinkedIn",  bundleId: "g", iconSymbol: "briefcase"),
        .init(name: "TikTok",    bundleId: "h", iconSymbol: "music.note"),
    ]
    ScrollView {
        BlockedAppGrid(
            apps: apps,
            insight: "Instagram accounts for 78% of your blocked attempts."
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
