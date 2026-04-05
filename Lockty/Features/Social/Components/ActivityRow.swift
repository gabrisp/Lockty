//
//  ActivityRow.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - ActivityRow

/// Fila de un evento de actividad reciente.
/// Muestra avatar, nombre en negrita + descripción, pill del modo y timestamp.
/// `showDivider` añade un separador inferior (para todos menos el último).

struct ActivityRow: View {
    let event: ActivityEvent
    var showDivider: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: BaseTheme.Spacing.lg) {
                // Avatar + info
                HStack(spacing: BaseTheme.Spacing.xs) {
                    AvatarView(name: event.actorName, imageURL: event.actorAvatarURL, size: .custom(40))

                    VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs - 2) {
                        // "Name  verb"
                        (Text(event.actorName).fontWeight(.bold)
                        + Text("  \(event.description)"))
                            .font(Typography.body(weight: .regular))
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)

                        // Mode pill (optional)
                        if let modeName = event.modeName, let colorHex = event.modeColorHex {
                            Text(modeName)
                                .font(Typography.micro())
                                .foregroundStyle(Color(.secondaryLabel))
                                .padding(.horizontal, BaseTheme.Spacing.xs + 2)
                                .padding(.vertical, BaseTheme.Spacing.xs - 2)
                                .background(Color(hex: colorHex))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                // Timestamp
                Text(event.relativeTime)
                    .font(Typography.caption(weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            if showDivider {
                Divider()
                    .padding(.top, BaseTheme.Spacing.lg)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: BaseTheme.Spacing.lg) {
        ForEach(Array(ActivityEvent.preview.enumerated()), id: \.offset) { i, event in
            ActivityRow(event: event, showDivider: i < ActivityEvent.preview.count - 1)
        }
    }
    .padding(BaseTheme.Spacing.lg)
    .background(Color.pageBackground)
}
