//
//  AppGroupBrowserSheet.swift
//  Lockty
//

import SwiftUI

struct AppGroupBrowserSheet: View {
    @Bindable var vm: ScreenTimePickerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            HStack {
                Text("App Groups")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))

                Spacer()

                Button(action: vm.prepareNewGroup) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color.innerBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)

            Button(action: vm.useManualSelection) {
                HStack(spacing: BaseTheme.Spacing.md) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selección manual")
                            .font(Typography.body(weight: .semibold))
                            .foregroundStyle(Color(.label))
                        Text("Usar el picker con apps, categorías y webs")
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    Spacer()

                    if vm.draftLinkedAppGroupID == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                    }
                }
                .padding(BaseTheme.Spacing.lg)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, BaseTheme.Spacing.lg)

            if vm.savedGroups.isEmpty {
                Text("Todavía no tienes grupos guardados. Crea uno a partir de tu selección actual.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, BaseTheme.Spacing.lg)
            } else {
                VStack(spacing: BaseTheme.Spacing.sm) {
                    ForEach(vm.savedGroups) { group in
                        Button {
                            vm.selectGroup(group)
                        } label: {
                            HStack(spacing: BaseTheme.Spacing.md) {
                                Text(group.emoji)
                                    .font(.system(size: 24))
                                    .stickered()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(group.name)
                                        .font(Typography.body(weight: .semibold))
                                        .foregroundStyle(Color(.label))
                                    Text(group.summary)
                                        .font(Typography.caption())
                                        .foregroundStyle(Color(.secondaryLabel))
                                }

                                Spacer()

                                if vm.draftLinkedAppGroupID == group.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color(.tertiaryLabel))
                                }
                            }
                            .padding(BaseTheme.Spacing.lg)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Editar") {
                                vm.prepareEditingGroup(group)
                            }
                            Button("Eliminar grupo", role: .destructive) {
                                vm.deleteGroup(group)
                            }
                        }
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
            }
        }
        .padding(.vertical, BaseTheme.Spacing.lg)
    }
}
