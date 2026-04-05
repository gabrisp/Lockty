//
//  ActiveModeCard.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ActiveModeCard: View {
    let mode: Mode
    let elapsedTime: String
    let trigger: String
    var onBreak: () -> Void
    var onFinish: () -> Void

    var body: some View {
            VStack(alignment: .center, spacing: BaseTheme.Spacing.lg) {
                // Header — icon + name + apps/rules + active badge
               

                
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
                                Text("3 apps")
                                Circle()
                                    .fill(Color(.secondaryLabel))
                                    .frame(width: BaseTheme.Spacing.xs, height: BaseTheme.Spacing.xs)
                                Text("3 rules")
                            }
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }


                // Timer
                Text(elapsedTime)
                    .font(Typography.extraLargeTitle(weight: .semibold))
                    .foregroundStyle(Color(.label))

                // Buttons
                HStack(spacing: BaseTheme.Spacing.lg) {
                    PrimaryButton(action: onBreak) {
                        Text("Take a Break")
                            .font(Typography.body(weight: .semibold))
                    }

                    DestructiveButton(action: onFinish) {
                        Text("Finish")
                            .font(Typography.body(weight: .semibold))
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
}

#Preview {
    ActiveModeCard(
        mode: .previewActive,
        elapsedTime: "02h 44m 02s",
        trigger: "Manual",
        onBreak: {},
        onFinish: {}
    )
    .padding()
    .background(Color.pageBackground)
}
