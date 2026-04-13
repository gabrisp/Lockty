//
//  ScreenTimePickerSheet.swift
//  Lockty
//

import SwiftUI
import FamilyControls

struct ScreenTimePickerSheet: View {
    @Bindable var vm: CreateModeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $vm.blockedApps)
                .navigationTitle("Apps bloqueadas")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") { dismiss() }
                            .font(Typography.body(weight: .semibold))
                    }
                }
        }
    }
}
