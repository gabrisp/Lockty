//
//  SettingsView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct SettingsView: View {
    let user: User
    @Environment(AppRouter.self) var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.settings.path) {
            List {
                Section {
                    VStack(spacing: BaseTheme.Spacing.xl) {
                        AvatarView(name: user.displayName, size: .large)
                        VStack(spacing: BaseTheme.Spacing.xs) {
                            Text(user.displayName)
                                .font(Typography.sectionTitle())
                            Text("@\(user.username)")
                                .font(Typography.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }

                Section(header: sectionHeader("Profile")) {
                    row(title: "Display Name", value: user.displayName, disclosure: true) {
                        router.settings.push(.editDisplayName)
                    }
                    row(title: "Username", value: "@\(user.username)", disclosure: true) {
                        router.settings.push(.editUsername)
                    }
                    row(title: "Email", value: user.email, disclosure: true) {
                        router.settings.push(.editEmail)
                    }
                }

                Section(header: sectionHeader("Devices")) {
                    row(title: "iPhone 17 Pro", value: "Primary", valueColor: .green)
                    row(title: "iPad Pro", value: "Read-Only")
                }

                Section(header: sectionHeader("Settings")) {
                    row(title: "Sync", value: "Active", valueColor: .green)
                    row(title: "Tabs", disclosure: true) {
                        router.settings.push(.tabs)
                    }
                    row(title: "Permissions", disclosure: true) {
                        router.settings.push(.permissions)
                    }
                    row(title: "Notifications", disclosure: true) {
                        router.settings.push(.notifications)
                    }
                }

                Section(header: sectionHeader("Legal")) {
                    row(title: "Privacy Policy", external: true)
                    row(title: "Terms of Use", external: true)
                }

                Section(header: sectionHeader("Share")) {
                    row(title: "Contact", external: true)
                    row(title: "Feedback", external: true)
                    row(title: "Feature Request", external: true)
                    row(title: "Rate us", external: true)
                }

                Section {
                    Button(role: .destructive) { } label: {
                        Text("Sign Out")
                            .font(Typography.body())
                    }
                }

                Section {
                    Text("v 1.1")
                        .font(Typography.caption())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .scrollIndicators(.hidden)
            .presentationDragIndicator(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .editDisplayName: Text("Edit Display Name")
                case .editUsername:    Text("Edit Username")
                case .editEmail:       Text("Edit Email")
                case .devices:         Text("Devices")
                case .deviceDetail:    Text("Device Detail")
                case .tabs:            Text("Tabs")
                case .permissions:     Text("Permissions")
                case .notifications:   Text("Notifications")
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Typography.sectionTitle(weight: .semibold))
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    @ViewBuilder
    private func row(
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

#Preview {
    NavigationStack {
        SettingsView(user: .preview)
            .environment(AppRouter())
    }
}
