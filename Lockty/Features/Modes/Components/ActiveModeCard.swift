//
//  ActiveModeCard.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ActiveModeCard: View {
    let mode: Mode
    let status: ActiveModeRuntimeStatus
    var onBreak: () -> Void
    var onFinish: () -> Void

    var body: some View {
            VStack(alignment: .center, spacing: BaseTheme.Spacing.lg) {
                HStack(alignment: .top) {
                    VStack(spacing: BaseTheme.Spacing.sm) {
                        RoundedRectangle(cornerRadius: BaseTheme.Spacing.lg, style: .continuous)
                            .frame(width: 50, height: 50)
                            .font(Typography.title(weight: .medium))
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(Color(hex: mode.colorHex))
                            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Spacing.lg))
                            .overlay(alignment:.center){
                                Image(systemName: mode.iconName)
                                    .colorMultiply(Color(hex: mode.colorHex).opacity(0.6))

                            }

                        VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                            Text(mode.name)
                                .font(Typography.body(weight: .bold))
                            HStack(spacing: BaseTheme.Spacing.xs) {
                                Text(status.blockedAppsSummary)
                                Circle()
                                    .fill(Color(.secondaryLabel))
                                    .frame(width: BaseTheme.Spacing.xs, height: BaseTheme.Spacing.xs)
                                Text(status.rulesSummary)
                            }
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }

                Text(status.elapsedTimeText)
                    .font(Typography.extraLargeTitle(weight: .semibold))
                    .foregroundStyle(Color(.label))

                VStack(spacing: BaseTheme.Spacing.sm) {
                    HStack(spacing: BaseTheme.Spacing.sm) {
                        policyPill(
                            title: "\(status.breakPolicy.breaksRemaining)/\(status.breakPolicy.maxBreaks) breaks left",
                            subtitle: status.breakPolicy.canStartBreak
                                ? "Available now"
                                : "Next in \(status.breakPolicy.nextBreakAvailableInText ?? "0m")"
                        )
                        policyPill(
                            title: status.breakPolicy.maxBreakDurationText,
                            subtitle: status.breakPolicy.minIntervalText
                        )
                    }

                    Text(status.finishPolicy.requirementText)
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)

                    Text(status.helperText)
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: BaseTheme.Spacing.lg) {
                    PrimaryButton(isDisabled: !status.breakPolicy.canStartBreak, action: onBreak) {
                        VStack(spacing: 2) {
                            Text("Take a Break")
                                .font(Typography.body(weight: .semibold))
                            Text("\(status.breakPolicy.breaksRemaining) left")
                                .font(Typography.caption())
                        }
                    }

                    DestructiveButton(isDisabled: !status.finishPolicy.canFinish, action: onFinish) {
                        VStack(spacing: 2) {
                            Text("Finish")
                                .font(Typography.body(weight: .semibold))
                            Text(status.finishPolicy.canFinish ? "Allowed now" : "Locked")
                                .font(Typography.caption())
                        }
                    }
                }
            }
            .padding(BaseTheme.Spacing.xl)
            .background{
                
                RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                    .fill(.background)
                    .glassEffect(.regular, in:  RoundedRectangle(cornerRadius: BaseTheme.Radius.card) )
            }
            .padding(BaseTheme.Spacing.lg)

    }

    private func policyPill(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Typography.caption(weight: .semibold))
                .foregroundStyle(Color(.label))
            Text(subtitle)
                .font(Typography.micro())
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BaseTheme.Spacing.md)
        .background(Color.innerBackground)
        .locktyRadius(BaseTheme.Radius.md)
    }
}

#Preview {
    ActiveModeCard(
        mode: .previewActive,
        status: .previewUniversity,
        onBreak: {},
        onFinish: {}
    )
    .padding()
    .background(Color.pageBackground)
}
