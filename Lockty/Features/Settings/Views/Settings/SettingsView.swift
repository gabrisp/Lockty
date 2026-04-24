//
//  SettingsView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI
import CoreData
import RevenueCatUI

struct SettingsView: View {
    let user: LocalUser
    @Environment(AppRouter.self) var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.settings.path) {
            List {
                profileHeader
                profileSection
                settingsSection
                subscriptionSection
                legalSection
                shareSection
                #if DEBUG
                developerSection
                #endif
                versionFooter
            }
            .scrollIndicators(.hidden)
            .presentationDragIndicator(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .editDisplayName: EditDisplayNameView(user: user)
                case .editUsername:    Text("Nombre de usuario")
                case .editEmail:       Text("Email")
                case .tabs:            Text("Pestañas")
                case .permissions:     Text("Permisos")
                case .notifications:   Text("Notificaciones")
                case .sync:            SyncSettingsView()
                case .subscription:    CustomerCenterView()
                }
            }
        }
    }
}

// MARK: - Sections

private extension SettingsView {
    var profileHeader: some View {
        Section {
            VStack(spacing: BaseTheme.Spacing.xl) {
                AvatarView(name: user.displayName, size: .large)
                VStack(spacing: BaseTheme.Spacing.xs) {
                    Text(user.displayName)
                        .font(Typography.sectionTitle())
                    Text(user.displayName)
                        .font(Typography.caption())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
        }
    }

    var profileSection: some View {
        Section(header: sectionHeader("Perfil")) {
            row(title: "Nombre", value: user.displayName, disclosure: true) {
                router.settings.push(.editDisplayName)
            }
        }
    }

    var settingsSection: some View {
        Section(header: sectionHeader("Ajustes")) {
            row(title: "Sincronización", value: "Activa", valueColor: .green, disclosure: true) {
                router.settings.push(.sync)
            }
            row(title: "Pestañas", disclosure: true) {
                router.settings.push(.tabs)
            }
            row(title: "Permisos", disclosure: true) {
                router.settings.push(.permissions)
            }
            row(title: "Notificaciones", disclosure: true) {
                router.settings.push(.notifications)
            }
        }
    }

    var subscriptionSection: some View {
        Section(header: sectionHeader("Suscripción")) {
            row(title: "Gestionar suscripción", disclosure: true) {
                router.settings.push(.subscription)
            }
        }
    }

    var legalSection: some View {
        Section(header: sectionHeader("Legal")) {
            row(title: "Política de privacidad", external: true)
            row(title: "Términos de uso", external: true)
        }
    }

    var shareSection: some View {
        Section(header: sectionHeader("Compartir")) {
            row(title: "Contacto", external: true)
            row(title: "Feedback", external: true)
            row(title: "Sugerencia", external: true)
            row(title: "Valorar la app", external: true)
        }
    }

    var developerSection: some View {
        Section(header: sectionHeader("Desarrollador")) {
            Button(role: .destructive) {
                let ctx = PersistenceController.shared.context
                let req = LocalUserEntity.fetchRequest()
                if let entities = try? ctx.fetch(req) {
                    entities.forEach { ctx.delete($0) }
                    try? ctx.save()
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    router.currentUser = nil
                    router.authState = .onboarding
                }
            } label: {
                Text("Reiniciar onboarding")
                    .font(Typography.body())
            }
        }
    }

    var versionFooter: some View {
        Section {
            Text("v 1.1")
                .font(Typography.caption())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
        }
    }
}

// MARK: - Row Helpers

private extension SettingsView {
    @ViewBuilder
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Typography.sectionTitle(weight: .semibold))
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    @ViewBuilder
    func row(
        title: String,
        value: String? = nil,
        valueColor: Color = .secondary,
        disclosure: Bool = false,
        external: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                Text(title)
                    .font(Typography.body())
                    .foregroundStyle(.primary)
                Spacer()
                if let value {
                    Text(value)
                        .font(Typography.body())
                        .foregroundStyle(valueColor)
                }
                if disclosure {
                    Image(systemName: "chevron.right")
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                if external {
                    Image(systemName: "arrow.up.right")
                        .font(Typography.caption())
                        .foregroundStyle(.tertiary)
                }
            }
            .tappable()
        }
        .buttonStyle(.plain)
        .disabled(action == nil && !external)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView(user: .preview)
            .environment(AppRouter.shared)
    }
}
