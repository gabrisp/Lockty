//
//  PermissionsStep.swift
//  Lockty
//

import SwiftUI

struct PermissionsStep: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                Text("Unos permisos")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                Text("Lockty los necesita para funcionar correctamente.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
            }

            VStack(spacing: BaseTheme.Spacing.sm) {
                permissionRow(
                    icon: "bell.fill",
                    title: "Notificaciones",
                    description: "Recibe alertas cuando un amigo quiera bloquear contigo.",
                    state: vm.notificationsState
                ) {
                    Task { await vm.requestNotifications() }
                }
                .haptic(.success, trigger: vm.notificationsGranted)

                permissionRow(
                    icon: "lock.shield.fill",
                    title: "Screen Time",
                    description: "Necesario para bloquear apps durante las sesiones.",
                    state: vm.screenTimeState
                ) {
                    Task { await vm.requestScreenTime() }
                }
                .haptic(.success, trigger: vm.screenTimeGranted)
            }
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onboardingButtonLabel("Empezar")
    }

    private func permissionRow(
        icon: String,
        title: String,
        description: String,
        state: OnboardingViewModel.PermissionState,
        onTap: @escaping () -> Void
    ) -> some View {
        let isGranted  = state == .granted
        let isRejected = state == .rejected

        return Button(action: {
            guard !isGranted else { return }
            Haptics.play(.button)
            onTap()
        }) {
            HStack(alignment: .top, spacing: BaseTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isGranted ? Color.green : isRejected ? Color.red : Color(.label))
                    .frame(width: 32)
                    .animation(.easeInOut(duration: 0.3), value: state)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.body(weight: .semibold))
                        .foregroundStyle(isRejected ? Color.red : Color(.label))
                    Text(isRejected ? "Permiso denegado. Toca para abrir Ajustes." : description)
                        .font(Typography.caption())
                        .foregroundStyle(isRejected ? Color.red.opacity(0.8) : Color(.secondaryLabel))
                        .animation(.easeInOut(duration: 0.3), value: isRejected)
                }

                Spacer()

                Group {
                    if isGranted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                    } else if isRejected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.red)
                    }
                }
                .transition(.blurReplace)
                .animation(.easeInOut(duration: 0.3), value: state)
            }
            .padding(BaseTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BaseTheme.Radius.card)
                    .fill(
                        isGranted  ? Color.green.opacity(0.08) :
                        isRejected ? Color.red.opacity(0.08)   :
                        Color.cardBackground
                    )
                    .animation(.easeInOut(duration: 0.4), value: state)
            )
        }
        .buttonStyle(NoFlashButtonStyle())
    }
}
