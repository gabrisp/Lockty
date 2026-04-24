//
//  AppGroupEditorSheet.swift
//  Lockty
//

import SwiftUI
import EmojiPicker

struct AppGroupEditorSheet: View {
    @Bindable var vm: ScreenTimePickerViewModel

    private var selectedEmojiBinding: Binding<Emoji?> {
        Binding(
            get: {
                Emoji(value: vm.draftGroupEmoji, name: vm.draftGroupEmoji)
            },
            set: { emoji in
                guard let emoji else { return }
                vm.draftGroupEmoji = emoji.value
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            Text(vm.editingGroupID == nil ? "Crear grupo" : "Editar grupo")
                .font(Typography.title())
                .foregroundStyle(Color(.label))
                .padding(.horizontal, BaseTheme.Spacing.lg)

            HStack(spacing: BaseTheme.Spacing.md) {
                Button {
                    vm.isEmojiPickerPresented = true
                } label: {
                    Text(vm.draftGroupEmoji)
                        .font(.system(size: 36))
                        .stickered(width: 5)
                        .frame(width: 62, height: 62)
                        .background(Color.innerBackground)
                        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.md))
                }
                .buttonStyle(.plain)

                TextField("Nombre del grupo", text: $vm.draftGroupName)
                    .font(Typography.body())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, BaseTheme.Spacing.md)
                    .padding(.vertical, BaseTheme.Spacing.md)
                    .background(Color.innerBackground)
                    .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.md))
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)

            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                Text("Contenido bloqueado")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(Color(.label))

                SelectionStatusPill(selection: vm.editorSelection)
            }
            .padding(BaseTheme.Spacing.lg)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
            .padding(.horizontal, BaseTheme.Spacing.lg)

            PrimaryButton(
                isDisabled: !vm.canSaveCurrentGroup(),
                action: vm.saveCurrentGroup
            ) {
                Text(vm.editingGroupID == nil ? "Guardar grupo" : "Actualizar grupo")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)
        }
        .padding(.vertical, BaseTheme.Spacing.lg)
        .modifier(
            AppGroupEditorPresentations(
                vm: vm,
                selectedEmoji: selectedEmojiBinding
            )
        )
    }
}
