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
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(spacing: BaseTheme.Spacing.lg) {

                    // MARK: Hero — icono + nombre (editable en modo edición)
                    hero
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    Picker("", selection: $vm.selectedTab) {
                        ForEach(ModeDetailViewModel.ModeDetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, BaseTheme.Spacing.lg)

                    // MARK: Contenido
                    switch vm.selectedTab {
                    case .overview:
                        restrictionsSection
                        rulesSection
                    case .stats:
                        Text("Stats coming soon")
                            .font(Typography.caption())
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(maxWidth: .infinity)
                            .padding(.top, BaseTheme.Spacing.xxl)
                            .padding(.horizontal, BaseTheme.Spacing.lg)
                }
                }
                .padding(.top, 54 + BaseTheme.Spacing.md)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(Color.pageBackground.ignoresSafeArea())

            // Blur overlay
            GeometryReader { geo in
                VariableBlurView(maxBlurRadius: 16, direction: .blurredTopClearBottom)
                    .frame(height: 54 + geo.safeAreaInsets.top + 8)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .frame(height: 0)

            // Toolbar flotante
            GlassEffectContainer(spacing: 10) {
                HStack(spacing: 10) {
                    ToolbarButton(icon: "chevron.left") {
                        router.navigation.pop()
                    }

                    Spacer()

                    if vm.isEditing {
                        if !vm.isNew {
                            ToolbarButton(icon: "xmark") { vm.cancelEdit() }
                        }
                        ToolbarButton(icon: "checkmark") {
                            try? vm.saveEdit()
                            if vm.isNew { router.navigation.pop() }
                        }
                    } else {
                        Menu {
                            Button { vm.startEditing() } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                vm.showDeleteAlert = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        } label: {
                            Circle()
                                .foregroundStyle(.clear)
                                .frame(width: 50, height: 50)
                                .overlay {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color(.label))
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(BaseTheme.Spacing.md)
            .animation(.smooth(duration: 0.5), value: vm.isEditing)
        }
        .navigationBarBackButtonHidden()
        .offset(y: max(dragOffset, 0))
        .gesture(
            DragGesture()
                .onChanged { value in dragOffset = value.translation.height }
                .onEnded { value in
                    if value.translation.height > 100 || value.predictedEndTranslation.height > 220 {
                        router.navigation.pop()
                    } else {
                        withAnimation(.spring(duration: 0.3)) { dragOffset = 0 }
                    }
                }
        )
        .alert("Eliminar modo", isPresented: $vm.showDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                vm.deleteMode()
                router.navigation.pop()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: Binding(
            get: { vm.editVM?.showIconPicker ?? false },
            set: { vm.editVM?.showIconPicker = $0 }
        )) {
            if let editVM = vm.editVM { DynamicSheet { IconPickerSheet(vm: editVM) } }
        }
        .sheet(isPresented: Binding(
            get: { vm.editVM?.showColorPicker ?? false },
            set: { vm.editVM?.showColorPicker = $0 }
        )) {
            if let editVM = vm.editVM { DynamicSheet { ColorPickerSheet(vm: editVM) } }
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
        VStack(spacing: BaseTheme.Spacing.sm) {
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
                            .foregroundStyle(Color(.label))
                    }
                    .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(!vm.isEditing)

            if vm.isEditing, let editVM = vm.editVM {
                @Bindable var editVM = editVM
                HStack(alignment: .center, spacing: BaseTheme.Spacing.sm) {
                    TextField(vm.mode?.name ?? "Nombre del modo", text: $editVM.name)
                        .font(Typography.title())
                        .foregroundStyle(Color(.label))
                        .multilineTextAlignment(.leading)
                        .autocorrectionDisabled()
                        .padding(.horizontal, BaseTheme.Spacing.lg)
                        .padding(.vertical, BaseTheme.Spacing.md)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))

                    Button { editVM.showColorPicker = true } label: {
                        Circle()
                            .fill(Color(hex: editVM.colorHex))
                            .frame(width: 30, height: 30)
                            .overlay {
                                Circle()
                                    .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(vm.mode?.name ?? "")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
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
        let hasCategories = !displayedBlockedCategories.isEmpty

        if vm.isEditing || hasApps || hasCategories {
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
                if hasCategories {
                    BlockedCategoryGrid(
                        categories: displayedBlockedCategories,
                        onAdd: nil
                    )
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
                if vm.isEditing && !hasApps && !hasCategories {
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

// MARK: - Color helper

// MARK: - Preview

#Preview {
    ModeDetailView(mode: Mode(
        id: UUID(), name: "Gym", iconName: "figure.run",
        colorHex: "#E8F5E9", state: ModeState.inactive.rawValue, createdAt: .now
    ))
    .environment(AppRouter())
}
