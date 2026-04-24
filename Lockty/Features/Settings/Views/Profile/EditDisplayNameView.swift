//
//  EditDisplayNameView.swift
//  Lockty
//
//  Created by Gabrisp on 11/4/26.
//

import SwiftUI
import CoreData

struct EditDisplayNameView: View {
    let user: LocalUser
    @Environment(AppRouter.self) private var router
    @State private var name: String
    @State private var isLoading = false
    @State private var error: String? = nil

    init(user: LocalUser) {
        self.user = user
        _name = State(initialValue: user.displayName)
    }

    var body: some View {
        List {
            Section {
                TextField("Tu nombre", text: $name)
                    .font(Typography.body())
                    .autocorrectionDisabled()
            }

            if let error {
                Section {
                    Text(error)
                        .font(Typography.caption())
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Nombre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Guardar") { save() }
                    .font(Typography.body(weight: .semibold))
                    .disabled(!canSave || isLoading)
            }
        }
    }
}

// MARK: - Logic

private extension EditDisplayNameView {
    var canSave: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 2 && trimmed != user.displayName
    }

    func save() {
        isLoading = true
        error = nil
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let ctx = PersistenceController.shared.context
        let req = LocalUserEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        req.fetchLimit = 1
        guard let entity = try? ctx.fetch(req).first else {
            error = "No se pudo guardar. Inténtalo de nuevo."
            isLoading = false
            return
        }
        entity.displayName = trimmed
        do {
            try ctx.save()
            var updated = user
            updated.displayName = trimmed
            withAnimation(.easeInOut(duration: 0.3)) { router.currentUser = updated }
            router.settings.pop()
        } catch {
            self.error = "No se pudo guardar. Inténtalo de nuevo."
            isLoading = false
        }
    }
}
