//
//  RulesCard.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI

// MARK: - RulesCard

struct RulesCard: View {
    let groups: [RuleGroup]
    var insight: String? = nil
    var isLoadingInsight: Bool = false
    var onSeeFlow: (() -> Void)? = nil
    var onAddRule: ((Transition) -> Void)? = nil
    var onDeleteRule: ((UUID) -> Void)? = nil
    var isEditing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Text("Rules")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))

                Spacer()

                if !isEditing, onSeeFlow != nil {
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
            }
            .padding(.top, BaseTheme.Spacing.lg)
            .padding(.bottom, BaseTheme.Spacing.md)

            // Groups card
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(groups.enumerated()), id: \.offset) { i, group in
                    RuleGroupRow(
                        group: group,
                        showDivider: i < groups.count - 1,
                        onAdd: onAddRule.map { cb in { cb(group.transition) } },
                        onDelete: onDeleteRule,
                        isEditing: isEditing
                    )
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
    var onAdd: (() -> Void)? = nil
    var onDelete: ((UUID) -> Void)? = nil
    var isEditing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
            HStack(spacing: BaseTheme.Spacing.xs) {
                Text(group.title)
                    .font(Typography.caption())
                    .foregroundStyle(Color(.secondaryLabel))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BaseTheme.Spacing.sm) {
                    if group.participants.isEmpty, isEditing {
                        Text("No rules yet")
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(.horizontal, BaseTheme.Spacing.md)
                            .frame(height: 44)
                            .background(Color.innerBackground)
                            .locktyRadius(BaseTheme.Radius.md)
                    } else {
                        ForEach(group.participants) { participant in
                            RuleParticipantChip(
                                participant: participant,
                                onDelete: onDelete.map { delete in { delete(participant.id) } }
                            )
                        }
                    }

                    if let onAdd {
                        ToolbarButton(icon: "plus", size: 40, iconSize: 13, action: onAdd)
                    }
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
    var onDelete: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.xs) {
            HStack(alignment: .top, spacing: BaseTheme.Spacing.xs) {
                Circle()
                    .fill(participant.accentColor)
                    .frame(width: 20, height: 20)

                if let onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 1) {
                Text(participant.label)
                    .font(Typography.caption(weight: .bold))
                    .foregroundStyle(Color(.label))

                if !participant.sublabel.isEmpty {
                    Text(participant.sublabel)
                        .font(Typography.micro())
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
        }
        .padding(BaseTheme.Spacing.md)
        .background(participant.accentColor.opacity(0.1))
        .locktyRadius(BaseTheme.Radius.md)
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
