//
//  SelectionStatusPill.swift
//  Lockty
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct SelectionStatusPill: View {
    let selection: FamilyActivitySelection

    private var stats: AppGroupSelectionStats {
        AppGroup.stats(for: selection)
    }

    private var applicationTokens: [ApplicationToken] {
        Array(selection.applicationTokens.prefix(3))
    }

    private var extraApplicationsCount: Int {
        max(selection.applicationTokens.count - applicationTokens.count, 0)
    }

    var body: some View {
        HStack(spacing: BaseTheme.Spacing.sm) {
            if stats.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Seleccionar")
                        .font(Typography.caption(weight: .semibold))
                }
                .foregroundStyle(Color.orange)
            } else {
                if stats.categories > 0 {
                    CountTokenPill(icon: "square.grid.2x2", count: stats.categories)
                }

                if !applicationTokens.isEmpty {
                    AppIconsCluster(tokens: applicationTokens, extraCount: extraApplicationsCount)
                }

                if stats.webDomains > 0 {
                    CountTokenPill(icon: "globe", count: stats.webDomains)
                }
            }
        }
        .padding(.horizontal, BaseTheme.Spacing.md)
        .padding(.vertical, BaseTheme.Spacing.sm)
        .background(Color.innerBackground)
        .clipShape(Capsule())
        .fixedSize()
    }
}

private struct CountTokenPill: View {
    let icon: String
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
            Text("\(count)")
                .font(Typography.body(weight: .semibold))
        }
        .foregroundStyle(Color(.label))
    }
}

private struct AppIconsCluster: View {
    let tokens: [ApplicationToken]
    let extraCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                Label(token)
                    .labelStyle(AppIconLabelStyle(size: 30))
                    .padding(.leading, index == 0 ? 0 : -10)
                    .zIndex(Double(tokens.count - index))
            }

            if extraCount > 0 {
                Text("+\(extraCount)")
                    .font(Typography.caption(weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.leading, BaseTheme.Spacing.sm)
            }
        }
    }
}
