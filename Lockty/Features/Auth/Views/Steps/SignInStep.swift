//
//  SignInStep.swift
//  Lockty
//

import SwiftUI

struct SignInStep: View {
    @Bindable var vm: OnboardingViewModel
    let router: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                Text("Crea tu cuenta")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                Text("Necesario para una experiencia completa de la aplicación.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
            }

            VStack(spacing: BaseTheme.Spacing.sm) {
                PrimaryButton(isLoading: vm.isLoading, action: {
                    Haptics.play(.button)
                    Task { await vm.signInWithApple(router: router) }
                }) {
                    HStack(spacing: BaseTheme.Spacing.sm) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Iniciar sesión con Apple")
                            .font(Typography.body(weight: .semibold))
                    }
                }

                Button {
                    Haptics.play(.selection)
                    vm.showAppleSignInSheet = true
                } label: {
                    Text("¿Por qué necesito esto?")
                        .font(Typography.caption())
                        .foregroundStyle(Color(.secondaryLabel))
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .hideOnboardingButton()
        .sheet(isPresented: $vm.showAppleSignInSheet) {
            DynamicSheet {
                AppleSignInExplainerContent()
            }
        }
    }
}
