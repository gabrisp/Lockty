//
//  ScreenTimePickerPresentations.swift
//  Lockty
//

import SwiftUI

/// Keeps alert and nested sheet wiring out of the rendering view.
struct ScreenTimePickerPresentations: ViewModifier {
    @Bindable var vm: ScreenTimePickerViewModel
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .interactiveDismissDisabled(vm.hasUnsavedChanges)
            .sheet(
                item: Binding(
                    get: { vm.activeSheet },
                    set: { newValue in
                        if let newValue {
                            vm.activeSheet = newValue
                        } else {
                            vm.dismissPresentedSheet()
                        }
                    }
                )
            ) { route in
                DynamicSheet {
                    switch route {
                    case .appGroupBrowser:
                        AppGroupBrowserSheet(vm: vm)
                    case .appGroupEditor:
                        AppGroupEditorSheet(vm: vm)
                    }
                }
            }
            .alert("Descartar cambios", isPresented: $vm.isDiscardAlertPresented) {
                Button("Seguir editando", role: .cancel) {}
                Button("Descartar", role: .destructive) {
                    vm.finalizeDismissal()
                    onDismiss()
                }
            } message: {
                Text("Tienes cambios sin guardar en este selector.")
            }
    }
}
