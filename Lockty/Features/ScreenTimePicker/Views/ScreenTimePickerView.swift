//
//  ScreenTimePickerView.swift
//  Lockty
//

import SwiftUI
import FamilyControls

struct ScreenTimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: ScreenTimePickerViewModel

    init(vm modeViewModel: CreateModeViewModel) {
        _vm = State(initialValue: ScreenTimePickerViewModel(modeViewModel: modeViewModel))
    }

    var body: some View {
        @Bindable var vm = vm

        VStack(spacing: BaseTheme.Spacing.lg) {
            FamilyActivityPicker(selection: $vm.draftSelection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.pageBackground)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                .overlay {
                    if vm.isUsingLinkedGroup {
                        RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                            .fill(Color.pageBackground.opacity(0.6))
                            .overlay {
                                VStack(spacing: BaseTheme.Spacing.sm) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color(.secondaryLabel))
                                    Text("La selección viene del App Group vinculado")
                                        .font(Typography.caption(weight: .medium))
                                        .foregroundStyle(Color(.secondaryLabel))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, BaseTheme.Spacing.lg)
                            }
                    }
                }
                .opacity(vm.isUsingLinkedGroup ? 0.45 : 1)
                .allowsHitTesting(!vm.isUsingLinkedGroup)

            ScreenTimePickerBlockedContentCard(vm: vm)
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .padding(.top, 120)
        .padding(.bottom, BaseTheme.Spacing.lg)
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .safeAreaBar(edge: .top) {
            ScreenTimePickerTopBar(
                vm: vm,
                onClose: handleCloseTap,
                onSave: handleSaveTap
            )
        }
        .modifier(
            ScreenTimePickerPresentations(
                vm: vm,
                onDismiss: closeSheet
            )
        )
    }

    private func handleCloseTap() {
        guard vm.requestDismiss() else { return }
        closeSheet()
    }

    private func handleSaveTap() {
        vm.saveChanges()
        closeSheet()
    }

    private func closeSheet() {
        vm.finalizeDismissal()
        dismiss()
    }
}
