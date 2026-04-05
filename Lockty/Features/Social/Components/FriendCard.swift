//
//  FriendCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - FriendCard

/// Tarjeta vertical de un amigo en el carrusel horizontal.
/// Muestra avatar, nombre, username y los modos compartidos como pills.
/// Si `friend.hasNoPermissions` muestra un pill gris "No Permissions".

struct FriendCard: View {
    let friend: Friend
    var onTap: (() -> Void)? = nil

    private let cardWidth: CGFloat = 125
    private let avatarDiameter: CGFloat = 70

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: BaseTheme.Spacing.xs) {
                AvatarView(name: friend.displayName, size: .custom(avatarDiameter))

                VStack(spacing: 2) {
                    Text(friend.displayName)
                        .font(Typography.body(weight: .bold))
                        .foregroundStyle(Color(.label))
                        .lineLimit(1)

                    Text(friend.username)
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(1)
                }

                // Mode pills
                if friend.hasNoPermissions {
                    noPermissionsPill
                } else {
                    modePills
                }
            }
            .padding(BaseTheme.Spacing.lg)
            .frame(width: cardWidth)
            .background(Color.cardBackground)
            .locktyRadius(BaseTheme.Radius.card)
        }
        .buttonStyle(NoFlashButtonStyle())
    }

    // MARK: - Pills

    @ViewBuilder
    private var modePills: some View {
        HStack(spacing: BaseTheme.Spacing.xs) {
            ForEach(friend.sharedModes.prefix(2)) { mode in
                Text(mode.name)
                    .font(Typography.micro())
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, BaseTheme.Spacing.xs + 2)
                    .padding(.vertical, BaseTheme.Spacing.xs - 2)
                    .background(Color(hex: mode.colorHex))
                    .clipShape(Capsule())
            }
        }
    }

    private var noPermissionsPill: some View {
        Text("No Permissions")
            .font(Typography.micro())
            .foregroundStyle(Color(.secondaryLabel))
            .padding(.horizontal, BaseTheme.Spacing.xs + 2)
            .padding(.vertical, BaseTheme.Spacing.xs - 2)
            .background(Color(.systemFill))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: BaseTheme.Spacing.lg) {
            ForEach(Friend.preview) { friend in
                FriendCard(friend: friend)
            }
        }
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
