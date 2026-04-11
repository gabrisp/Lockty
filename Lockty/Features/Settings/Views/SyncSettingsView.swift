//
//  SyncSettingsView.swift
//  Lockty
//
//  Created by Gabrisp on 11/4/26.
//

import SwiftUI
import CoreData

struct SyncSettingsView: View {
    @State private var syncModes: Bool = false
    @State private var syncSessions: Bool = false
    private let ctx = PersistenceController.shared.context

    var body: some View {
        List {
            Section(footer: Text("Sincroniza tus datos entre dispositivos usando tu cuenta de Apple.").font(Typography.caption())) {
                Toggle(isOn: $syncModes) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sincronizar Modos")
                            .font(Typography.body())
                        Text("Guarda tus modos en la nube.")
                            .font(Typography.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: syncModes) { _, new in save(syncModes: new, syncSessions: syncSessions) }

                Toggle(isOn: $syncSessions) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sincronizar Sesiones")
                            .font(Typography.body())
                        Text("Guarda tu historial de sesiones en la nube.")
                            .font(Typography.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: syncSessions) { _, new in save(syncModes: syncModes, syncSessions: new) }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Sincronización")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { load() }
    }

    private func load() {
        let settings = SyncSettingsEntity.current(in: ctx)
        syncModes = settings.syncModes
        syncSessions = settings.syncSessions
    }

    private func save(syncModes: Bool, syncSessions: Bool) {
        let settings = SyncSettingsEntity.current(in: ctx)
        settings.syncModes = syncModes
        settings.syncSessions = syncSessions
        try? ctx.save()
    }
}
