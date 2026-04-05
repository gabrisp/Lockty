//
//  StatCard.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

// MARK: - StatCard

/// Card genérico de stats.
/// - pretitle: label pequeño arriba
/// - content: cualquier View (el valor principal)
/// - badge: View opcional top-right (ej. DeltaBadge, Text)
/// - insight: texto AI opcional. Si nil, no se muestra. Si isLoadingInsight, muestra shimmer.
struct StatCard<Content: View, Badge: View>: View {
    let pretitle: String
    @ViewBuilder let badge: () -> Badge
    @ViewBuilder let content: () -> Content
    var insight: String? = nil
    var isLoadingInsight: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            // Header
            HStack(alignment: .top) {
                Text(pretitle)
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
                Spacer()
                badge()
            }

            // Content
            content()

            // AI Insight
            if isLoadingInsight {
                insightRow(text: "")
                    .redacted(reason: .placeholder)
            } else if let insight {
                insightRow(text: insight)
            }
        }
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .locktyRadius(BaseTheme.Radius.card)
    }

    @ViewBuilder
    private func insightRow(text: String) -> some View {
        HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
            Text(text)
                .font(Typography.caption(weight: .medium))
                .foregroundStyle(Color(.label))
                .frame(maxWidth: .infinity, alignment: .leading)
            AIBadge()
        }
        .padding(BaseTheme.Spacing.md)
        .background(Color.innerBackground)
        .locktyRadius(BaseTheme.Radius.md)
    }
}

// MARK: - Convenience init — sin badge

extension StatCard where Badge == EmptyView {
    init(
        pretitle: String,
        insight: String? = nil,
        isLoadingInsight: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.pretitle = pretitle
        self.content = content
        self.badge = { EmptyView() }
        self.insight = insight
        self.isLoadingInsight = isLoadingInsight
    }

    // trailing closure con badge explícito vacío — alias para el call site con badge: { ... } content: { ... }
    init(
        pretitle: String,
        @ViewBuilder content: @escaping () -> Content,
        insight: String? = nil,
        isLoadingInsight: Bool = false
    ) {
        self.pretitle = pretitle
        self.content = content
        self.badge = { EmptyView() }
        self.insight = insight
        self.isLoadingInsight = isLoadingInsight
    }
}

// MARK: - Convenience init — content es un Text simple

extension StatCard where Content == Text, Badge == EmptyView {
    init(
        pretitle: String,
        value: String,
        insight: String? = nil,
        isLoadingInsight: Bool = false
    ) {
        self.pretitle = pretitle
        self.content = { Text(value).font(Typography.largeTitle()).foregroundStyle(Color(.label)) }
        self.badge = { EmptyView() }
        self.insight = insight
        self.isLoadingInsight = isLoadingInsight
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: BaseTheme.Spacing.lg) {
            // Con badge y insight
            StatCard(
                pretitle: "Focused today",
                badge: {
                    Text("↑ 34m vs yesterday")
                        .font(Typography.caption(weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, BaseTheme.Spacing.sm)
                        .padding(.vertical, BaseTheme.Spacing.xs)
                        .background(Color.green)
                        .clipShape(Capsule())
                },
                content: {
                    Text("2h 44m")
                        .font(Typography.largeTitle(weight: .bold))
                        .foregroundStyle(Color(.label))
                },
                insight: "You resisted Instagram twice as well as yesterday."
            )

            // Valor simple sin badge
            StatCard(pretitle: "Sessions", value: "2")

            // Loading insight
            StatCard(pretitle: "Sessions", value: "2", isLoadingInsight: true)
        }
        .padding(BaseTheme.Spacing.lg)
        .background(Color.pageBackground)
    }
}
