//
//  ScreenTimePickerViewModel.swift
//  Lockty
//

import Foundation
import FamilyControls

@MainActor
@Observable
final class ScreenTimePickerViewModel {
    private let store: AppGroupStore
    private let modeViewModel: CreateModeViewModel

    // Draft state lives here so the view only renders.
    var draftSelection: FamilyActivitySelection
    var draftLinkedAppGroupID: UUID?

    // Nested presentation state.
    var activeSheet: ScreenTimePickerSheetRoute?
    var isDiscardAlertPresented: Bool = false
    var isEmojiPickerPresented: Bool = false

    // App Group editing state.
    var savedGroups: [AppGroup] = []
    var editingGroupID: UUID?
    var draftGroupName: String = ""
    var draftGroupEmoji: String = "🙂"

    init(
        modeViewModel: CreateModeViewModel,
        store: AppGroupStore? = nil
    ) {
        self.modeViewModel = modeViewModel
        self.store = store ?? .shared
        self.draftSelection = modeViewModel.blockedApps
        self.draftLinkedAppGroupID = modeViewModel.linkedAppGroupID
        refreshGroups()
    }

    var hasUnsavedChanges: Bool {
        draftLinkedAppGroupID != modeViewModel.linkedAppGroupID ||
        !AppGroup.matches(draftSelection, modeViewModel.blockedApps)
    }

    var isUsingLinkedGroup: Bool {
        draftLinkedAppGroupID != nil
    }

    var currentLinkedGroup: AppGroup? {
        linkedGroup(for: draftLinkedAppGroupID)
    }

    var shouldShowCreateGroupButton: Bool {
        !isUsingLinkedGroup && !AppGroup.stats(for: draftSelection).isEmpty
    }

    var trimmedGroupName: String {
        draftGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var editorSelection: FamilyActivitySelection {
        linkedGroup(for: editingGroupID)?.selection ?? draftSelection
    }

    func refreshGroups() {
        savedGroups = store.fetchAll()
    }

    func linkedGroup(for id: UUID?) -> AppGroup? {
        guard let id else { return nil }
        return savedGroups.first(where: { $0.id == id }) ?? store.fetch(id: id)
    }

    func requestDismiss() -> Bool {
        guard hasUnsavedChanges else { return true }
        isDiscardAlertPresented = true
        return false
    }

    func saveChanges() {
        if let linkedGroup = currentLinkedGroup {
            modeViewModel.applyAppGroup(linkedGroup)
        } else {
            modeViewModel.unlinkAppGroup()
            modeViewModel.blockedApps = draftSelection
        }
    }

    func finalizeDismissal() {
        modeViewModel.showScreenTimePicker = false
    }

    func presentAppGroupBrowser() {
        activeSheet = .appGroupBrowser
    }

    func dismissPresentedSheet() {
        if activeSheet == .appGroupEditor {
            resetEditorDraft()
        }
        activeSheet = nil
    }

    func useManualSelection() {
        draftLinkedAppGroupID = nil
        activeSheet = nil
    }

    func selectGroup(_ group: AppGroup) {
        draftLinkedAppGroupID = group.id
        draftSelection = group.selection
        activeSheet = nil
    }

    func prepareNewGroup() {
        editingGroupID = nil
        draftGroupName = ""
        draftGroupEmoji = "🙂"
        transitionToSheet(.appGroupEditor)
    }

    func prepareEditingGroup(_ group: AppGroup) {
        editingGroupID = group.id
        draftGroupName = group.name
        draftGroupEmoji = group.emoji
        transitionToSheet(.appGroupEditor)
    }

    func canSaveCurrentGroup() -> Bool {
        !trimmedGroupName.isEmpty && !AppGroup.stats(for: editorSelection).isEmpty
    }

    func saveCurrentGroup() {
        guard canSaveCurrentGroup() else { return }

        guard let group = try? store.save(
            id: editingGroupID,
            name: trimmedGroupName,
            emoji: draftGroupEmoji,
            selection: editorSelection
        ) else { return }

        draftLinkedAppGroupID = group.id
        draftSelection = group.selection
        refreshGroups()
        resetEditorDraft()
        activeSheet = nil
    }

    func deleteGroup(_ group: AppGroup) {
        let shouldFallbackToManualSelection = draftLinkedAppGroupID == group.id

        try? store.delete(id: group.id)
        refreshGroups()

        if shouldFallbackToManualSelection {
            draftLinkedAppGroupID = nil
            draftSelection = group.selection
        }
    }

    private func transitionToSheet(_ route: ScreenTimePickerSheetRoute) {
        if activeSheet == .appGroupBrowser {
            activeSheet = nil
            DispatchQueue.main.async { [weak self] in
                self?.activeSheet = route
            }
        } else {
            activeSheet = route
        }
    }

    private func resetEditorDraft() {
        draftGroupName = ""
        draftGroupEmoji = "🙂"
        editingGroupID = nil
        isEmojiPickerPresented = false
    }
}
