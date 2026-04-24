//
//  ScreenTimePickerTopBar.swift
//  Lockty
//

import SwiftUI

struct ScreenTimePickerTopBar: View {
    @Bindable var vm: ScreenTimePickerViewModel
    let onClose: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.md) {
            HStack {
                toolbarButton(
                    icon: "xmark",
                    isConfirmation: false,
                    action: onClose
                )

                Spacer()

                toolbarButton(
                    icon: "checkmark",
                    isConfirmation: true,
                    action: onSave
                )
            }

            Button {
                vm.presentAppGroupBrowser()
            } label: {
                HStack(spacing: BaseTheme.Spacing.sm) {
                    if let group = vm.currentLinkedGroup {
                        Text(group.emoji)
                            .font(.system(size: 18))
                            .stickered(width: 4)
                    } else {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    Text(vm.currentLinkedGroup?.name ?? "App Group")
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, BaseTheme.Spacing.md)
                .padding(.vertical, BaseTheme.Spacing.sm)
                .background(Color.cardBackground)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .padding(.top, BaseTheme.Spacing.sm)
        .padding(.bottom, BaseTheme.Spacing.sm)
    }

    private func toolbarButton(
        icon: String,
        isConfirmation: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isConfirmation ? Color.white : Color(.label))
                .frame(width: 38, height: 38)
                .background(isConfirmation ? Color.blue : Color.cardBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
