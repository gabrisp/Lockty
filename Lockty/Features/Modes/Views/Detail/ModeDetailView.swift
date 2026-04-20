//
//  ModeDetailView.swift
//  Lockty
//
//  Created by Gabrisp on 2/4/26.
//

import SwiftUI
import VariableBlur
import FamilyControls

struct ModeDetailView: View {
    @Environment(AppRouter.self) private var router
    @State private var vm: ModeDetailViewModel
    @State private var dragOffset: CGFloat = 0

    init(mode: Mode? = nil) {
        _vm = State(initialValue: ModeDetailViewModel(mode: mode))
    }

    var body: some View {
            ScrollView(.vertical) {
                VStack(spacing: BaseTheme.Spacing.lg) {

                    // MARK: Hero — icono + nombre (editable en modo edición)
                    hero
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    // MARK: Contenido
                        restrictionsSection
                        rulesSection
                
                
                }
                .padding(.top, 54 + BaseTheme.Spacing.md)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(Color.pageBackground.ignoresSafeArea())
            .overlay(alignment: .topLeading, content: {
                CustomToolbar(title: vm.mode?.name ?? "Mode") {
                    router.navigation.pop()
                }
            })
        .onAppear {
            vm.refreshModeState()
        }
        .alert("Eliminar modo", isPresented: $vm.showDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                vm.deleteMode()
                router.navigation.pop()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .sheet(item: $vm.activationPrompt) { prompt in
            DynamicSheet {
                detailPromptSheet(prompt: prompt)
            }
        }
        .sheet(isPresented: Binding(
            get: { vm.editVM?.showIconPicker ?? false },
            set: { vm.editVM?.showIconPicker = $0 }
        )) {
            if let editVM = vm.editVM {
                DynamicSheet { IconColorPickerSheet(vm: editVM) }
                    .presentationDragIndicator(.hidden)
            }
        }
        .sheet(isPresented: Binding(
            get: { vm.editVM?.showCreateRule ?? false },
            set: { vm.editVM?.showCreateRule = $0 }
        )) {
            if let editVM = vm.editVM {
                DynamicSheet {
                    CreateRuleSheet(
                        modeVM: editVM,
                        preselectedTransition: editVM.preselectedTransition
                    )
                }
                .onDisappear { vm.editVM?.preselectedTransition = nil }
            }
        }
        .sheet(isPresented: Binding(
            get: { vm.editVM?.showScreenTimePicker ?? false },
            set: { vm.editVM?.showScreenTimePicker = $0 }
        )) {
            if let editVM = vm.editVM {
                ScreenTimePickerSheet(vm: editVM)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: BaseTheme.Spacing.md) {
            Button {
                guard vm.isEditing else { return }
                vm.editVM?.showIconPicker = true
            } label: {
                RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                    .fill(Color(hex: vm.editVM?.colorHex ?? vm.mode?.colorHex ?? "#FCE8E3"))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: vm.editVM?.iconName ?? vm.mode?.iconName ?? "target")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(Color(hex: vm.editVM?.colorHex ?? vm.mode?.colorHex ?? "#FCE8E3").contrastingLabel)
                    }
            }
            .buttonStyle(.plain)
            .allowsHitTesting(vm.isEditing)

            HStack {
                Spacer()
                TextField(
                    vm.mode?.name ?? "Nombre del modo",
                    text: Binding(
                        get: { vm.editVM?.name ?? vm.mode?.name ?? "" },
                        set: { vm.editVM?.name = $0 }
                    )
                )
                .font(Typography.title())
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .fixedSize()
                .padding(.vertical, BaseTheme.Spacing.sm)
                .padding(.horizontal, BaseTheme.Spacing.md)
                .frame(minWidth: 120)
                .background(vm.isEditing ? Color.cardBackground : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                .tappable()
                .disabled(!vm.isEditing)
                Spacer()
            }

            if !vm.isEditing, !vm.isNew {
                if vm.isModeActive {
                    Text("This mode is active right now")
                        .font(Typography.caption(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                } else {
                    PrimaryButton(action: vm.handlePlay) {
                        HStack(spacing: BaseTheme.Spacing.sm) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text("Start mode")
                                .font(Typography.body(weight: .semibold))
                        }
                    }
                    .padding(.top, BaseTheme.Spacing.sm)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, BaseTheme.Spacing.sm)
        .animation(.smooth(duration: 0.5), value: vm.isEditing)
    }

    // MARK: - Restrictions

    @ViewBuilder
    private var restrictionsSection: some View {
        let hasApps = !displayedBlockedApps.isEmpty

        if vm.isEditing || hasApps  {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                HStack {
                    Text("Restrictions")
                        .font(Typography.title())
                        .foregroundStyle(Color(.label))
                    Spacer()
                    if vm.isEditing {
                        ToolbarButton(icon: "plus") {
                            vm.editVM?.showScreenTimePicker = true
                        }
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)

                if hasApps {
                    BlockedAppGrid(
                        apps: displayedBlockedApps,
                        onAdd: nil
                    )
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
                if vm.isEditing && !hasApps {
                    StatCard(
                        pretitle: "Restrictions",
                        badge: { EmptyView() },
                        content: {
                            Text("Sin restricciones")
                                .font(Typography.body())
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    )
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }
        }
    }

    // MARK: - Rules

    @ViewBuilder
    private var rulesSection: some View {
        let hasRules = !vm.ruleGroups.isEmpty

        if vm.isEditing || hasRules {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                if vm.isEditing {
                    RulesCard(
                        groups: editRuleGroups,
                        onAddRule: { transition in
                            vm.editVM?.preselectedTransition = transition
                            vm.editVM?.showCreateRule = true
                        },
                        onDeleteRule: { ruleID in
                            vm.editVM?.rules.removeAll { $0.id == ruleID }
                        },
                        isEditing: true
                    )
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                } else {
                    RulesCard(
                        groups: vm.ruleGroups,
                        insight: vm.rulesInsight,
                        onAddRule: nil
                    )
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }
        }
    }
    
    private var editRuleGroups: [RuleGroup] {
        let rules = vm.editVM?.rules ?? []
        return Transition.allCases.map { transition in
            RuleGroup(
                transition: transition,
                participants: rules
                    .filter { $0.transition == transition.rawValue }
                    .map(vm.participantFrom(rule:))
            )
        }
    }

    private var displayedBlockedApps: [BlockedApp] {
        if vm.isEditing, let selection = vm.editVM?.blockedApps {
            return selection.applicationTokens.map(BlockedApp.init(token:))
        }
        return vm.blockedApps
    }

    private var displayedBlockedCategories: [BlockedCategory] {
        if vm.isEditing, let selection = vm.editVM?.blockedApps {
            return selection.categoryTokens.map(BlockedCategory.init(token:))
        }
        return vm.blockedCategories
    }
}

extension ModeDetailView {
    @ViewBuilder
    private func detailPromptSheet(prompt: ModeActivationPrompt) -> some View {
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

            if vm.isModeActive {
                DestructiveButton(action: vm.finishMode) {
                    Text("Finish mode")
                        .font(Typography.body(weight: .semibold))
                }
            }
        }
        .padding(.horizontal, BaseTheme.Spacing.xl)
        .padding(.vertical, BaseTheme.Spacing.xl)
    }
}

// MARK: - Color helper

// MARK: - Preview

#Preview {
    ModeDetailView(mode: Mode(
        id: UUID(), name: "Gym", iconName: "figure.run",
        colorHex: "#E8F5E9", state: ModeState.inactive.rawValue, createdAt: .now
    ))
    .environment(AppRouter())
}
