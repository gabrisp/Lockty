//
//  BlockedAppGrid.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

// MARK: - BlockedAppGrid

private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: BaseTheme.Spacing.sm), count: 4)

struct BlockedAppGrid: View {
    let apps: [BlockedApp]
    var insight: String? = nil
    var isLoadingInsight: Bool = false
    var onAdd: (() -> Void)? = nil

    var body: some View {
        if onAdd != nil {
            StatCard(
                pretitle: "Blocked Apps",
                badge: { addButton },
                content: { grid(apps: apps) },
                insight: insight,
                isLoadingInsight: isLoadingInsight
            )
        } else {
            StatCard(
                pretitle: "Blocked Apps",
                insight: insight,
                isLoadingInsight: isLoadingInsight
            ) { grid(apps: apps) }
        }
    }

    private var addButton: some View {
        Button { onAdd?() } label: {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .buttonStyle(.plain)
    }

    private func grid(apps: [BlockedApp]) -> some View {
        LazyVGrid(columns: gridColumns, spacing: BaseTheme.Spacing.sm) {
            ForEach(apps) { app in
                AppCell(token: app.token)
            }
        }
    }
}

// MARK: - BlockedCategoryGrid

struct BlockedCategoryGrid: View {
    let categories: [BlockedCategory]
    var insight: String? = nil
    var isLoadingInsight: Bool = false
    var onAdd: (() -> Void)? = nil

    var body: some View {
        if onAdd != nil {
            StatCard(
                pretitle: "Blocked Categories",
                badge: { addButton },
                content: { grid(categories: categories) },
                insight: insight,
                isLoadingInsight: isLoadingInsight
            )
        } else {
            StatCard(
                pretitle: "Blocked Categories",
                insight: insight,
                isLoadingInsight: isLoadingInsight
            ) { grid(categories: categories) }
        }
    }

    private var addButton: some View {
        Button { onAdd?() } label: {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .buttonStyle(.plain)
    }

    private func grid(categories: [BlockedCategory]) -> some View {
        LazyVGrid(columns: gridColumns, spacing: BaseTheme.Spacing.sm) {
            ForEach(categories) { category in
                CategoryCell(token: category.token)
            }
        }
    }
}

// MARK: - AppCell

private struct AppCell: View {
    let token: ApplicationToken

    var body: some View {
        Label(token)
            .labelStyle(AppIconLabelStyle())
            .padding(.vertical, BaseTheme.Spacing.sm)
    }
}

struct AppIconLabelStyle: LabelStyle {
    var size: CGFloat = 48

    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2224))
    }
}

// MARK: - CategoryCell

private struct CategoryCell: View {
    let token: ActivityCategoryToken

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.sm) {
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.sm))

            Label(token)
                .labelStyle(.titleOnly)
                .font(Typography.micro())
                .foregroundStyle(Color(.label))
                .lineLimit(1)
        }
        .padding(.vertical, BaseTheme.Spacing.sm)
    }
}
