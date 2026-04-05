//
//  SocialInboxCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - SocialInboxCard

/// Tarjeta de bandeja de entrada (Requests / Actions).
/// Muestra título, subtítulo y un badge de conteo con color configurable.

struct SocialInboxCard: View {
    let title: String
    let subtitle: String
    let count: Int
    let badgeColor: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                    Text(title)
                        .font(Typography.caption(weight: .regular))
                        .foregroundStyle(Color(.label))

                    Text(subtitle)
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if count > 0 {
                    Text("\(count)")
                        .font(Typography.caption(weight: .medium))
                        .foregroundStyle(Color.pageBackground)
                        .frame(width: BaseTheme.Spacing.xxl, height: BaseTheme.Spacing.xxl)
                        .background(badgeColor)
                        .clipShape(Circle())
                }
            }
            .padding(BaseTheme.Spacing.lg)
            .background(Color.cardBackground)
            .locktyRadius(BaseTheme.Radius.card)
        }
        .buttonStyle(NoFlashButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: BaseTheme.Spacing.lg) {
        SocialInboxCard(
            title: "Requests",
            subtitle: "People who want to connect with you",
            count: 2,
            badgeColor: .red
        )
        SocialInboxCard(
            title: "Actions",
            subtitle: "Accept or decline requests from your friends",
            count: 2,
            badgeColor: .orange
        )
    }
    .padding(BaseTheme.Spacing.lg)
    .background(Color.pageBackground)
}
