//
//  ModesView.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import SwiftUI

struct ModesView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modeZoomNamespace) private var zoomNamespace
    @State private var vm = ModesViewModel()

    @State private var appeared = false

    var body: some View {
        Group {
            if vm.isEmpty {
                emptyState
            } else {
                modesContent
            }
        }
        .opacity(appeared ? 1 : 0)
        .blur(radius: appeared ? 0 : 12)
        .animation(.snappy(duration: 0.6, extraBounce: 0.02).delay(0.6), value: appeared)
        .onAppear {
            appeared = true
            vm.loadModes()
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $vm.activationPrompt) { prompt in
            DynamicSheet {
                ModeActivationPromptSheet(prompt: prompt)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: BaseTheme.Spacing.lg) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))

            VStack(spacing: BaseTheme.Spacing.xs) {
                Text("Sin modos")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                Text("Crea tu primer modo para empezar a bloquear apps.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }

            PrimaryButton {
                router.openCreateMode()
            } label: {
                Text("Crear modo")
                    .font(Typography.body(weight: .semibold))
            }
            .padding(.horizontal, BaseTheme.Spacing.xl)
            .padding(.top, BaseTheme.Spacing.sm)
        }
        .padding(.horizontal, BaseTheme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Modes content

    private var modesContent: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

                // MARK: - Active Mode Banner
                if let mode = vm.activeMode, let status = vm.activeModeStatus {
                    ActiveModeCard(
                        mode: mode,
                        status: status,
                        onBreak: {},
                        onFinish: vm.finishActiveMode
                    )
                }

                // homeInsightsSection

                // MARK: - Inactive Modes Grid
                VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                    // if vm.activeMode != nil {
                    //     Text("Modos")
                    //         .font(Typography.body(weight: .semibold))
                    //         .foregroundStyle(Color(.secondaryLabel))
                    //         .padding(.horizontal, BaseTheme.Spacing.lg)
                    // }
                    Text("Modes")
                        .font(Typography.body(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: BaseTheme.Spacing.lg
                    ) {
                        ForEach(vm.inactiveModes) { mode in
                            ModeCard(
                                name: mode.name,
                                icon: mode.iconName,
                                colorHex: mode.colorHex,
                                subtitle: ""
                            ) {
                                router.navigation.push(.modeDetail(mode: mode))
                            }
                            .ifLet(zoomNamespace) { view, ns in
                                view.matchedTransitionSource(id: mode.id, in: ns) {
                                    $0.background(.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                                }
                            }
                        }

                        // Nueva tarjeta
                        ModeCard(
                            name: "Nuevo",
                            icon: "plus",
                            colorHex: "#F2F2F7",
                            subtitle: ""
                        ) {
                            router.openCreateMode()
                        }
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }
            .padding(.top, 44 + BaseTheme.Spacing.md)
            .padding(.bottom, 100)
        }

    }
}

private struct ModeActivationPromptSheet: View {
    let prompt: ModeActivationPrompt

    var body: some View {
        VStack(spacing: BaseTheme.Spacing.lg) {
            RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                .fill(Color.cardBackground)
                .frame(width: 72, height: 72)
                .overlay {
                    Image(systemName: prompt.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color(.label))
                }

            VStack(spacing: BaseTheme.Spacing.xs) {
                Text(prompt.title)
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))

                Text(prompt.message)
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, BaseTheme.Spacing.xl)
        .padding(.vertical, BaseTheme.Spacing.xl)
    }
}

#Preview {
    ModesView()
        .environment(AppRouter())
        .background(Color.pageBackground)
}
