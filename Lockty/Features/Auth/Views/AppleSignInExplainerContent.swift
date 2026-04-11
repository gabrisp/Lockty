//
//  AppleSignInExplainerContent.swift
//  Lockty
//
//  Created by Gabrisp on 11/4/26.
//

import SwiftUI

struct AppleSignInExplainerContent: View {
    var body: some View {
        VStack(alignment: .center, spacing: BaseTheme.Spacing.xl) {
            VStack(alignment: .center, spacing: BaseTheme.Spacing.sm) {
                   Image(systemName: "lock.shield.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary)
                HStack(spacing: BaseTheme.Spacing.sm) {
                    Text("Tu privacidad, primero")
                        .font(Typography.sectionTitle(weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth :.infinity, alignment: .center)

                Text("Todo tu progreso y datos se guardan en tu dispositivo. El inicio de sesión con Apple solo lo necesitamos para gestionar tu suscripción y personalización.")
                    .font(Typography.body())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, BaseTheme.Spacing.md)

                Text("No compartimos nada con terceros.")
                    .font(Typography.body(weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .center, spacing: BaseTheme.Spacing.sm) {
                privacyRow(icon: "iphone", text: "Tus modos y sesiones viven en tu dispositivo")
                privacyRow(icon: "creditcard", text: "Solo usamos Apple para verificar tu suscripción")
                privacyRow(icon: "eye.slash", text: "Nunca vendemos ni compartimos tus datos")
            }
        }
        .padding(BaseTheme.Spacing.lg)
        .padding(.vertical, BaseTheme.Spacing.xl * 2)
    }

    private func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: BaseTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(text)
                .font(Typography.body())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth:.infinity, alignment: .center)
    }
}
