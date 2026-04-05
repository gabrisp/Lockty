//
//  RulesCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - RulesCard

/// Tarjeta de reglas de un modo. Agrupa participantes por transición (Activate / Break / Finish).
/// Cada grupo tiene un label de sección, chips de participantes y un separador inferior
/// (excepto el último grupo). Termina con el AI insight.

struct RulesCard: View {
    let groups: [RuleGroup]
    var insight: String? = nil
    var isLoadingInsight: Bool = false
    var onSeeFlow: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("Rules")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))

                Spacer()

                Button {
                    onSeeFlow?()
                } label: {
                    Text("See Flow")
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, BaseTheme.Spacing.md)
                        .frame(height: BaseTheme.Spacing.xxl)
                        .background(Color.innerBackground)
                        .clipShape(Capsule())
                }
                .buttonStyle(NoFlashButtonStyle())
            }
            .padding(.top, BaseTheme.Spacing.lg)
            .padding(.bottom, BaseTheme.Spacing.md)

            // Groups card
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(groups.enumerated()), id: \.offset) { i, group in
                    RuleGroupRow(group: group, showDivider: i < groups.count - 1)
                }

                // AI insight
                if let insight {
                    HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
                        Text(insight)
                            .font(Typography.caption(weight: .medium))
                            .foregroundStyle(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        AIBadge()
                    }
                    .padding(BaseTheme.Spacing.lg)
                    .background(Color.innerBackground)
                    .locktyRadius(BaseTheme.Radius.md)
                } else if isLoadingInsight {
                    HStack(alignment: .top, spacing: BaseTheme.Spacing.sm) {
                        Text("Placeholder insight text for sizing")
                            .font(Typography.caption(weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        AIBadge()
                    }
                    .padding(BaseTheme.Spacing.lg)
                    .background(Color.innerBackground)
                    .locktyRadius(BaseTheme.Radius.md)
                    .redacted(reason: .placeholder)
                }
            }
            .padding(BaseTheme.Spacing.lg)
            .background(Color.cardBackground)
            .locktyRadius(BaseTheme.Radius.card)
        }
    }
}

// MARK: - RuleGroupRow

private struct RuleGroupRow: View {
    let group: RuleGroup
    let showDivider: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            // Label + participant chips
            FlowLayout(spacing: BaseTheme.Spacing.sm) {
                Text(group.title)
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(group.participants) { participant in
                    RuleParticipantChip(participant: participant)
                }
            }

            if showDivider {
                Divider()
                    .padding(.bottom, BaseTheme.Spacing.sm)
            }
        }
        .padding(.bottom, showDivider ? 0 : BaseTheme.Spacing.sm)
    }
}

// MARK: - RuleParticipantChip

private struct RuleParticipantChip: View {
    let participant: RuleParticipant

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.xs) {
            Circle()
                .fill(participant.accentColor)
                .frame(width: 20, height: 20)

            VStack(spacing: 1) {
                Text(participant.label)
                    .font(Typography.caption(weight: .bold))
                    .foregroundStyle(Color(.label))

                Text(participant.sublabel)
                    .font(Typography.micro())
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .padding(BaseTheme.Spacing.md)
        .background(participant.accentColor.opacity(0.1))
        .locktyRadius(BaseTheme.Radius.md)
    }
}

// MARK: - FlowLayout (wrapping HStack)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let result = layout(subviews: subviews, in: proposal.width ?? 0)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let result = layout(subviews: subviews, in: bounds.width)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func layout(subviews: Subviews, in width: CGFloat) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            // "Activate" label gets full width on its own row
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            size: CGSize(width: width, height: currentY + rowHeight),
            frames: frames
        )
    }
}

// MARK: - Preview

#Preview {
    let groups: [RuleGroup] = [
        RuleGroup(transition: .activate,   participants: (0..<3).map { _ in RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .green) }),
        RuleGroup(transition: .startBreak, participants: (0..<3).map { _ in RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .yellow) }),
        RuleGroup(transition: .stop,       participants: (0..<3).map { _ in RuleParticipant(label: "Friend", sublabel: "Jorge", accentColor: .red) }),
    ]

    ScrollView {
        RulesCard(
            groups: groups,
            insight: "Your Location rule has never fired — your NFC tag always beats it. You could simplify by removing it."
        )
        .padding(BaseTheme.Spacing.lg)
    }
    .background(Color.pageBackground)
}
