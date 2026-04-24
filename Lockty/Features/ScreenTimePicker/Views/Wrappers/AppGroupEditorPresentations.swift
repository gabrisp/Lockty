//
//  AppGroupEditorPresentations.swift
//  Lockty
//

import SwiftUI
import EmojiPicker

/// Keeps the nested emoji sheet out of the editor view body.
struct AppGroupEditorPresentations: ViewModifier {
    @Bindable var vm: ScreenTimePickerViewModel
    let selectedEmoji: Binding<Emoji?>

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $vm.isEmojiPickerPresented) {
                NavigationStack {
                    EmojiPickerView(
                        selectedEmoji: selectedEmoji,
                        searchEnabled: true,
                        selectedColor: .blue
                    )
                    .navigationTitle("Emoji")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
    }
}
