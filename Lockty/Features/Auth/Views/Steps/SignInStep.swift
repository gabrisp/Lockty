//
//  SignInStep.swift
//  Lockty
//

import SwiftUI
import FirebaseAuth

struct SignInStep: View {
    @Bindable var vm: OnboardingViewModel
    let router: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                Text(vm.isLoginFlow ? "Iniciar sesión" : "Vincula tu cuenta")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                Text(vm.isLoginFlow
                     ? "Inicia sesión para recuperar tu progreso."
                     : "Sincroniza tu progreso y accede desde cualquier dispositivo.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
            }

            // Botón principal
            PrimaryButton(isLoading: vm.isLoading, action: {
                Haptics.play(.button)
                Task { await vm.signInWithApple(router: router) }
            }) {
                HStack(spacing: BaseTheme.Spacing.sm) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Continuar con Apple")
                        .font(Typography.body(weight: .semibold))
                }
            }

            // Sección secundaria — ¿Por qué necesito esto? (solo en register flow)
            VStack(spacing: BaseTheme.Spacing.xs) {
                if !vm.isLoginFlow {
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
                    .opacity(vm.isLoading ? 0 : 1)
                    .animation(.easeInOut(duration: 0.2), value: vm.isLoading)
                }
            }
            .frame(height: 32)
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .hideOnboardingButton()
        .onboardingBackButtonOverride(vm.isLoginFlow ? {
            try? Auth.auth().signOut()
            vm.isLoading = false
            withAnimation(.snappy) {
                vm.isLoginFlow = false
                vm.currentStep = .name
            }
        } : {
            try? Auth.auth().signOut()
            vm.isLoading = false
            vm.prevStep()
        })
        .sheet(isPresented: $vm.showAppleSignInSheet) {
            DynamicSheet {
                AppleSignInExplainerContent()
            }
        }
    }
}
