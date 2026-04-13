//
//  CreateRuleSheet.swift
//  Lockty
//

import SwiftUI

struct CreateRuleSheet: View {
    let modeVM: CreateModeViewModel
    @State private var vm: CreateRuleViewModel
    @Environment(\.dismiss) private var dismiss

    init(modeVM: CreateModeViewModel, preselectedTransition: Transition? = nil) {
        self.modeVM = modeVM
        var ruleVM = CreateRuleViewModel()
        if let t = preselectedTransition {
            ruleVM.transition = t
            ruleVM.step = .config
            ruleVM.preselectedTransition = t
        }
        _vm = State(initialValue: ruleVM)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            Text("Nueva regla")
                .font(Typography.title())
                .foregroundStyle(Color(.label))
                .padding(.horizontal, BaseTheme.Spacing.lg)

            switch vm.step {
            case .type:
                typeStep
                    .transition(AnyTransition(.blurReplace).combined(with: .opacity))
            case .config:
                configStep
                    .transition(AnyTransition(.blurReplace).combined(with: .opacity))
            }
        }
        .padding(.vertical, BaseTheme.Spacing.lg)
        .animation(.snappy(duration: 0.3, extraBounce: 0.02), value: vm.step)
    }

    // MARK: - Step 1: Tipo

    private var typeStep: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BaseTheme.Spacing.sm) {
                    ForEach(ConditionType.allCases, id: \.self) { type in
                        Button {
                            vm.selectedType = type
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.02)) {
                                vm.step = .config
                            }
                        } label: {
                            HStack(spacing: BaseTheme.Spacing.sm) {
                                Image(systemName: iconFor(type))
                                    .font(.system(size: 16, weight: .semibold))
                                Text(labelFor(type))
                                    .font(Typography.body(weight: .semibold))
                            }
                            .padding(.horizontal, BaseTheme.Spacing.md)
                            .padding(.vertical, BaseTheme.Spacing.md)
                            .background(Color.cardBackground)
                            .foregroundStyle(Color(.label))
                            .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, BaseTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Step 2: Config + Transición

    private var configStep: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {

            // Back al paso anterior (solo si no viene preseleccionado)
            if vm.preselectedTransition == nil {
                Button {
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0.02)) {
                        vm.step = .type
                    }
                } label: {
                    HStack(spacing: BaseTheme.Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text(labelFor(vm.selectedType ?? .manual))
                            .font(Typography.body(weight: .semibold))
                    }
                    .foregroundStyle(Color(.secondaryLabel))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BaseTheme.Spacing.lg)
            }

            // Campos dinámicos según tipo
            if let type = vm.selectedType {
                typeFields(for: type)
            }

            // Transición
            if vm.preselectedTransition == nil {
                VStack(alignment: .leading, spacing: BaseTheme.Spacing.sm) {
                    Text("Cuándo")
                        .font(Typography.body(weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, BaseTheme.Spacing.lg)

                    HStack(spacing: BaseTheme.Spacing.sm) {
                        ForEach(Transition.allCases, id: \.self) { t in
                            Button {
                                vm.transition = t
                            } label: {
                                Text(labelForTransition(t))
                                    .font(Typography.body(weight: .semibold))
                                    .padding(.horizontal, BaseTheme.Spacing.md)
                                    .padding(.vertical, BaseTheme.Spacing.sm)
                                    .frame(maxWidth: .infinity)
                                    .background(vm.transition == t ? Color(.label) : Color.cardBackground)
                                    .foregroundStyle(vm.transition == t ? Color(.systemBackground) : Color(.label))
                                    .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.2), value: vm.transition)
                        }
                    }
                    .padding(.horizontal, BaseTheme.Spacing.lg)
                }
            }

            // Botón añadir
            PrimaryButton(isDisabled: !vm.canSave) {
                let rule = vm.buildRule(modeId: UUID())
                modeVM.rules.append(rule)
                dismiss()
            } label: {
                Text("Añadir regla")
                    .font(Typography.body(weight: .semibold))
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)
        }
    }

    // MARK: - Campos por tipo

    @ViewBuilder
    private func typeFields(for type: ConditionType) -> some View {
        switch type {
        case .manual:
            Text("Se activa manualmente desde la app.")
                .font(Typography.body())
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, BaseTheme.Spacing.lg)

        case .nfc:
            Text("Se activa al acercar un tag NFC.")
                .font(Typography.body())
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, BaseTheme.Spacing.lg)

        case .location:
            VStack(spacing: BaseTheme.Spacing.sm) {
                TextField("Nombre del lugar", text: $vm.locationName)
                    .font(Typography.body())
                    .padding(BaseTheme.Spacing.md)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))

                VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                    Text("Radio: \(Int(vm.locationRadius))m")
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                    Slider(value: $vm.locationRadius, in: 50...1000, step: 50)
                        .tint(Color(.label))
                }
            }
            .padding(.horizontal, BaseTheme.Spacing.lg)

        case .friend:
            TextField("Nota para el amigo (opcional)", text: $vm.friendNote)
                .font(Typography.body())
                .padding(BaseTheme.Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                .padding(.horizontal, BaseTheme.Spacing.lg)

        case .reminder:
            DatePicker("Hora", selection: $vm.reminderTime, displayedComponents: .hourAndMinute)
                .font(Typography.body())
                .padding(BaseTheme.Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                .padding(.horizontal, BaseTheme.Spacing.lg)
        }
    }

    // MARK: - Helpers

    private func iconFor(_ type: ConditionType) -> String {
        switch type {
        case .manual:   return "hand.tap.fill"
        case .nfc:      return "wave.3.right"
        case .location: return "location.fill"
        case .friend:   return "person.fill"
        case .reminder: return "bell.fill"
        }
    }

    private func labelFor(_ type: ConditionType) -> String {
        switch type {
        case .manual:   return "Manual"
        case .nfc:      return "NFC"
        case .location: return "Ubicación"
        case .friend:   return "Amigo"
        case .reminder: return "Recordatorio"
        }
    }

    private func labelForTransition(_ t: Transition) -> String {
        switch t {
        case .activate:   return "Activar"
        case .startBreak: return "Pausa"
        case .stop:       return "Detener"
        }
    }
}
