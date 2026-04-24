//
//  NameStep.swift
//  Lockty
//

import SwiftUI

struct NameStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: BaseTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BaseTheme.Spacing.xs) {
                Text("¿Cómo te llamas?")
                    .font(Typography.title())
                    .foregroundStyle(Color(.label))
                Text("Así te verán tus amigos.")
                    .font(Typography.body())
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .geometryGroup()
         


            TextField("Tu nombre", text: $vm.displayName)
                .font(Typography.body())
                .padding(BaseTheme.Spacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BaseTheme.Radius.card))
                .autocorrectionDisabled()
                .geometryGroup()
              
        }
        .padding(.horizontal, BaseTheme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onboardingSecondaryAction(label: "Iniciar sesión") {
            vm.jumpToSignIn()
        }
    }
}
