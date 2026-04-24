//
//  ScreenTimePickerBlockedContentCard.swift
//  Lockty
//

import SwiftUI

struct ScreenTimePickerBlockedContentCard: View {
    @Bindable var vm: ScreenTimePickerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.md) {
            HStack(alignment: .center, spacing: BaseTheme.Spacing.md) {
                Text("Contenido bloqueado")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(Color(.label))

                Spacer(minLength: BaseTheme.Spacing.sm)

                SelectionStatusPill(selection: vm.draftSelection)
            }

            if vm.shouldShowCreateGroupButton {
                SecondaryButton(action: vm.prepareNewGroup) {
                    HStack(spacing: BaseTheme.Spacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Convertir en grupo")
                            .font(Typography.caption(weight: .semibold))
                    }
                }
            }
        }
        .padding(BaseTheme.Spacing.lg)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
    }
}
