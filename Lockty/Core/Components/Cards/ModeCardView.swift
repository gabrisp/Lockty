//
//  ModeCardView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//
import SwiftUI

struct ModeCard: View {
    let name: String
    let icon: String        // SF Symbol name
    let colorHex: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var onPlay: (() -> Void)? = nil

    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                action?()
            } label: {
                VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color(.label))

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(Typography.body(weight: .semibold))
                            .foregroundStyle(Color(.label))

                        Text(subtitle)
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .padding(BaseTheme.Spacing.lg)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .background(Color(hex: colorHex).opacity(colorScheme == .light ? 1 : 0.5))
                .locktyRadius(BaseTheme.Radius.card)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                .tappable()
            }
            .buttonStyle(NoFlashButtonStyle())

            if let onPlay {
                Button(action: onPlay) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 34, height: 34)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .buttonStyle(.plain)
                .padding(BaseTheme.Spacing.sm)
            }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BaseTheme.Spacing.md) {
        ModeCard(name: "Gym", icon: "figure.run", colorHex: "#FCE8E3", subtitle: "3 apps") {} onPlay: {}
        ModeCard(name: "Study", icon: "book.fill", colorHex: "#E3ECF8", subtitle: "2 apps") {} onPlay: {}
        ModeCard(name: "Evening", icon: "moon.fill", colorHex: "#E8F5E9", subtitle: "5 apps") {} onPlay: {}
        ModeCard(name: "Deep Work", icon: "target", colorHex: "#F3E8FF", subtitle: "4 apps") {} onPlay: {}
    }
    .padding()
    .background(Color.pageBackground)
}
